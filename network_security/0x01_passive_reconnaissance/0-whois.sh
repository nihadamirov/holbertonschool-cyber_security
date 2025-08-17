#!/bin/bash
whois $1 | awk '/^[ ]*Registrant|^[ ]*Admin|^[ ]*Tech/ && !/Registry/ {gsub(/: /, ","); print}' > $1.csv
