#!/usr/bin/env bash

if [ -e $HOME/.emacs ] ; then
    rm $HOME/.emacs
fi

if [ -e .emacs ] ; then
    ln -s "$(realpath .emacs)" $HOME/.emacs
fi

