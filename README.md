kleptoken
=========

Leverage XSS to steal session cookies, hook targets to beef and redirect
URL's

Installation:
=======

Run 'make install' in the kleptoken directory. kleptoken can now be run 
from anywhere with 'kleptoken'.

Usage:
=======

	Usage: kleptoken <options>

			-r <URL>  ~  Redirect/Iframe to URL (default ha.ckers.org)
			-o        ~  Just display obfuscated IP address and exit
			-l        ~  Use local IP address for payload (default)
			-e     	  ~  Use external IP address for payload
			-d <DDNS> ~  Use DDNS for payload
