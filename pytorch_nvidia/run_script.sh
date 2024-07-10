#!/bin/bash
#
# This script is used to run a python script in runai.
# It:
# - clones private repositories
# - activates a virtual environment
# - installs extra dependencies if any
# - runs the script passed as an argument
#
# Author: Etienne de Montalivet
#
echo "Start job"

# clone private repositories (needs ssh key secret)
echo "Copy ssh key + clone private repositories + export PYTHONPATH"
source /home/$USER/pull_repo.sh

# activate virtual environment (in this case, the venv has been built in the Dockerfile)
echo "Activate virtual environment"
source /home/$USER/code/.venv/bin/activate

# install extra dependencies if any
if [ -z "$EXTRA_DEPS" ]; then
    echo "No EXTRA_DEPS to install."
else
    echo "Install EXTRA_DEPS"
    pip install $EXTRA_DEPS
fi

# run script
echo "Run script"
python3 "/home/$USER/code/syn_decoder/$SCRIPT_PATH"
echo "End job"
