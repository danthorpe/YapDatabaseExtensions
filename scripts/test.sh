#!/usr/bin/env bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby ruby
echo ''gem: --no-ri --no-rdoc'' > ~/.gemrc
bundle install
rake xcode:test:go
