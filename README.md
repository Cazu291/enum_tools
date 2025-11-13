# enum_tools
obsidian://open?vault=Cysec%20Notes&file=Pasted%20image%2020251113230441.png

This tool was designed to run a very simple set of commands for scanning a machine, especially for a htb machine, as they usually contain a website to use for privesc.

Quick command is
```
./aio.sh -t <ip>
```

If it is impossible to connect to the website without the use of the domain name, use the `-u` option:
```
./aio.sh -t <ip> -u <domain_name.com>
```

For a more complete control of the wordlists used for directories, files and subdomains scanning, you can respectively use the options `-d`, `-f` and `-s`
```
./aio.sh -t <ip> -d <dirs_list> -f <files_list> -s <subs_list>
```

All scans outputs are written in the files `nmap.scan`, `nma-all-ports.scan`, `nmap-udp.scan`, `dirs.scan` and `subs.scan`. The options to modify those outputs files are not yet available.
