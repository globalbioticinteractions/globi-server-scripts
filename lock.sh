# from http://wiki.bash-hackers.org/howto/mutex
LOCK_DIR=~/indexing.lock
function acquire_lock {
  if mkdir $LOCK_DIR; then
    echo "Locking succeeded for [$LOCK_DIR]" >&2
  else
    echo "Lock failed for [$LOCK_DIR] - exit" >&2
    exit 1
  fi
}

function release_lock {
  echo "Releasing lock [$LOCK_DIR]"
  rmdir $LOCK_DIR
}
