#!/bin/bash

# BUILD SCRIPT
# Requires the following env variables:
#
# For: xananax.itch.io/testing-many-uploads
# 
# ITCHIO_USERNAME="xananax"
# ITCHIO_GAME="testing-many-uploads"
# 
# And, found on https://itch.io/user/settings/api-keys
# BUTLER_API_KEY=""

function check_requirements() {
  
  command -v zip >/dev/null 2>&1 || { echo >&2      "'zip' is required"; exit 1; }
  command -v envsubst >/dev/null 2>&1 || { echo >&2 "'envsubst' is required"; exit 1; }
  command -v awk >/dev/null 2>&1 || { echo >&2      "'awk' is required"; exit 1; }
  command -v butler >/dev/null 2>&1 || { echo >&2   "'butler' is required"; exit 1; }

  #[ -n "$ITCHIO_USERNAME" ] || { echo >&2 "\$ITCHIO_USERNAME is not set" ; exit 1; }
  #[ -n "$ITCHIO_GAME" ] || { echo >&2     "\$ITCHIO_GAME is not set" ; exit 1; }
  #[ -n "$BUTLER_API_KEY" ] || { echo >&2  "\$BUTLER_API_KEY is not set" ; exit 1; }

  mkdir -p "$BUILD_DIR" || { echo >&2     "Could not create destination directory $BUILD_DIR"; exit 1; }
  mkdir -p "$ARTIFACTS_DIR" || { echo >&2 "Could not create destination directory $ARTIFACTS_DIR"; exit 1; }
}

function process() {
  project_file="$0"
  project_name=$(awk -F "=" '/config\/name=/ {print $2}' "$project_file" | tr -d '"')
  dir=$(dirname "$project_file")
  base=$(basename "$dir")
  filename="$base.$DATE.$GIT_BRANCH.$GIT_HASH.zip"
  artifact="$ARTIFACTS_DIR/$filename"

  # Zip file
  cd "$ROOT" && zip "$artifact" -r "$base" -x "$base/.import/*" "$base/.git/*"

  # push to itch
 # butler push "$artifact" "$ITCHIO_USERNAME/$ITCHIO_GAME:$base" --userversion "$DATE.$GIT_HASH"

  # Generate HTML
  classes="project"
  export project_name
  export filename
  export base
  export classes
  envsubst < "$HTML_TEMPLATE" > "$BUILD_DIR/$base.html"

  echo "<a href=\"$base.html\">$project_name</a>" >> "$TEMP_FILE"
}

# these variables are used in several places, and changing them will probably break things
# specifically, the link to files in the html template, and the pages location in the gh-pages CI
DATE=$(date '+%Y-%m-%d-%H-%M-%S')
git_diff=$(git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*")
GIT_BRANCH=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$git_diff/" | tr -d '*')
GIT_HASH=$(git rev-parse --short HEAD 2> /dev/null)
ROOT=$(dirname "$(readlink -f $0)")
BUILD_DIR="$ROOT/build"
ARTIFACTS_DIR="$BUILD_DIR/artifacts"
HTML_TEMPLATE="$ROOT/template.html"
TEMP_FILE=$(mktemp)

check_requirements

export -f process
export BUILD_DIR
export ARTIFACTS_DIR
export ROOT
export HTML_TEMPLATE
export ITCHIO_USERNAME
export BUTLER_API_KEY
export ITCHIO_GAME
export DATE
export GIT_BRANCH
export GIT_HASH
export TEMP_FILE


# Process files and create zips
find "$ROOT" -name "project.godot"  -exec bash -c 'process "$0"' {} \;

# create main index file
content=$(cat "$TEMP_FILE")
project_name="Demos"
classes="main"
export content
export project_name
envsubst < "$HTML_TEMPLATE" > "$BUILD_DIR/index.html"