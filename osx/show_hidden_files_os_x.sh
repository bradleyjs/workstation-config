#! /usr/bin/env bash

# Updates OS X default settings to show all hidden files by default in the
# Finder. This can be turned off via keystroke with `Cmd-Shift-.` (the
# period character).

defaults write com.apple.Finder AppleShowAllFiles true && killall Finder
