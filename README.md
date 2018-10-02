# LoopiaDNSUpdater


======================================================================
========================    INFO     =================================
 This script checks the external IP (using curl -s ipecho.net/plain`).
 If the IP has changed since the last run, it will call Loopia API and update the DNS records.

 Requirements:	write permission to <LASTIPFILE> path_info
				Loopia DNS configured
				This script scheduled to run frequently. Every 1 hour recommended
 				0 * * * * perl /home/scripts/loopiadns.pl
 Parameters:
				-debug   (writes user-friendly information to output)
 ======================================================================
