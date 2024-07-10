#!/bin/bash
echo "Start Jupyter Notebook"

if [ -z "$JUPYTER_PORT" ]; then
    echo "JUPYTER_PORT is not set. Using 8889 by default."
    JUPYTER_PORT=8889
fi

# copy ssh key to clone private repositories
echo "Copy ssh key + clone private repositories"
source /home/$USER/pull_repo.sh

# activate virtual environment
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
echo "Run jupyter"
jupyter notebook --no-browser --port=$JUPYTER_PORT --ip=0.0.0.0
echo "End job"
