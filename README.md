# OnePlus 6T – NetHunter OTG Kernel Experiments  
**Status:** Highly experimental | Boot image + DTB modification research  
**Device:** OnePlus 6T (fajita)  
**Goal:** Enable full USB Host (OTG) mode under Kali NetHunter Pro (sdm845)

---

## 📌 Purpose

This repository documents an ongoing technical experiment focused on:

- Enabling **USB Host / OTG** mode on OnePlus 6T  
- Modifying **DTB**, **kernel image**, and **NetHunter boot images**  
- Testing custom patches and custom-compiled kernels  
- Creating a clean, documented knowledge base for the community  
- Allowing others with SDM845 or OnePlus expertise to contribute

This is **not a stable kernel**, not intended for production use.  
The purpose is **learning, sharing, experimenting**, and debugging OTG behavior on SDM845.

---

## ⚠️ Current Status

- Many experimental builds lead to **bootloop**  
- Some DTB edits cause **early crash during boot**  
- AIK sometimes fails with **"ASCII compression"** errors  
- netHunter boot images require **special repack steps**  
- OTG mode is still **unstable / not fully functional**  
- USB drivers (`snps,dwc3`, `qcom,dwc3`) show different behaviors depending on DTB patch

Anyone with knowledge of:

- SDM845 USB PHY  
- DWC3 USB host driver  
- OnePlus device tree  
- NetHunter boot structure  

…is welcome to help.

---



## 📁 Folder Structure

op6t-otg-kernel/
│
├── dtb/ # Decompiled & modified DTS/DTBs for experiment
│
├── images/ # Kernel Image, stock boot, extracted boot components
│ ├── boot-stock.img
│ ├── Image.gz
│ └── dtb
│
├── scripts/ # Helper scripts (unpack / patch / repack)
│ ├── unpack.sh
│ ├── repack.sh
│ └── dtb_patch.sh
│
├── build-logs/ # dmesg logs, bootloop notes, test results
│
└── configs/ # kernel configs (defconfig, .config backups)


---

## 🛠️ Tools Used

- **AIK (Android Image Kitchen)**  
  Used for unpacking stock boot images.

- **magiskboot (source-built)**  
  Used to repack modified boot images.

- **Device Tree Compiler (dtc)**  
  For turning DTB → DTS → modified DTB.

- **Custom helper scripts**  
  For automating kernel + ramdisk repack steps.

---

## 🧪 Experiment Summary

### 1. Extract boot image  

./unpack.sh boot-stock.img


### 2. Modify DTB  
Example goal: Force USB Host mode  


dr_mode = "host";

But experiments show SDM845 may require additional PHY & glue changes.

### 3. Repack  


./repack.sh new_boot.img


### 4. Test via fastboot  


fastboot boot new_boot.img


---

## 🔍 Findings So Far

- Some DWC3 nodes default to `"peripheral"`  
- Changing **only dr_mode** often causes kernel panic  
- Boot image repacking requires special alignment on OnePlus 6T  
- Magiskboot source-compiled version avoids segmentation faults  
- NetHunter boot images include additional ramdisk layers (LZ4/gzip mix)  
- Kernel and DTB must match the **same base version** or the bootloader rejects it

Detailed experimentation logs are inside:  
`build-logs/`

---

## 🤝 Contributions

Anyone experienced with:

- **SDM845 kernel internals**  
- **OnePlus 6/6T device tree**  
- **USB host mode / DWC3 driver**  
- **NetHunter boot images**  
- **Qualcomm PHY configuration**

…is welcome to contribute.

PRs, forks, patches, DTB suggestions, or diagnostic logs are appreciated.

---

## 📌 Todo / Roadmap

- [ ] Stabilize repacker for NetHunter boot images  
- [ ] Investigate `qcom,dwc3` → `snps,dwc3` transitions  
- [ ] Patch OTG PHY clocks & regulators  
- [ ] Add buildable kernel tree based on upstream SDM845  
- [ ] Add release section with `.img` builds  
- [ ] Document all dmesg error patterns  
- [ ] Provide a simplified auto-patch script

---

## 📜 License

MIT License – free to use, modify, contribute  
This project is for educational & research purposes only.

---

## 🙏 Acknowledgements

- NetHunter Pro Team  
- osm0sis – AIK  
- topjohnwu – magiskboot  
- SDM845 open-source kernel communities  
- Contributors who test experimental OTG builds

---



