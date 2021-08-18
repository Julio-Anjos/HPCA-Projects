#!/bin/bash

# Abort on error
set -e
set -o pipefail

# read vars
origin="$(pwd)"
samtools_folder_path="$(pwd)/../../samtools"
samtools="$(pwd)/../../samtools/samtools"
run="$1"

# check what to do
case $run in
  "all")
  echo "Unimplemented."
  exit 1
  ;;

  "view")
    echo "Expected input: ./run_profile.sh view cram ref"
    f_input="view_input"
    f_validate="view_validate"
    f_build="samtools_build"
    f_setup="common_setup"
    f_profile="view_profile"
  ;;

  "index" )
    echo "Expected input: ./run_profile.sh index bam"
    f_input="index_input"
    f_validate="index_validate"
    f_build="samtools_build"
    f_setup="common_setup"
    f_profile="index_profile"
  ;;

  *)
  echo "Unimplemented."
  exit 1
  ;;
esac

#
# Common
#

function samtools_build {
  cd "$samtools_folder_path"
  git --no-pager log --pretty=oneline --max-count=1
  git stash
  make clean
  make -j6
}

function common_setup {
  # env setup
  cd "$origin"
  profile_path="$(pwd)/$1_$(date +'%d_%m_%y_%H%M%S')"
  mkdir $profile_path
  cd $profile_path
}

#
# View
#

function view_input {
  cram="$2"
  ref="$3"
}

function view_validate {
  ls -d "$samtools_folder_path"
  test -n "$cram"
  test -n "$ref"
  ls -l "$cram"
  ls -l "$ref"
}

function view_profile {
  # total time profiling
  time_start=$(date +%s%3N)
  "$samtools" view -b -T "$ref" "$cram" >out.bam
  time_end=$(date +%s%3N)
  echo "total_time_ms=$((time_end - time_start))"
}

#
# Index
#

function index_input {
  bam="$2"
}

function index_validate {
  ls -d "$samtools_folder_path"
  test -n "$bam"
  ls -l "$bam"
}

function index_profile {
  time_start=$(date +%s%3N)
  "$samtools" index "$bam" 
  time_end=$(date +%s%3N)
  echo "total_time_ms=$((time_end - time_start))"
}

echo "Get input..."
$f_input "$@"
echo "Validate input..."
$f_validate
echo "Build samtools..."
$f_build
echo "Setup run env..."
$f_setup "$1"
echo "Profiling... It is $(date)"
$f_profile
echo "Done... It is $(date)" 


