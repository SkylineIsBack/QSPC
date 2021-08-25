#!/bin/bash

# By SkylineIsBack

clear
echo "Installing QS Panel Customizer"
echo ""
pkg install openjdk-17 -y
pkg install aapt -y
pkg install openssl-tool -y
mkdir QSPC
mv android.jar QSPC/
mv apksigner.jar QSPC/
mv make QSPC/
mv afterupdate QSPC/
mv delete QSPC/
mv QSPC $HOME
cd $HOME/QSPC/
chmod +x make
chmod +x afterupdate
chmod +x delete
mkdir input
mkdir output
mkdir backup
mkdir keys
cd keys
openssl genrsa -3 -out temp.pem 2048
openssl req -new -x509 -key temp.pem -out releasekey.x509.pem -days 10000 -subj '/C=US/ST=California/L=San Narciso/O=Yoyodyne, Inc./OU=Yoyodyne Mobility/CN=Yoyodyne/emailAddress=yoyodyne@example.com'
openssl pkcs8 -in temp.pem -topk8 -outform DER -out releasekey.pk8 -nocrypt
shred --remove temp.pem
echo ""
echo "Successfully installed QSPC"