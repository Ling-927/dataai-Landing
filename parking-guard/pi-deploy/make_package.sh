#!/bin/bash
# Buat pakej ZIP yang boleh disalin ke microSD
# Jalankan dari folder parking-guard/: bash pi-deploy/make_package.sh

set -e
OUT="idefender-pi-deploy.zip"
rm -f "$OUT"

cd pi-deploy
zip -r "../$OUT" . -x "*.DS_Store" -x "__pycache__/*" -x "*.pyc" -x "make_package.sh"
cd ..

echo "✓ Pakej siap: $OUT"
echo "  Saiz: $(du -sh $OUT | cut -f1)"
echo ""
echo "Cara guna:"
echo "  1. Ekstrak ZIP ini"
echo "  2. Salin kandungan folder 'boot/' ke partition boot microSD"
echo "  3. Salin folder 'home/pi/parking-guard/' ke Pi via SCP"
echo "  4. SSH ke Pi dan jalankan: sudo bash /home/pi/parking-guard/install.sh"
