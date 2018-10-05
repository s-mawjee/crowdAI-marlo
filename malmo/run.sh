#!/bin/sh

xpra start :100
export DISPLAY=:100
eval $*