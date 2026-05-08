WORDCHARS=${WORDCHARS//[\/.]}
REPORTTIME=10

# Beloved key-binds
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word

bindkey "^[[1;9D" beginning-of-line
bindkey "^[[1;9C" end-of-line

bindkey "^[[3;9~" kill-line

bindkey "^[[3;3~" kill-word
