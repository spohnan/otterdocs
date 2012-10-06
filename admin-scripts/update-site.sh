#!/bin/bash
#
# update-site.sh - Deploy files in project site/ directory to web site
#
# A convenience script to automate deployment of the project web site
#

declare -r SCRIPT=${0##*/}                  # Name of this script
declare -r rsync=$(which rsync)             # Command that will actually do all the file management

# Test to see if rsync command is present
if test ! -x "$rsync" ; then
    echo "$SCRIPT:$LINENO: The rsync command is not available on this client - aborting"
    exit -1
fi

# Full path to the location of this script within the file system
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set the current working directory of this script to the root of the project
cd $SCRIPT_DIR/..

# Transfer the files within the site/ directory of this project to the web site.
# For this to work you'll need your .ssh/config set up for host otterdocs and public
# key authentication configured. This command reads and will skip files matching entries
# in the project .gitignore file
$rsync -avrt --exclude-from .gitignore -e ssh site/* otterdocs:/var/www/otterdocs.com/
