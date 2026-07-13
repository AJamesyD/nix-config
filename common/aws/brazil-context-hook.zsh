_brazil_context_hook() {
  local dir=$PWD
  while [[ $dir != / ]]; do
    if [[ -f "$dir/packageInfo" ]]; then
      export _BRAZIL_WS=${dir:t}
      _BRAZIL_PKG=
      _BRAZIL_PKG_VER=
      local d=$PWD
      while [[ $d != "$dir" && $d != / ]]; do
        if [[ -f "$d/Config" ]]; then
          export _BRAZIL_PKG=${d:t}
          # Config format: interfaces ( VERSION ); -- extract VERSION without forking
          local _cfg_line=${(M)${(f)"$(<$d/Config)"}:#*interfaces*}
          export _BRAZIL_PKG_VER=${${${_cfg_line##*\(}%%[;\)]*}// /}
          break
        fi
        d=${d:h}
      done
      export _BRAZIL_PKG _BRAZIL_PKG_VER
      return
    fi
    dir=${dir:h}
  done
  unset _BRAZIL_WS _BRAZIL_PKG _BRAZIL_PKG_VER
}
add-zsh-hook chpwd _brazil_context_hook
_brazil_context_hook
