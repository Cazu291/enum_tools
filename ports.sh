#!/bin/bash

separator="================================================================"
run=false

if [ -z $1 ]; then
        if [ -z $box ]; then
                echo "Please either set the variable \$box or provide an ip so I set it for you"
	else
		target=$box
		run=true
        fi
else
	target=$1
	run=true
fi

if [ "$run"=true ]; then
        # assigning value and pretty print
        echo $separator
        echo "--"
        echo "||"
        echo "||target is: $box"
        echo "||"
        echo "--"
        echo $separator

        # basic nmap
	echo "-"
	echo "|"
	echo "| Running a basic nmap scan on the target"
	echo "|"
	echo "| $ nmap -sV $box -o nmap.scan"
	echo "|"
	echo "-"
	echo ""
        nmap -sV $box -o nmap.scan

        # advanced nmap
	echo "-"
	echo "|"
	echo "| Running an extended nmap scan on $box"
	echo "|"
	echo "| $ nmap -A $box -o nmap_extended.scan"
	echo "|"
	echo "-"
        nmap -A $box -o nmap_extended.scan

        # Syn stealth nmap
        # needs the sudo to be started
	echo "-"
        echo "|"
        echo "| Running a Syn Stealth nmap scan on $box"
        echo "|"
        echo "| $ sudo nmap -sS $box -o nmap_stealth.scan"
        echo "|"
        echo "-"
        sudo nmap -sS $box -o nmap_stealth.scan

        # UDP nmap
        echo "-"
        echo "|"
        echo "| Running an UDP nmap scan on $box"
        echo "|"
        echo "| $ sudo nmap -sU $box -o nmap_udp.scan"
        echo "|"
        echo "-"
        nmap -sU $box -o nmap_udp.scan
fi
