#!/bin/bash

header_separator="===================================================================================="
command_separator="================================================================"
banner=" \
      █▒             █▒▒          █▒▒▒▒      \
      █▒ ▒▒           █▒▒        █▒▒    █▒▒  \
     █▒  █▒▒          █▒▒      █▒▒        █▒▒\
    █▒▒   █▒▒         █▒▒      █▒▒        █▒▒\
   █▒▒▒▒▒▒ █▒▒        █▒▒      █▒▒        █▒▒\
  █▒▒       █▒▒       █▒▒        █▒▒     █▒▒ \
 █▒▒         █▒▒      █▒▒          █▒▒▒▒     \
"

print_header () {
	echo $header_separator
	echo "|||"
	echo "|||"
	echo "||| $1"
	echo "|||"
	echo "|||"
	echo $header_separator
	echo ""
}

run_command () {
	echo $command_separator
	echo "|"
	echo "| $1"
	echo "|"
	echo "| $ $2"
	echo "|"
	echo "-"
	echo ""
	$2
}

run=false

if [ -z $1 ]; then
        echo "Command usage is: ai1.sh <target> [<website>]"
else
	target=$1
	web_scans=false;
	if [ -z $3 ]; then
		echo "website not specified, dirs and subs scans will be skipped"
	else
		website=$3
		web_scans=true
	fi

        dirs_wordlist=/usr/share/wordlists/dirb/big.txt
        subs_wordlist=/usr/share/wordlists/dirb/subs/n0kovo_subdomains/n0kovo_subdomains_medium.txt

	echo $banner
	echo ""
	echo ""

	print_header "Starting basic scans on ports and website dirs"
	run_command "nmap quick tcp scan on $target" "nmap $target -o nmap.scan"
	run_command "nmap extended tcp on $target"  "nmap -A $target -o nmap.scan"
	if [ "$web_scans" = true ]; then
		run_command "ffuf scanning for directories on the website $website" "ffuf -u http://$website/FUZZ -w $dirs_wordlist -o dirs.scan"
	fi

	print_header "Now running advanced scans on ports and website"
	run_command "nmap syn stealth scan on $target" "sudo nmap -sS $target -o nmap-stealth.scan"
	run_command "nmap script scan on $target" "nmap -sC -p- --open -o nmap-scripts.txt $target"
	if [ "web_scans" = true ]; then
		run_command "ffuf scanning for subdomains on the website $website" "ffuf -u http://FUZZ.$website -w $subs_wordlist -o subs.scan"
	fi
	run_command "nmap udp scan on $target" "nmap -sU $target -o nmap-udp.scan"

fi

if [ $false ]; then
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
	echo "| Running a basic nmap scan on $target"
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
	echo "| Running an extended nmap scan on $target"
	echo "|"
	echo "| $ nmap -A $target -o nmap-extended.scan"
	echo "|"
	echo "-"
        nmap -A $target -o nmap-extended.scan

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

        # Syn stealth nmap
        # needs the sudo to be started
	echo $separator
	echo "-"
        echo "|"
        echo "| Running a Syn Stealth nmap scan on $target"
        echo "|"
        echo "| $ sudo nmap -sS $target -o nmap_stealth.scan"
        echo "|"
        echo "-"
        sudo nmap -sS $target -o nmap-stealth.scan

	# scripts nmap
        echo $separator
        echo "-"
        echo "|"
        echo "| Running nmap scan with default scripts on $target"
        echo "|"
	echo "| $ nmap -sC -p- --open -o nmap-full.txt $target"
        echo "|"
        echo "-"
        echo ""
	nmap -sC -p- --open -o nmap-scripts.txt $target

        # UDP nmap
	echo $separator
        echo "-"
        echo "|"
        echo "| Running an UDP nmap scan on $target"
        echo "|"
        echo "| $ sudo nmap -sU $target -o nmap_udp.scan"
        echo "|"
        echo "-"
        nmap -sU $target -o nmap-udp.scan

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

