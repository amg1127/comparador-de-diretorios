#!/bin/bash
if [ "x${3}" != "x" -o "x${1}" == "x" ]; then
    echo "Uso: ${0} [origem] [destino]"
    exit 1
fi
origem="${1}"
destino="${2}"
leng="`expr length \"${origem}\"`"
find -- "${origem}" | while read elem; do
    base="`echo \"$elem\" | cut -b \"${leng}-\"`"
    outro="${destino}/${base}"
    if [ -h "${outro}" -o -e "${outro}" ]; then
        if [ -h "${elem}" ]; then
            alvo="`readlink \"${elem}\"`"
            if [ -h "${outro}" ]; then
                outroalvo="`readlink \"${outro}\"`"
                if ! [ "${outroalvo}" == "${alvo}" ]; then
                    echo "Alvo do link simbolico '${base}' difere:"
                    echo "    O => '${alvo}'"
                    echo "    D => '${outroalvo}'"
                fi
            else
                echo "Link simbolico '${base}' nao eh link simbolico no destino."
                echo "    => '${alvo}'"
            fi
        elif [ -d "${elem}" ]; then
            if ! [ -d "${outro}" ]; then
                echo "Diretorio '${base}' nao eh diretorio no destino."
            fi
        elif [ -p "${elem}" ]; then
            if ! [ -p "${outro}" ]; then
                echo "FIFO '${base}' nao eh FIFO no destino."
            fi
        elif [ -b "${elem}" -o -c "${elem}" ]; then
            if [ -b "${outro}" -o -c "${outro}" ]; then
                propelem="`stat -c '%F 0x%t 0x%T' \"${elem}\"`"
                propoutro="`stat -c '%F 0x%t 0x%T' \"${outro}\"`"
                if ! [ "${propelem}" == "${propoutro}" ]; then
                    echo "Dispositivo '${base}' difere do destino."
                    echo "    O => ${propelem}"
                    echo "    D => ${propoutro}"
                fi
            else
                echo "Dispositivo '${base}' nao eh dispositivo no destino."
            fi
        elif [ -f "${elem}" ]; then
            if [ -f "${outro}" ]; then
                diff --brief -- "${elem}" "${outro}"
            else
                echo "Arquivo regular '${base}' nao eh arquivo regular no destino."
            fi
        elif [ -S "${elem}" ]; then
            if ! [ -S "${outro}" ]; then
                echo "Soquete UNIX '${base}' nao eh soquete UNIX no destino."
            fi
        else
            echo "Item nao previsto: '${base}'. Abortando..."
            exit 1
        fi
    else
        echo "Item '${base}' nao existe no destino."
    fi
done
