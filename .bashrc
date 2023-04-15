
export arch=$(uname -m)
export host=$(uname -n)

export LC_ALL=C

source $HOME/.bash-git
source $HOME/.bash-prompt
source $HOME/.bash_generic
source $HOME/.bourne-apparix
source $HOME/.bash-workutils

export PATH=$HOME/local/bin:$HOME/bin:${PATH}
export PATH=$HOME/dev/bin:${PATH}

shopt -s direxpand

