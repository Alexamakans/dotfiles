#!/usr/bin/env sh

pushd ~/dotfiles
nix flake update
echo "$(alias ns)"
ns
