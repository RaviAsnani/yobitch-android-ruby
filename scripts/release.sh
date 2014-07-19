#!/bin/bash

echo "Releaseing..."
echo "Please run this from project root or heavens might fall!!!"

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