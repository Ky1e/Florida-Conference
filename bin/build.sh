#!/bin/bash

#
# Build script
#
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow
txtblu=$(tput setaf 4) # Blue
txtpur=$(tput setaf 5) # Purple
txtcyn=$(tput setaf 6) # Cyan
txtwht=$(tput setaf 7) # White
txtrst=$(tput sgr0) # Text reset.

EXE=grunt

FOUND=`which $EXE`
if [ ! -x "$FOUND" ]
then
	echo ${txtred}Error: executable grunt not found on path ${txtrst}
	exit 1
fi

# Look for Gruntfile.js occurrences NOT in node_modules
echo -e "\n${txtylw}Looking for Gruntfile.js occurrences NOT in node_modules.. ${txtrst}"
FILE=Gruntfile.*js
for d in `find . \( -name node_modules -or -name components \) -prune -o -name "$FILE" | grep "$FILE"`
do
	# Change into containing directory
	echo -e "\n${txtylw}Gruntfile found, changing directories into: ${d%/*} ${txtrst}"
	cd ${d%/*}

	# ~/node_modules is cached on Circles CI
	CURRENT_DIR=${PWD##*/}
	echo -e "\n${txtylw}Moving $HOME/node_modules/$CURRENT_DIR to node_modules${txtrst}"
	mkdir -p $HOME/node_modules/$CURRENT_DIR
	mv $HOME/node_modules/$CURRENT_DIR ./node_modules

	# Install any dependencies, if we find packages.json
	[ -f 'package.json' ] && echo -e "\n${txtylw}package.json found, running 'npm install' ${txtrst}"
	[ -f 'package.json' ] && npm install

	# Run Grunt
	echo -e "\n${txtylw}Running 'Grunt' ${txtrst}"
	$FOUND

	echo -e "\n${txtylw}Moving node_modules back to $HOME/node_modules/$CURRENT_DIR to cache it for next time${txtrst}"
	mv ./node_modules $HOME/node_modules/$CURRENT_DIR

	# Change back again
	echo -e "\n${txtylw}changed directories back into: ${txtrst}"
	cd -
done