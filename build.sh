#!/bin/bash

GIT='https://github.com/GloriousEggroll/proton-ge-custom/releases'
GE_RELEASE='latest'
#GE_RELEASE='GE-Proton7-29'

# machine's architecture
export ARCH='x86_64'
echo "Machine's architecture: $ARCH"

# get the missing tools if necessary
if [ ! -f "appimagetool-$ARCH.AppImage" ]
  then
      echo "Get the missing tools..."
      wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$ARCH.AppImage"
      chmod a+x "appimagetool-$ARCH.AppImage"
fi

# get binary sources if necessary
if [ ! -f "$GE_TAR_GZ" ]
    then
        echo "Get binary sources..."
        if [ "$GE_RELEASE" != 'latest' ]
            then
                wget "${GIT}$(curl -L -s "${GIT}/tag/${GE_RELEASE}"|grep -o '\/download.*tar.gz')"
            else
                DL_URL="${GIT}$(curl -L -s "${GIT}"|grep -o '\/download.*tar.gz'|head -1)"
                GE_RELEASE="$(basename "$DL_URL"|sed 's/.tar.gz//')"
                wget "$DL_URL"
        fi
        GE_TAR_GZ="$(ls -1t "$GE_RELEASE.tar.gz" 2>/dev/null|head -1)"
fi

# prepare source AppDir
rm -rvf src
if [ -f "$GE_TAR_GZ" ]
    then
        echo "Prepare source AppDir..."
        tar -xvf "$GE_TAR_GZ" && mkdir src
        mv "${GE_RELEASE}/files" src/usr
        rm -rvf ${GE_RELEASE}
        cp -vf proton.png src/
        cp -vf proton.desktop src/
        cp -vf AppRun src/
        chmod a+x src/AppRun
        (cd src && ln -sf proton.png .DirIcon)
        mkdir -p src/usr/share/applications
        mkdir -p src/usr/share/icons/hicolor/256x256/apps
        cp -vf proton.desktop src/usr/share/applications/
        cp -vf proton.png src/usr/share/icons/hicolor/256x256/apps/
fi

# building AppImage
if [[ -f "appimagetool-$ARCH.AppImage" && -d src ]]
    then
        echo "Building AppImage..."
        mkdir build 2>/dev/null
        (cd build && ../appimagetool-$ARCH.AppImage ../src
        GE_VERSION="$(echo "$GE_RELEASE"|sed 's/GE-Proton//')"
        GE_APPIMAGE="$(ls -1t "GE-Proton-${ARCH}.AppImage" 2>/dev/null|head -1)"
        [ -f "$GE_APPIMAGE" ] && mv "$GE_APPIMAGE" "GE-Proton-v${GE_VERSION}-${ARCH}.AppImage")
        rm -rvf src
fi
