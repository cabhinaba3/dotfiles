#!/bin/bash
cd "$(dirname "$0")"
/home/cohitherewer/Desktop/dotfiles/.venv/bin/python paper_finder.py >> paper_finder.log 2>&1
