#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

parse_git_branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ [\1]/'
}

PROMPT_COMMAND='printf "\e[01;30m[%03.0f] " "$?"'

PS1='\[\033[01;32m\]\u\[\033[0m\]@\[\033[01;31m\]\h\[\033[0m\]:\[\033[01;33m\]\w\[\033[1;30m\]$(parse_git_branch)\n\[\033[0m\]$ '

PATH="$PATH:/home/dirk/.gem/ruby/2.4.0/bin"

export VISUAL=vi
export EDITOR=vi
export JAVA_HOME="/usr/lib/jvm/default"
export WINEARCH=win32

eval $(keychain --eval --quiet --agents ssh id_rsa)

# ALIASES

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias l='ls -alih --color=auto'
alias o='xdg-open'
alias upd='sudo pacman -Syu'
alias upg='pacaur -Syyu --aur'
# alias upg='pacaur -u --aur'
alias ins='sudo pacman -S'
alias rem='sudo pacman -Rsn'
alias comt='tar -cjvf'
alias comz='zip -r -9'
alias coms='zip -r -0'
alias bashr='source ~/.bashrc'
alias mcd='multiple_change_directory'
alias devices='sudo fdisk -l'
alias diskusage='sudo du -hsx * | sort -rh | head -10'
alias openconn='sudo netstat -tupan'
alias aliases='grep ^alias ~/.bashrc'
alias youtubedl='youtube-dl -x -c --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s"'
alias ethupmac='sudo macchanger -r enp0s25 && sudo dhcpcd enp0s25'
alias ethup='sudo dhcpcd enp0s25'
alias ethdown='sudo killall dhcpcd && sudo macchanger -p enp0s25 && sudo ip addr flush dev enp0s25 && ip link set enp0s25 down'
alias weather='curl wttr.in/berlin'
alias bananapisermonit='ssh -vL 8000:localhost:8000 bananapilocal'
alias bananapibackupsync='rsync -avz --progress -e ssh bananapi:/root/backup/ /home/dirk/Backups/'
alias bananapizuendstoff='ssh -vL 9000:localhost:9000 bananapilocal'
alias odroidmusicmixsync='rsync -avz --delete --progress -e ssh /home/dirk/Music/Mix/ odroid:/home/alarm/Music/Music2/Mix/'
alias odroidmusicdiversesync='rsync -avz --delete --progress -e ssh /home/dirk/Music/Diverse/ odroid:/home/alarm/Music/Music2/Diverse/'
alias odroidmusicdrumnbasssync='rsync -avz --delete --progress -e ssh /home/dirk/Music/DrumNBass/ odroid:/home/alarm/Music/Music2/DrumNBass/'
alias odroidmusicoldiessync='rsync -avz --delete --progress -e ssh /home/dirk/Music/Oldies/ odroid:/home/alarm/Music/Music2/Oldies/'
alias odroidvncserver='ssh -t -L 5900:localhost:5900 odroid "x11vnc -display :0 -auth /home/odroid/.Xauthority"'
alias odroidvncclient='gvncviewer localhost'
alias odroidmount='sshfs odroid:/home/alarm /mnt/odroid -o follow_symlinks'
alias odroidumount='fusermount3 -u /mnt/odroid'
alias raspberrypimusicmixsync='rsync -avz --delete --progress -e ssh /home/dirk/Music/Mix/ raspberrypi:/home/alarm/Music/'
alias publicip='printf "$(curl -s http://ipecho.net/plain)\n"'
alias pinggoogle='ping 8.8.8.8'
alias hcat='highlight -O ansi'
alias cpr='rsync -ahz --progress'
alias streamffserver='ffserver -f $HOME/.config/ffserver.conf'
alias streamffmpeg='ffmpeg -f pulse -i default http://127.0.0.1:9001/feed.ffm'
alias onetimefullload='sudo tlp fullcharge BAT0'
alias srm='sudo rm'
alias ct='ctags --fields=+KSn -R .'
alias permissionsdir='find . -type d -print0 | xargs -0 chmod 755'
alias permissionsfile='find . -type f -print0 | xargs -0 chmod 644'
alias gits='git status'
alias gitc='git commit -m'
alias gita='git add .'
alias gitl='git pull'
alias gith='git push'
alias gitd='git diff HEAD'

# FUNCTIONS

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

copyisotodrive()
{
    if [ $# -ne 2 ]; then
        printf "Usage: copyisotodrive [ISO] [DRIVE]\\n"
    else
        if [ -f "$1" ] && [ -b "$2" ]; then
            sudo dd if="$1" of="$2" status=progress && sync
        else
            printf "Either the given file doesn't exist or the drive is not available.\\n"
        fi
    fi
}

runusbquemu()
{
    if [ $# -ne 1 ]; then
        printf "Usage: runusbqemu [USB]\\n"
    else
        if [ -b "$1" ]; then
            sudo qemu-system-x86_64 -m 4096 -enable-kvm -hda "$1"
        else
            printf "The given usb drive was not found.\n"
        fi
    fi
}

# manpage wrapper with less
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

startappnohup()
{
    if [ $# -lt 1 ]; then
        echo "Usage: startappnohup [APPLICATION] [PARAMETERS]"
    else
        if hash "$1" > /dev/null 2>&1; then
            DATEFORMAT=$(date +%Y-%m-%d-%H-%m-%S-%N)
            LOGFILE="/tmp/$1-$DATEFORMAT.log"
            nohup "$1" "$2" > "$LOGFILE" 2>&1 &
            echo "The application '$1' started with logfile '$LOGFILE'."
        else
            echo "The given application '$1' doesn't exists."
        fi
    fi
}

zuendstoffbook()
{
    if [ $# -lt 1 ]; then
        echo "Usage: zuendstoffbook [PDF]"
    else
        scp "$1" bananapilocal:/usr/share/zuendstoff/books
    fi
}
