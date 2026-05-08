# PERF: compinit is expensive (~1.4s with ~3000 completions).
# Full compinit once per day; -C (cached, skip security check) otherwise.
autoload -U compinit
() {
  setopt local_options extendedglob
  if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi
}
# Background-compile the dump for faster future loads
{
  if [[ -s "${ZDOTDIR}/.zcompdump" && (! -s "${ZDOTDIR}/.zcompdump.zwc" || "${ZDOTDIR}/.zcompdump" -nt "${ZDOTDIR}/.zcompdump.zwc") ]]; then
    zcompile "${ZDOTDIR}/.zcompdump"
  fi
} &!
