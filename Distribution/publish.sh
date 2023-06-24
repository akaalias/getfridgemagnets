#!/usr/bin/env zsh

set -e

export APPNAME="FridgeMagnets"
export APPBUNDLE="$APPNAME.app"

if [ -d $APPBUNDLE ] 
then
    echo "SUCCESS: $APPBUNDLE exists!" 
else
    echo "ERROR: $APPBUNDLE is missing!" 
    exit 1
fi

export APPVERSION=$(scout read -i $APPBUNDLE/Contents/Info.plist -f plist "CFBundleVersion")
export DMGNAME="$APPNAME-$APPVERSION.dmg"
export HTMLNAME="$APPNAME-$APPVERSION.html"

echo ""
echo "Committing latest code changes to Github:"
echo ""
DEFAULT_MESSAGE="Updates $APPNAME Version $APPVERSION"
echo -n "$DEFAULT_MESSAGE: "
read MESSAGE
git add -A
git commit -m "$DEFAULT_MESSAGE - $MESSAGE"
git push origin main

echo ""
echo "Generating DMG:"
echo ""
hdiutil create -volname $APPNAME -srcfolder $APPBUNDLE -ov -format UDZO ../Archive/$DMGNAME

echo ""
echo "Write Release Notes:"
echo ""
echo "Let's tell them why they should update!"
export EDITOR=/opt/homebrew/bin/emacs
$EDITOR ../Archive/$HTMLNAME
echo "Creating HTML for $DMGNAME: $HTMLNAME"
echo "-----------------------------------"
echo "-----------------------------------"

echo ""
echo "Generating Appcast:"
echo ""
~/Workshop/Sparkle-Tools/bin/generate_appcast ../Archive/

echo ""
echo "Cleaning up:"
echo ""
rm -Rf $APPBUNDLE

echo "Committing latest Appcast to Github:"
echo ""
DEFAULT_MESSAGE="Updates $APPNAME Version $APPVERSION"
echo -n "$DEFAULT_MESSAGE: "
read MESSAGE

git add -A
git commit -m "$DEFAULT_MESSAGE - $MESSAGE"
git push origin main

