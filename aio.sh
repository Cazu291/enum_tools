#!/bin/bash

read -r -d '' ascii_art << 'EOF'
-       █▒▒   █▒▒▒▒
 █▒▒▒▒  █▒▒ █▒▒ █▒▒
 █▒ █▒▒ █▒▒ █▒▒ █▒▒
█▒▒ █▒▒ █▒▒ █▒▒ █▒▒
█▒▒▒▒▒▒ █▒▒ █▒▒ █▒▒ █▒▒
█▒▒ █▒▒ █▒▒ █▒▒ █▒▒
█▒▒ █▒▒ █▒▒ █▒▒▒▒
EOF

printf "%s\n" "$ascii_art"

header_separator="===================================================================================="
command_separator="================================================================"

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
	echo ""
}

run=false

if [ -z $1 ]; then
        echo "Command usage is: aio.sh <target> [<website>]"
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
