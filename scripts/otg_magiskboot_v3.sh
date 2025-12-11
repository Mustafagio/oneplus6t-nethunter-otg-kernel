#!/bin/bash
set -e

echo "=== [1] Dizinleri ayarlıyorum... ==="

NH_DIR="/home/kali/nethunter-otg"
KERNEL_DIR="$NH_DIR/qcom-linux"
MAGISKBOOT_DIR="$NH_DIR/magiskboot-src"
ORIG_BOOT="/home/kali/Downloads/nethunterpro-20250915-sdm845-phosh.boot-fajita.img"

KERNEL_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz"
DTB_IMG="$KERNEL_DIR/out/arch/arm64/boot/dts/qcom/sdm845-oneplus-fajita.dtb"

UNPACK_DIR="$NH_DIR/boot_ms_otg"
NEW_BOOT="$NH_DIR/new_boot_ms_otg.img"

echo "NH_DIR      = $NH_DIR"
echo "KERNEL_DIR  = $KERNEL_DIR"
echo "MAGISKBOOT_DIR = $MAGISKBOOT_DIR"
echo "ORIG_BOOT   = $ORIG_BOOT"
echo "KERNEL_IMG  = $KERNEL_IMG"
echo "DTB_IMG     = $DTB_IMG"
echo "UNPACK_DIR  = $UNPACK_DIR"
echo "NEW_BOOT    = $NEW_BOOT"
echo

echo "=== [2] Gerekli dosyaları kontrol ediyorum... ==="

if [ ! -f "$ORIG_BOOT" ]; then
  echo "HATA: Orijinal boot img bulunamadı:"
  echo "  $ORIG_BOOT"
  exit 1
fi

if [ ! -f "$KERNEL_IMG" ]; then
  echo "HATA: Derlediğimiz kernel (Image.gz) bulunamadı:"
  echo "  $KERNEL_IMG"
  exit 1
fi

if [ ! -f "$DTB_IMG" ]; then
  echo "HATA: DTB dosyası bulunamadı:"
  echo "  $DTB_IMG"
  exit 1
fi

echo "Tüm gerekli dosyalar mevcut görünüyor."
echo

echo "=== [3] magiskboot reposunu kontrol ediyorum... ==="

if [ ! -d "$MAGISKBOOT_DIR" ]; then
  echo "magiskboot klasörü yok, şimdi GitHub'dan klonlayacağım..."
  mkdir -p "$NH_DIR"
  cd "$NH_DIR"
  git clone https://github.com/alitekin2fx/magiskboot "$MAGISKBOOT_DIR"
else
  echo "magiskboot klasörü mevcut, güncelleme deniyorum..."
  cd "$MAGISKBOOT_DIR"
  git pull || true
fi

echo
echo "=== [4] magiskboot binary'sini hazırlıyorum... ==="

cd "$MAGISKBOOT_DIR"

MAGISKBOOT_BIN=""

if [ -f "$MAGISKBOOT_DIR/magiskboot" ]; then
  MAGISKBOOT_BIN="$MAGISKBOOT_DIR/magiskboot"
elif [ -f "$MAGISKBOOT_DIR/out/magiskboot" ]; then
  MAGISKBOOT_BIN="$MAGISKBOOT_DIR/out/magiskboot"
elif [ -f "$MAGISKBOOT_DIR/bin/magiskboot" ]; then
  MAGISKBOOT_BIN="$MAGISKBOOT_DIR/bin/magiskboot"
fi

if [ -z "$MAGISKBOOT_BIN" ]; then
  echo "HATA: magiskboot binary bulunamadı."
  echo "Lütfen şu klasöre bak:"
  echo "  ls $MAGISKBOOT_DIR"
  exit 1
fi

chmod +x "$MAGISKBOOT_BIN"
echo "magiskboot bulundu: $MAGISKBOOT_BIN"
echo

echo "=== [5] Eski unpack dizinini temizliyorum... ==="

rm -rf "$UNPACK_DIR"
mkdir -p "$UNPACK_DIR"
cd "$UNPACK_DIR"

echo "=== [6] Orijinal boot.img'yi UNPACK ediyorum (--unpack ile)... ==="
cp "$ORIG_BOOT" ./orig_boot.img

"$MAGISKBOOT_BIN" --unpack ./orig_boot.img

echo
echo "Unpack tamamlandıysa burada kernel / ramdisk.cpio / dtb dosyalarını görmelisin:"
ls -lh || true

if [ ! -f "kernel" ]; then
  echo "HATA: unpack sonrası 'kernel' dosyası bulunamadı!"
  exit 1
fi

if [ ! -f "dtb" ]; then
  echo "DİKKAT: 'dtb' dosyası bulunamadı, bazı boot img tiplerinde ayrı dtb olmayabilir."
  DTB_PRESENT=0
else
  DTB_PRESENT=1
fi

echo
echo "=== [7] Kernel'i bizim derlediğimiz Image.gz ile DEĞİŞTİRİYORUM... ==="

mv kernel kernel.backup
cp "$KERNEL_IMG" kernel

echo "Eski kernel yedeği: $UNPACK_DIR/kernel.backup"
echo "Yeni kernel:        $UNPACK_DIR/kernel"
echo

if [ "$DTB_PRESENT" -eq 1 ]; then
  echo "=== [8] DTB'yi bizim derlediğimiz fajita DTB ile DEĞİŞTİRİYORUM... ==="
  mv dtb dtb.backup
  cp "$DTB_IMG" dtb
  echo "Eski dtb yedeği: $UNPACK_DIR/dtb.backup"
  echo "Yeni dtb:        $UNPACK_DIR/dtb"
else
  echo "DTB dosyası yoktu, sadece kernel değiştirildi."
fi

echo
echo "=== [9] Yeni boot img'yi REPACK ediyorum (--repack ile)... ==="

"$MAGISKBOOT_BIN" --repack ./orig_boot.img ./new_boot_ms_otg.img

if [ ! -f "./new_boot_ms_otg.img" ]; then
  echo "HATA: Repack sonrası new_boot_ms_otg.img bulunamadı!"
  exit 1
fi

cp ./new_boot_ms_otg.img "$NEW_BOOT"

echo
echo "=== [10] İşlem tamam! 🎉 ==="
echo "Yeni boot img şu konuma kaydedildi:"
echo "  $NEW_BOOT"
echo
echo "Geçici test için (fastboot modunda):"
echo "  fastboot boot $NEW_BOOT"
echo
echo "Sorunsuz açılırsa kalıcı flash için:"
echo "  fastboot flash boot $NEW_BOOT && fastboot reboot"
echo
