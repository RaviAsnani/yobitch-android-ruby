#!/bin/bash

echo "Releasing..."
echo "Please run this from project root or heavens might fall!!!"

echo "Tagging the repository & pushing the tag to Production"
tag_name=$(date +"%S-%M-%H-%d-%m-%Y")
now=$(date)
who=$(whoami)
machine=$(hostname)
git tag `echo $tag_name` -m "Production candidate created at $now by $who on $machine"
git push origin $tag_name

echo "Copying jRuby runtime into project scope : /libs"
cp ./tmp/*.jar ./libs

echo "Running ant release => Ensure passwords are entered"
ant release

echo "Running jarsigner -verrify -certs on the release APK"
jarsigner -verify -certs ./bin/Yobitch-release.apk 

echo "Cleaning up /libs"
rm -f libs/dx.jar
rm -f libs/jruby-core-1.7.13.jar
rm -f libs/jruby-stdlib-1.7.13.jar