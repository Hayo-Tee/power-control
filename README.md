# Power Control PC by ESP32

[🇷🇺 RU](README_ru.md) | [🇬🇧 EN](README.md)

<img src="/pictures/esp32_c3.webp" alt="ESP32-C3" width="400" />

## Project Description

Recently, I purchased a **Cooler Master Stacker 830** case and built a server PC based on the **ASUS Z10PE-D8** motherboard. Since I access the server via **Tailscale**, I faced a challenge — how to power on the PC remotely if it is completely turned off at home. There are many solutions available online, but I decided to create my own using **ESPHome** and **ESP32-C3**.

---

## Key Features

* **Power on the PC**
* **Power off the PC**
* **Force shutdown** (emulation of holding the power button)
* **Restart the PC**
* **Get PC status** (on / off)

---

## Additional Functionality for Unraid

Since my server runs **Unraid OS**, I added an extra button to control a virtual machine. You can easily repurpose this feature for any other task by modifying the script.

* **Single press** — starts the virtual machine
* **Double press** — stops the virtual machine
* **Long press** — force stops the virtual machine

---

## License

This project is distributed under the **MIT** license.
