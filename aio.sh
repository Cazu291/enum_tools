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
echo ""
echo ""
echo "Thank you for using this tool"
echo "credit goes to nmap and ffuf for being so useful"
echo " - TheLastOfEugenes"


header_separator="===================================================================================="
command_separator="================================================================"

# Error message function
error_message () {
	echo ""
	echo "usage: aio.sh ([<flag> [<value>]]*|--target <target>)"
	echo "  Options:"
	echo "    -t| --target <target>	: specifies the targeted ip, required"
	echo "    -d| --dirlist <list>	: change the file for the directories fuzzing, default is	/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt"
	echo "    -f| --filelist <list>	: change the file for the files fuzzing, default is		/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt"
	echo "    -s| --sublist <list>	: change the file for the subs fuzzing, default is		/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt"
	echo "    -u| --url <url>		: sets the domain name/url for the web scans, example would be 	-u editor.htb"
	echo ""
}


# Source - https://stackoverflow.com/a
# gets arguments

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--target)
      target="$2"
      shift # past argument
      shift # past value
      ;;
    -d|--dirlist)
      dirlist="$2"
      shift # past argument
      shift # past value
      ;;
    -f|--filelist)
      filelist="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--sublist)
      sublist="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--url)
      url="$2"
      shift # past argument
      shift # past value
      ;;
    --default)
      DEFAULT=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [ -z "$target" ]; then
	error_message
	exit 1
fi

set -- "${POSITIONAL_ARGS[@]}"

if [ -z "$url" ]; then
	url="$target"
fi

if [ -z "$filelist" ]; then
	filelist="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-files-lowercase.txt"
fi
if [ -z "$dirlist" ]; then
	dirlist="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories-lowercase.txt"
fi
if [ -z "$sublist" ]; then
	sublist="/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt"
fi

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

main () {

	echo $banner
	echo ""
	echo ""

	echo $command_separator
	echo "|| set parameters are:"
	echo "||"
	echo "|| target: $target"
	echo "|| url: $url"
	echo "|| dirlist: $dirlist"
	echo "|| sublist: $sublist"
	echo "|| filelist: $filelist"
	echo ""

	## simple scans
	print_header "Starting basic scans on ports and website dirs"
	# nmap scans
	run_command "nmap basic tcp on $target"  "nmap -sCV -T4 -v $target -oN nmap.scan"
	# ffuf scan
	run_command "ffuf scanning for directories on the website $url" "ffuf -u http://$url/FUZZ -w $dirlist -o dirs.scan"

	## advanced scans
	print_header "Now running advanced scans on ports and website"
	# ffuf scans
	run_command "ffuf scanning for subdomains on the website $url" "ffuf -u http://FUZZ.$url -w $sublist -o subs.scan"
	run_command "ffuf scanning for files on the website $url" "ffuf -u http://$url/FUZZ -w $filelist -o files.scan"
	# nmap scans
	run_command "nmap all ports scan on $target" "nmap -T4 -v -p- --open $target -oN nmap-all-ports.scan"
	run_command "nmap udp scan on $target" "nmap -sU -v -T4 $target -oN nmap-udp.scan"

}

main "$@"
