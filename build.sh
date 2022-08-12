#!/bin/bash

GIT='https://github.com/GloriousEggroll/proton-ge-custom/releases'
#GE_RELEASE='GE-Proton7-29'

rm_ai_flag() {
    dd if=/dev/zero bs=1 count=3 seek=8 conv=notrunc of="$1" &>/dev/null
    #sed -i 's|AI\x02|\x00\x00\x00|' "$1" &>/dev/null
}

try_dl() {
    aria2c "$1"||wget "$1"
}

# machine's architecture
export ARCH='x86_64'
echo "Machine's architecture: $ARCH"

# get the missing tools if necessary
if [ ! -f "appimagetool-$ARCH.AppImage" ]
  then
      echo "Get the missing tools..."
      try_dl "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$ARCH.AppImage"
      chmod a+x "appimagetool-$ARCH.AppImage"
      #rm_ai_flag "appimagetool-$ARCH.AppImage"
fi

# get binary sources if necessary
if [[ "$GE_RELEASE" == 'latest' || ! -n "$GE_RELEASE" ]]
    then
        GE_DL_URL="${GIT}$(curl -L -s "${GIT}"|grep -o '\/download.*tar.gz'|head -1)"
        GE_RELEASE="$(basename "$GE_DL_URL"|sed 's/.tar.gz//')"
        GE_TAR="$(basename "$GE_DL_URL")"
    else
        GE_TAR="$GE_RELEASE.tar.gz"
        [ ! -f "$GE_TAR" ] && \
        GE_DL_URL="${GIT}$(curl -L -s "${GIT}/tag/${GE_RELEASE}"|grep -o '\/download.*tar.gz')"
fi
if [ ! -f "$GE_TAR" ]
    then
        echo "Get binary sources..."
        try_dl "$GE_DL_URL"
fi

# prepare source AppDir
rm -rvf src
if [ -f "$GE_TAR" ]
    then
        echo "Prepare source AppDir..."
        tar -xvf "$GE_TAR" && mkdir src
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
        #[ -f "$GE_APPIMAGE" ] && rm_ai_flag "$GE_APPIMAGE" && \
        [ -f "$GE_APPIMAGE" ] && \
        mv "$GE_APPIMAGE" "GE-Proton-v${GE_VERSION}-${ARCH}.AppImage")
        rm -rvf src
fi
