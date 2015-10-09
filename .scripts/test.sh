#!/usr/bin/env bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby ruby
bundle update && bundle exec fastlane test
bash <(curl -s https://codecov.io/bash) -f .fastlane/xcodebuild-data/Build/Intermediates/CodeCoverage/YapDatabaseExtensions/Coverage.profdata