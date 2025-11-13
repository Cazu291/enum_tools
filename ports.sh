#!/bin/bash

separator="================================================================"
run=false

if [ -z $1 ]; then
        echo "Command usage is: ports.sh <target>"
else
	target=$1
        # assigning value and pretty print
        echo $separator
        echo "--"
        echo "||"
	echo "|| Now starting ports scans."
	echo "||"
        echo "|| target is: $target."
        echo "||"
        echo "--"

        # basic nmap
	echo $separator
	echo "-"
	echo "|"
	echo "| Running a basic nmap scan on the target"
	echo "|"
	echo "| $ nmap $target -o nmap.scan"
	echo "|"
	echo "-"
	echo ""
        nmap $target -o nmap.scan

        # advanced nmap
	echo $separator
	echo "-"
	echo "|"
	echo "| Running an extended nmap scan on $box"
	echo "|"
	echo "| $ nmap -A $target -o nmap_extended.scan"
	echo "|"
	echo "-"
        nmap -A $target -o nmap_extended.scan

        # Syn stealth nmap
        # needs the sudo to be started
	echo $separator
	echo "-"
        echo "|"
        echo "| Running a Syn Stealth nmap scan on $box"
        echo "|"
        echo "| $ sudo nmap -sS $target -o nmap_stealth.scan"
        echo "|"
        echo "-"
        sudo nmap -sS $target -o nmap_stealth.scan

        # UDP nmap
	echo $separator
        echo "-"
        echo "|"
        echo "| Running an UDP nmap scan on $box"
        echo "|"
        echo "| $ sudo nmap -sU $target -o nmap_udp.scan"
        echo "|"
        echo "-"
        nmap -sU $target -o nmap_udp.scan
fi
