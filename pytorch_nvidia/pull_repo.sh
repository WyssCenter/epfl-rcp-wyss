# copy ssh key to clone private repositories
if [ -z "$SSH_PRIVATE_KEY" ]; then
  echo "SSH_PRIVATE_KEY is not set. Not pulling anything."
else
  if [ -f /home/$USER/.ssh/id_rsa ]; then
    echo "SSH key already exists."
  else
    echo "$SSH_PRIVATE_KEY" >/home/$USER/.ssh/id_rsa && chmod 600 /home/$USER/.ssh/id_rsa
  fi
fi

# clone repositories if they don't exist
if ! [ -d "/home/$USER/code/wyss_ds" ] && [ -f /home/$USER/.ssh/id_rsa ]; then
  cd /home/$USER/code
  # set default branches
  if [ -z "$GIT_BRANCH_SYN_DECODER" ]; then
    GIT_BRANCH_SYN_DECODER="dev"
  fi
  if [ -z "$GIT_BRANCH_WYSS_DS" ]; then
    GIT_BRANCH_WYSS_DS="dev"
  fi
  # clone repositories
  git clone -b "$GIT_BRANCH_WYSS_DS" git@github.com:WyssCenter/wyss_ds.git
  git clone -b "$GIT_BRANCH_SYN_DECODER" git@github.com:WyssCenter/syn_decoder.git

  # export python path
  echo "Export python path"
  export PYTHONPATH="/home/$USER/code/wyss_ds:$PYTHONPATH"
  export PYTHONPATH="/home/$USER/code/syn_decoder:$PYTHONPATH"
fi
