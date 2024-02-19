#!/bin/bash

light_install="https://raw.githubusercontent.com/f5nodes/celestia/main/light_install.sh"
full_install="https://raw.githubusercontent.com/f5nodes/celestia/main/full_install.sh"
bridge_install="https://raw.githubusercontent.com/f5nodes/celestia/main/bridgeinstall.sh"

PS3='Enter your option: '
options=("Install the light node" "Install the full node" "Install the bridge node" "Quit")
selected="You choose the option"

select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $light_install)
            break
            ;;
        "${options[1]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $full_install)
            break
            ;;
        "${options[2]}")
            echo "$selected $opt"
            sleep 1
            . <(wget -qO- $bridge_install)
            break
            ;;
        "${options[3]}")
			echo "$selected $opt"
            break
            ;;
        *) echo "unknown option $REPLY";;
    esac
done