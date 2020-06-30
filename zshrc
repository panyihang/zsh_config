export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git autojump)
source $ZSH/oh-my-zsh.sh

# powerline
powerline-daemon -q
. /usr/lib/python3.8/site-packages/powerline/bindings/zsh/powerline.zsh


#color
autoload colors
colors

for color in RED GREEN YELLOW ORANGE MAGENTA CYAN WHITE; do
eval _$color='%{$terminfo[bold]$fg[${(L)color}]%}'
eval $color='%{$fg[${(L)color}]%}'
(( count = $count + 1 ))
done
FINISH="%{$terminfo[sgr0]%}"


#命令提示符
#RPROMPT=$(echo "$WHITE%D %T$FINISH")
#PROMPT=$(echo "$RED%D %T$FINISH $CYAN%n:$GREEN%/$_YELLOW>$FINISH ")
#PROMPT=$(echo "$CYAN%D %T$FINISH $GREEN%/$_YELLOW>$FINISH")


#标题栏、任务栏样式{{{
case $TERM in (*xterm*|*rxvt*|(dt|k|E)term)
precmd () { print -Pn "\e]0;%n@%M//%/\a" }
preexec () { print -Pn "\e]0;%n@%M//%/\ $1\a" }
;;
esac



#历史纪录条目数量
export HISTSIZE=10000

#注销后保存的历史纪录条目数量
export SAVEHIST=10000

#历史纪录文件
export HISTFILE=~/.zsh_history

#以附加的方式写入历史纪录
setopt INC_APPEND_HISTORY

#如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS

#为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY

#启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD

#相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS

#在命令前添加空格，不将此命令添加到纪录文件中
setopt HIST_IGNORE_SPACE

# 补全
#彩色补全菜单
if [ -x /usr/bin/dircolors ]; then
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi
export ZLSCOLORS="${LS_COLORS}"
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

#修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
#错误校正
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

#kill 命令补全
compdef pkill=kill
compdef pkill=killall
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:processes' command 'ps -au$USER'

#补全类型提示分组
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format $'\e[01;33m -- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[01;35m -- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;32m -- %d (errors: %e) --\e[0m'

# cd ~ 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'


#行编辑高亮模式
# Ctrl+@ 设置标记，标记和光标点之间为 region
zle_highlight=(region:bg=magenta #选中区域
special:bold      #特殊字符
isearch:underline)#搜索时使用的关键字


#空行(光标在行首)补全 "cd " 
user-complete(){
case $BUFFER in
"" )                       

# 空行填入 "cd "
BUFFER="cd "
zle end-of-line
zle expand-or-complete
;;
"cd --" )                  

# "cd --" 替换为 "cd +"
BUFFER="cd +"
zle end-of-line
zle expand-or-complete
;;
"cd +-" )                  

# "cd +-" 替换为 "cd -"
BUFFER="cd -"
zle end-of-line
zle expand-or-complete
;;
* )
zle expand-or-complete
;;
esac
}
zle -N user-complete
bindkey "\t" user-complete



#别名 
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ls='ls -F --color=auto'
alias ll='ls -l --color=auto'
alias grep='grep --color=auto'
alias la='ls -a'
alias pacman='pacman --color=auto'
alias yay='yay --color=auto'
alias c="clear"
alias wj="dolphin"
alias gc="git clone"
alias py="python"


#命令高亮
setopt extended_glob
TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')


recolor-cmd() {
region_highlight=()
colorize=true
start_pos=0
for arg in ${(z)BUFFER}; do
((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))
((end_pos=$start_pos+${#arg}))
if $colorize; then
colorize=false
res=$(LC_ALL=C builtin type $arg 2>/dev/null)
case $res in
*'reserved word'*)   style="fg=magenta,bold";;
*'alias for'*)       style="fg=cyan,bold";;
*'shell builtin'*)   style="fg=yellow,bold";;
*'shell function'*)  style='fg=green,bold';;
*"$arg is"*)
[[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=cyan,bold";;
*)                   style='none,bold';;
esac
region_highlight+=("$start_pos $end_pos $style")
fi
[[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true
start_pos=$end_pos
done
}
check-cmd-self-insert() { zle .self-insert && recolor-cmd }
check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }

zle -N self-insert check-cmd-self-insert
zle -N backward-delete-char check-cmd-backward-delete-char

#进shell自动更新
#sudo pacman -Syu

#thefuck
eval $(thefuck --alias)

#取消内存历史记录
set +H

#支持通配符
setopt nonomatch

#关联ls颜色文件
if [ -x /usr/bin/dircolors ]; then
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
fi
