#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -d "$HOME" ]] && cd "$HOME"

parse_git_branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

PROMPT_COMMAND='printf "\e[01;30m[%03.0f] " "$?"'

PS1='\[\033[01;32m\]\u\[\033[0m\]@\[\033[01;31m\]\h\[\033[0m\]:\[\033[01;33m\]\w\[\033[1;30m\]$(parse_git_branch)\n\[\033[0m\]$ '

export VISUAL=vi
export EDITOR=vi

# ALIASES

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias l='ls -alih --color=auto'
alias comt='tar -cjvf'
alias comz='zip -r -9'
alias coms='zip -r -0'
alias bashr='source ~/.bashrc'
alias mcd='multiple_change_directory'
alias aliases='grep ^alias ~/.bashrc'
alias weather='curl wttr.in/berlin'
alias publicip='printf "$(curl -s http://ipecho.net/plain)\n"'
alias pinggoogle='ping 8.8.8.8'
alias hcat='highlight -O ansi'
alias cpr='rsync -ahz --progress'
alias permissionsdir='find . -type d -print0 | xargs -0 chmod 755'
alias permissionsfile='find . -type f -print0 | xargs -0 chmod 644'
alias gits='git status'
alias gitc='git commit -m'
alias gita='git add .'
alias gitl='git pull'
alias gith='git push'
alias gitd='git diff HEAD'
alias youtubedl='youtube-dl -x -c --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s"'

# FUNCTIONS

dottopng()
{
    if [ $# -ne 1 ]; then
        echo "Usage: dottopng [FILE]"
    else
        if [ ! -f "$1" ]; then
            echo "The given file '$1' was not found."
        else
            local basename="${1%.*}"
            dot -T png "$1" -o "${basename}.png"
        fi
    fi
}

multiple_change_directory()
{
    C=0
    while [ $C -lt $1 ]; do
        cd ..
        C=$((C+1))
    done
}

grepall()
{
    if [ $# -ne 1 ]; then
        echo "Usage: grepall [TERM]"
    else
        grep -ri "$1"
    fi
}

findall()
{
    if [ $# -ne 1 ]; then
        echo "Usage: findall [TERM]"
    else
        find "$(pwd)" -iname "*$1*"
    fi
}

catall()
{
    if [ $# -ne 1 ]; then
        echo "Usage: catall [TERM]"
    else
        find "$(pwd)" -type f -iname "*$1*" | \
            while read -r filename; do 
                awk -v name="$(basename "$filename")" \
                    'NR==1 { printf "%-30s %s\n", name, $0 } NR>1 { printf "%-30s %s\n", "", $0 }' \
                    "$filename"
            done
    fi
}

man()
{
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}
