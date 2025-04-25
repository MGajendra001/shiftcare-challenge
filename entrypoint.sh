#!/bin/bash
set -e

# Check the first argument to decide what to run
case "$1" in
  rspec)
    exec ruby -e "require 'rspec/autorun'" spec
    ;;
  *)
    # Default to running app.rb with all arguments
    exec ruby app.rb "$@"
    ;;
esac