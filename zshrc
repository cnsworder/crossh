if which vim > /dev/null; then
    export EDITOR=vim
fi
# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update
fi

export ZSH=$HOME/.zplug/repos/robbyrussell/oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Essential
source ~/.zplug/init.zsh

clear
echo -n "Loading plugins..."

# Make sure to use double quotes to prevent shell expansion
zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
# zplug "djui/alias-tips"
# zplug "willghatch/zsh-snippets"
zplug "supercrabtree/k"
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
# zplug "plugins/zsh_reload", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
# zplug "plugins/autojump", from:oh-my-zsh
zplug "themes/ys", as:theme, from:oh-my-zsh

zplug "plugins/brew", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/cask", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/osx", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

zplug "plugins/linux", from:oh-my-zsh, if:"[[ $OSTYPE == *linux* ]]"

if which fzf > /dev/null; then
    zplug "/usr/local/opt/fzf/shell", from:local, if:"[[ $OSTYPE == *darwin* ]]"
    zplug "/usr/share/fzf", from:local, if:"[[ $OSTYPE == *linux* ]]"
    zplug "urbainvaes/fzf-marks"
else
    zplug "jocelynmallon/zshmarks"
fi
if [ -d ~/dev/tools ]; then
    zplug "~/dev/tools", from:local, use:"*.sh"
fi

# Add a bunch more of your favorite packages!

# Install packages that have not been installed yet
function check() {
    echo -n "\nplug check..."
    if ! zplug check; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        else
            echo
        fi
    fi
    touch ~/.zplug/.installed
}

if [ ! -e ~/.zplug/.installed ]; then
    check
fi

echo -n "\nzplug loaded..."
zplug load

echo -n "\ninit python env..."
# pyenv
export PYENV_ROOT=$HOME/.pyenv
eval "$(pyenv init -)"

# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

reset
echo  " \e[92m
\t ##########################
\t #                        #
\t #   ┌─┐┬─┐┌─┐┌─┐┌─┐┬ ┬   #
\t #   │  ├┬┘│ │└─┐└─┐├─┤   #
\t #   └─┘┴└─└─┘└─┘└─┘┴ ┴   #
\t #                        #
\t ##########################
\e[0m"

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(direnv hook zsh)"
# eval "$(aliases init --global)"
# bindkey '^j' snippet-expand

function linuxup() {
    if which dnf > /dev/null; then
        echo ">> dnf update application..."
        dnf -y update &> ~/allup.log
        return
    fi
    if which yum > /dev/null; then
        echo ">> yum update application..."
        yum -y update &> ~/allup.log
        return
    fi
    if which pacman > /dev/null; then
        echo ">> pacman update application..."
        yes | pacman -Syu &> ~/allup.log
        return
    fi
    if which aptitude > /dev/null; then
        echo ">> apt update application..."
        yes | aptitude update | aptitude upgrade &> ~/allup.log
        return
    fi
}

function macup() {
    if which brew > /dev/null; then
        echo ">> brew update application..."
        yes | brew upgrade &> ~/allup.log
        brew cleanup &>> ~/.aliasesallup.log
    fi
}

function zshup() {
    echo ">> zplug update zsh..."
    zplug update &>> ~/allup.log
    zplug clear &>> ~/allup.log
}

function emacsup() {
    if which cask; then
        echo ">> cask update emacs..."
        if [ -d ~/.emacs.d ]; then
            cd ~/.emacs.d
            cask upgrade &>> ~/allup.log
            cask update &>> ~/allup.log
            cd - > /dev/null
        fi
    fi
}

function vimup() {
    if which vim > /dev/null; then
        echo ">> vimplug update vim..."
        vim +PlugUpdate\ --sync +PlugUpgrade\ --sync +PlugClean\ --sync +qall
        clear
    fi
}

function echolog() {
    cat ~/allup.log
    echo
}

function allup() {
    clear
    linuxup
    macup
    zshup
    emacsup
    vimup
    echoup

    echo "[[ All plugin Upgraded! ]]"
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
