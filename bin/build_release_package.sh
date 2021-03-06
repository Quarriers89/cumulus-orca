#!/bin/sh
#TODO This needs to be better organized
set -ex

if [[ ! $bamboo_RELEASE_FLAG == true ]]; then
  >&2 echo "******Skipping build_release_package step as bamboo_PUBLISH_FLAG is not set"
  exit 0
fi

# Create the lambda zips
./bin/build_tasks.sh

# Clean up working directory and create a new build directory
rm -rf build
mkdir build
mkdir build/tasks

cp -r database build
cp -r modules build
cp *.tf build
cp README.md build
cp LICENSE.txt build
cp terraform.tfvars.example build

# Crawl through the zip files
for package in $(find . -name *.zip);
do
  filename=$(basename $package)
  base="${filename%.*}"
  destination="build/tasks/$base/"
  mkdir $destination
  cp -p $package $destination
done 

# create distribution package directory
mkdir dist

# Enter the build directory so the files that are zipped exist at the root level
cd build
zip -r "../dist/cumulus-orca-terraform.zip" .
cd ..

# Create the GitHub release
./bin/create_release.sh
