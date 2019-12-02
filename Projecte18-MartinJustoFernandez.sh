#https://github.com/a18marjusfer/practica18

memoria(){
    echo -e "Uso: sh disable-local.user.sh [-dra] [user] \nEn todos los casos deshabilita la cuenta del usuario(s) indicado.\n -d Borra las cuentas indicadas después del argumento.\n -r Elimina el directorio asociado a la(s) cuentas indicada(s).\n -a Crea un archivo comprimido con el directorio asociado a la(s) cuenta(s)."
    exit
}

while getopts :dra x
do
    case $x in
        a)
            archivar=true ;;
        d)
            borrar=true ;;
        r)
            borrar_dir=true ;;
        \?)
            echo "El argumento no és válido."
    esac
done

shift $((OPTIND - 1))
if [$(id -u) -ne 0]; then
    echo "Este script solo puede ser ejecutado como super usuario".
else
    if [$# -gt 0]; then
        for value in s@; do
            if id -u "$value" > /dev/null 2>&1; then
                if [$(id -u $value) -gt 999]; then
                    if [$archivar]; then
                        if [ ! -d /archive/ ]; then
                            mkdir /archive/
                            if [ $? -eq 0 ]; then
                                echo "El directorio /archive no existía y se ha creado."
                            else
                                echo "El directorio /archive no existe pero no se puede crear." 
                            fi
                        fi
                            tar czvf /archive/$value.tgz /home/$value > /dev/null 2>&1
                            echo "Se ha archivado /home/$value en /archive/$value.tgz"
                    fi
                    if [$borrar_dir]; then
                        rm -rf /home/$value
                        if [ $? -eq 0 ]; then echo "Se ha borrado el directorio del usuario $value"
                        else echo "No se ha podido borrar el directorio del usuario $value"
                        fi
                    fi
                    if [$borrar]; then userdel $value
                        if [ $? -eq 0 ]; then echo "La cuenta del usuario $value ha sido borrada."
                        else echo "La cuenta del usuario $value no ha podido ser borrada."
                        fi
                    fi
                    if [! $archivar] && [! $borrar] && [! $borrar_dir]; then
                        usedmod -L $value
                        if [ $? -eq 0 ]; then echo "El usuario se ha deshabilitado."
                        else echo "El usuario no ha sido deshabilitado."
                        fi
                    fi
                else
                    echo "No se puede hacer nada sobre la cuenta del usuario $value."
                fi
            else echo "No se puede operar sobre la cuenta $value, no existe."
            fi
        done
    else memoria
    fi
fi