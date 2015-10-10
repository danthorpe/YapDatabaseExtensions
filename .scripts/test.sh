#!/usr/bin/env bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby ruby
bundle update && bundle exec fastlane test
#.scripts/codecov.bash
bash <(curl -s https://raw.githubusercontent.com/codecov/codecov-bash/master/codecov) -D .fastlane/xcodebuild-data
