#!/bin/bash
whois "$1" | grep -E "^(Registrant|Admin|Tech)" | sed 's/: */,/' > "$1.csv"

