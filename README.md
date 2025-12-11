# OnePlus 6T OTG Kernel Patch Project  
**Experimental OTG Enabling for OnePlus 6T (sdm845) under Kali NetHunter Pro**

---

## ⚠️ Disclaimer
This project is **experimental** and may cause **bootloops**, **soft-bricks**, or require manual fastboot recovery.  
All work is performed on a test device by choice, and contributors should be aware of the risks.

---

## 🎯 Purpose
The goal of this project is to understand and modify the **USB controller (DWC3)** and **Device Tree (DTB)** on the OnePlus 6T to enable **stable OTG Host Mode** under:

- Kali NetHunter Pro  
- Custom kernels  
- Modified boot images  

We share progress here so the community can:

- Review experiments  
- Suggest improvements  
- Provide patches  
- Help stabilize OTG on OP6T  

---

## 📌 Current Status

- Many builds result in **bootloop**
- Some DTB edits cause early crash or interrupt failure
- AIK sometimes breaks due to `ASCII parsing` issues
- OTG mode still **unstable / not fully functional**
- Working hypothesis: OTG needs **multiple DTB nodes patched**, not only `dr_mode`

---

## 📁 Folder Structure

op6t-otg-kernel/
│
├── dtb/ → DTB files used in experiments
├── images/ → Kernel Image, stock boot, extracted boot
├── scripts/ → Helper scripts for unpack/patch/repack
├── configs/ → Kernel config files (defconfig, custom configs)
└── build-logs/ → dmesg logs, bootloop logs, debug notes


---

## 🔧 Tools Used

- **AIK-Linux** (Android Image Kitchen) for unpacking and repacking boot images  
- **dtc** (Device Tree Compiler)  
- **magiskboot** for repacking alternative boot formats  
- **fastboot** for flashing / testing  
- **Kali NetHunter Pro kernel source (qcom-linux)**  

---

## 🧪 Experiment Notes

### ✔ What works
- Extracting boot image  
- Editing DTB files  
- Repacking images  
- Flashing or temporarily booting with `fastboot boot`  

### ✖ What fails
- Many edited DTBs cause **kernel panic before init**  
- Changing the internal DWC3 controller node often causes **instant bootloop**  
- Repack errors during ASCII → binary transformation in DTB  

### 🧩 Hypothesis
OTG mode likely requires changes in:

- `/soc@0/.../usb@a600000` node  
- `/soc@0/.../usb@a800000` node  
- Power / PHY nodes  
- QCOM-specific properties that override standard USB roles  

Community expertise is needed to confirm this.

---

## 🛠 Example: Current DTB Modification Approach

### 1. Extract DTB
```bash
dtc -I dtb -O dts -o a.dts sdm845-oneplus-fajita.dtb

2. Modify USB role

Search for: dr_mode = "peripheral";

Replace with: dr_mode = "host";

3. Rebuild DTB

dtc -I dts -O dtb -o host.dtb a.dts

4. Inject into boot image

(Custom script included in project /scripts)

🚀 Flashing / Testing
Temporary boot (recommended)
fastboot boot boot-test.img

If it bootloops, simply reboot to fastboot.

Permanent flash (dangerous)
fastboot flash boot boot-test.img

📝 Logs & Debugging

Place your logs in:

build-logs/dmesg/
build-logs/bootloop/


Useful logs include:

dmesg from successful boots

UART logs from early crashes

Kernel panic screenshots

Output from fastboot getvar all

🤝 Contributions

Anyone experienced with:

SDM845 kernel internals

OnePlus 6/6T device tree

DWC3 USB host drivers

NetHunter boot images

Qualcomm PHY / pinctrl / power domains

…is welcome to contribute!

Please create:

Pull requests

Issues

Notes

Logs

Every bit of information helps.

📜 License

MIT License
This project is open for research and educational use.
Contributions remain credited to their authors.
