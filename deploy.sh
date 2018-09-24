#!/usr/bin/env sh

# abort on errors
set -e

# download csv
wget  -O src/assets/kills.csv "https://docs.google.com/spreadsheets/d/e/2PACX-1vTDxJGOFkuicgN3DF5JxyuvUW10c50M_WdySnxzMZ8KIW7NukGt8TfiSOqxz7knrbZY41UQzYB-7kwY/pub?gid=0&single=true&output=csv"
wget  -O src/assets/stats.csv "https://docs.google.com/spreadsheets/d/e/2PACX-1vTDxJGOFkuicgN3DF5JxyuvUW10c50M_WdySnxzMZ8KIW7NukGt8TfiSOqxz7knrbZY41UQzYB-7kwY/pub?gid=1745963979&single=true&output=csv"

# build
npm run build

# rename dist dir
mv dist docs

# Sends to Github
git ac -m "Updates"

git push origin master