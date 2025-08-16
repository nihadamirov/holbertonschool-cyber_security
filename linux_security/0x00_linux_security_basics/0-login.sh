#!/bin/bash
# Purpose: Show the last 5 login sessions with date & time

if [[ $EUID -ne 0 ]]; then 
	echo "You can only run this script as root or with sudo."
	exit 1
fi

last -5
