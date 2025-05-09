# ~/.dotfiles/modules/_log.fish
#
#  Log function for fish
function log
  echo -e "$argv"
end

#  Fatal error handler for fish
function fatal
  log "❌ $argv"
  exit 1
end
