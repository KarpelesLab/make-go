# Makefile for Go projects

Just a makefile I often use for Go projects, feel free to use it.

# Install?

wget -O Makefile https://raw.githubusercontent.com/KarpelesLab/make-go/master/Makefile

# Update?

make update-make

# Download service

	curl -s https://raw.githubusercontent.com/KarpelesLab/make-go/master/get.sh | /bin/sh -s name

## Install on systemd machines

	curl -s https://raw.githubusercontent.com/KarpelesLab/make-go/master/systemd.sh | /bin/sh -s name
