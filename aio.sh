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

read -r -d '' header_separator << 'EOF'
-----------------------------------------------------------------------------------------------------------------------------------------------------------
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----------------------------------------------------------------------------------------------------------------------------------------------------------
EOF

command_separator="================================================================"

# Error message function
error_message () {
	echo ""
	echo "usage: aio.sh ([<flag> [<value>]]*|--target <target>)"
	echo "  Options:"
	echo "    -t| --target <target>	: specifies the targeted ip, required"
	echo "    -u| --url <url>		: sets the domain name/url for the web scans, example would be 	-u editor.htb"
	echo "    -d| --dirlist <list>	: change the file for the directories fuzzing, default is	/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories-lowercase.txt"
	echo "    -f| --filelist <list>	: change the file for the files fuzzing, default is		/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-files-lowercase.txt"
	echo "    -s| --sublist <list>	: change the file for the subs fuzzing, default is		/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
	echo "    -r| --reclist <list>	: change the file for the recursive directory fuzzing, it is recommended to use a small file for this one. Default is"
	echo "												/usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-directories-lowercase.txt"
	echo "    -o| --output <dir>		: a directory will be created with the results of the scans inside -- default is 'aio_scans' -- to avoid creating one just use the value '.'"
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
    -r|--reclist)
      reclist="$2"
      shift;
      shift;
      ;;
    -o|--output)
      output="$2"
      shift
      shift
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
	sublist="/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
fi
if [ -z "$reclist" ]; then
	reclist="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-directories-lowercase.txt"
fi
if [ -z "$output" ]; then
	output="aio_scans"
fi

print_header () {
	printf "%s\n" "$hader_separator"
	echo "|||"
	echo "|||"
	echo "||| $1"
	echo "|||"
	echo "|||"
	printf "%s\n" "$header_separator"
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
	echo "|| reclist: $reclist"
	echo "|| output dir: $output"
	echo ""

	if [ ! -d "$output" ]; then
    		mkdir -p "$output"
   		echo "Directory created: $output"
	fi

	## simple scans
	print_header "Starting with basic scans on ports and website dirs"
	# nmap scans
	run_command "nmap basic tcp on $target"  "nmap -sCV -T4 -v $target -oN aio_scans/nmap.scan"
	# ffuf scan
	run_command "ffuf scanning for directories on the website $url" "ffuf -u http://$url/FUZZ -w $dirlist -o $output/dirs.json"
	run_command "ffuf scanning for files on the website $url" "ffuf -u http://$url/FUZZ -w $filelist -o $output/files.json"
	# nuclei scan
	run_command "nuclei scan on the main website $url" "nuclei -u $url -o $output/nuclei.scan"


	## advanced scans
	print_header "Running advanced scans on website and subdirectories"
	# ffuf scans
	run_command "ffuf scanning for subdomains on the website $url" "ffuf -u http://FUZZ.$url -w $sublist -o $output/subs.json"
	subs=$(cat subs.json | jq -r '.results[].url')
	touch targets.txt
	for sub in $subs; do
		echo "$subs" >> targets.txt
	done
	run_command "nuclei scanning each subdomain" "nuclei -l targets.txt -o $output/nuclei-subs.scan"
	echo "$url" >> targets.txt
	run_command "ffuf scanning for drectories on the subdomains" "ffuf -u 'TARGET/FUZZ' -w targets.txt:TARGET -w $reclist:FUZZ -recursion -recursion-depth 3 -o $output/sub-rec.json"
	rm targets.txt


	# last ports
	print_header "Finishing with ports as to not miss anything"
	# nmap scans
	run_command "nmap all ports scan on $target" "nmap -T4 -v -p- --open $target -oN $output/nmap-all-ports.scan"
	run_command "nmap udp scan on $target" "nmap -sU -v -T4 $target -oN $output/nmap-udp.scan"

}

main "$@"

