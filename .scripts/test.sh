#!/usr/bin/env bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby ruby

xcodebuild -workspace framework/YapDatabaseExtensions.xcworkspace -scheme YapDatabaseExtensions test | xcpretty -c && exit ${PIPESTATUS[0]}
