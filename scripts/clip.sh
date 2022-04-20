#!/bin/bash

#
# This script is actually a function that you should add to your bashrc file in order
# to cat a file into your clipboard.
# You can either source this file or copy the function to your bashrc file.
#


clip() {
	cat $1 | xclip -i -selection clipboard
}
