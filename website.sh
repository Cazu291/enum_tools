#!/bin/bash

separator="================================================================"
run=false

if [ -z $1 ]; then
	if [ -z $box ]; then
	        echo "If \$box is not set, command usage is: ports.sh <target>"
	else
		target=$box
		run=true
	fi
else
	target=$1
	run=true
fi

if [ "$run"=true ]; then

        dirs_wordlist=/usr/share/wordlists/dirb/big.txt
        subs_wordlist=/usr/share/wordlists/dirb/subs/n0kovo_subdomains/n0kovo_subdomains_medium.txt

        # pretty print
        echo $separator
        echo "--"
        echo "||"
        echo "|| Scans will now begin on directories and subdomains"
        echo "||"
        echo "--"

        # scans for dirs
	echo $separator
        echo "-"
        echo "|"
        echo "| Now scanning for directories and web pages on the main page"
        echo "|"
        echo "| $ ffuf -u http://$box/FUZZ -w $dirs_wordlist -o dirs.scan"
        echo "|"
        echo "-"
        echo ""
        ffuf -u http://$box/FUZZ -w $dirs_wordlist -o dirs.scan

        # scans for subdomains
	echo $separator
        echo "-"
        echo "|"
        echo "| Now scanning for subdirectories starting from the main page"
        echo "|"
        echo "| $ ffuf -u http://FUZZ.$box -w $subs_wordlist -o subs.scan"
        echo "|"
        echo "-"
        echo ""
        ffuf -u http://FUZZ.$box -w $subs_wordlist -o subs.scan

fi
