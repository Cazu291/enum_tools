#!/bin/bash

separator="================================================================"

if [ -z $1 ]; then
        if [ -z $box ]; then
                echo "you have to either set the variable box or provide an ip so i set it for you"
        fi
else
        # assigning value and pretty print
        export box=$1
        echo $separator
        echo "__"
        echo "||"
        echo "||target is: $box"
        echo "||"
        echo "__"
        echo $separator

        # basic nmap
        nmap -sV $box -o nmap.scan

        # advanced nmap
        nmap -A $box -o nmap_extended.scan

        # Syn stealth nmap
        # needs the sudo to be started
        sudo nmap -sS $box -o nmap_stealth.scan

        # UDP nmap
        nmap -sU $box -o nmap_udp.scan
fi
