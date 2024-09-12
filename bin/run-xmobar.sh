#!/bin/bash

flavour=$1
shift

$(cd ~/usr/jao/xmobar-config && cabal list-bin xmobar-$flavour) $*
