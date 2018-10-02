#!/usr/bin/env perl
use strict;
use warnings;
use v5.24;
use diagnostics;


# ======================================================================
# ========    INFO     =================================================
# This script checks the external IP (using curl -s ipecho.net/plain`).
# If the IP has changed since the last run, it will call Loopia API and update the DNS records.
#
# Requirements:	write permission to <LASTIPFILE> path_info
#				Loopia DNS configured
#				This script scheduled to run frequently. Every 1 hour recommended
# 				0 * * * * perl /home/scripts/loopiadns.pl
# Parameters:
#				-debug   (writes user-friendly information to output)
# ======================================================================




# ======================================================================
# CONFIG
# ======================================================================
use constant LASTIPFILE => "/home/scripts/loopiadns_lastip.txt"; #File to store IP-adress
my $cred		="username:password"; #Loopia credentials. Format = [username:password]
my $hostnames	="example.com,www.example.com,test.example.com"; #my domains and subdomains separated with comma (,)
# ======================================================================
# END CONFIG
# ======================================================================




my $input 		=  $ARGV[0];
my $debug 		= 0;	# 0 = debug OFF, 1 = DEBUG ON
my $lastIP 		= "";
my $currentIP 	= "";


# Parse input params
if(not defined $input) { $debug = 0; }
elsif(defined $input && $input eq "-debug"){ $debug = 1; }
else { die "The only allowed <option> is [-debug]"; }


sub Send_ip_to_Loopia
{
	my ($ip, $cred, $hostnames) = @_;
	my $baseURL = "https://dyndns.loopia.se";
	my $url = join('', $baseURL, "?hostname=", $hostnames);
	$url = join('', $url, "&myip=", $ip);
	$url = join('', $url, "&wildcard=on");
	if($debug==1) { say "final URL: $url"; }
	my $response = `curl -S --user '$cred' '$url'`;
	if($debug==1) { say "response: $response"; }
	return 1;
}



sub Write_ip_to_file
{
	my ($file, $ip) = @_;
	# the file is truncated and opened for output, being created if necessary.
	open my $fw, '>', $file or die $!;
	# output to the file
	print $fw join('', $ip, "\n");	
	close $fw;
	if($debug==1) { say "Wrote new IP to text file <$file>"; }
}


sub Get_external_ip {
	my $ip = `curl -s ipecho.net/plain`;
	if ( $ip =~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/) {
		if($debug==1) { say "Valid external IP fetched. <$ip>"; }
		return $ip;
	}
	else { die "Failed to fetch valid IP. Received value was <$ip>"; }
}

sub Get_last_ip {
	my ($file) = @_;
	#create the file if it doesn't exist
	unless(-e $file) {
		if($debug==1) { say "Creating file to store IP in"; }
		open my $fc, ">", $file or die $!;
		close $fc;
	}


	# Read the last IP from the file
	open my $fh, "<", $file or die $!;
	my $ip = <$fh>;
	if (!defined $ip) { say "clearing variable"; $ip = ""; }
	else { chomp($ip); }
	close $fh;
	if($debug==1) {say "The last IP was <$ip>"; }
	return $ip;
}


# Get the last IP adress
$lastIP = Get_last_ip(LASTIPFILE);


# Get current external IP adress
$currentIP = Get_external_ip();


# If the current IP adress differs from the last IP we send it to Loopia
if($currentIP ne $lastIP) {
	Send_ip_to_Loopia($currentIP, $cred, $hostnames);
	Write_ip_to_file(LASTIPFILE, $currentIP);
}
else {
	say "IP adress has not changed. Nothing for me to do except die";
}

exit;
