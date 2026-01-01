#!/usr/bin/env bash

ROOT_DIR="$(git rev-parse --show-toplevel)"

cp -r $essentia_src essentia/
sudo chmod -R 770 essentia/

pushd "$ROOT_DIR/essentia/packaging/debian_3rdparty/" &>/dev/null
./build_fftw3.sh

## ./build_gaia.sh
. ../build_config.sh
rm -rf tmp
mkdir tmp
cd tmp
echo "Building gaia $GAIA_VERSION"
curl -SLO https://github.com/MTG/gaia/archive/v$GAIA_VERSION.tar.gz
tar -xf v$GAIA_VERSION.tar.gz
cd gaia-$GAIA_VERSION
python2 waf configure --prefix=$PREFIX
python2 waf
python2 waf install 
cd ../..
rm -rf tmp

pushd "$ROOT_DIR/essentia/" &>/dev/null
python3 waf configure --build-static --static-dependencies --with-examples --with-gaia --prefix "$ROOT_DIR/out"
python3 waf
python3 waf install

rm -rf tmp
rm -rf essentia
