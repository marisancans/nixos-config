#!/usr/bin/env bash

cd /home/ma/flake/scripts
python3 scrape_ergopy.py https://configure.zsa.io/ergodox-ez/layouts/GlwEG/latest/0
mv layout.png /home/ma/flake/images
