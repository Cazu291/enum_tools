#!/bin/bash

separator="================================================================"
run=false

if [ -z $1 ]; then
        echo "Command usage is: ports.sh <target>"
	target=$1

        dirs_wordlist=/usr/share/wordlists/dirb/big.txt
        subs_wordlist=/usr/share/wordlists/dirb/subs/n0kovo_subdomains/n0kovo_subdomains_medium.txt

        # pretty print
        echo $separator
        echo "--"
        echo "||"
        echo "|| Now scanning for directories and subdirectories."
        echo "||"
	echo "|| target is: $target."
	echo "||"
        echo "--"

        # scans for dirs
	echo $separator
        echo "-"
        echo "|"
        echo "| Now scanning for directories and web pages on the main page"
        echo "|"
        echo "| $ ffuf -u http://$target/FUZZ -w $dirs_wordlist -o dirs.scan"
        echo "|"
        echo "-"
        echo ""
        ffuf -u http://$target/FUZZ -w $dirs_wordlist -o dirs.scan

        # scans for subdomains
	echo $separator
        echo "-"
        echo "|"
        echo "| Now scanning for subdirectories starting from the main page"
        echo "|"
        echo "| $ ffuf -u http://FUZZ.$target -w $subs_wordlist -o subs.scan"
        echo "|"
        echo "-"
        echo ""
        ffuf -u http://FUZZ.$target -w $subs_wordlist -o subs.scan

fi
