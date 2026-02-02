# An Efficient Approximate Ripple Carry Adder Design for Image Processing

![Status](https://img.shields.io/badge/Status-Under%20Review-yellow) ![Language](https://img.shields.io/badge/Verilog-HDL-blue) ![Technology](https://img.shields.io/badge/Technology-45nm%20CMOS-green) ![Accuracy](https://img.shields.io/badge/Accuracy-90%25-brightgreen)

## 📌 Overview
This repository contains the implementation of a **Hybrid Approximate Adder (PAL)** designed to optimize the trade-off between hardware efficiency (area, delay, power) and computational accuracy. The design is specifically tailored for error-tolerant applications like **Digital Image Processing**, utilizing a segmented architecture that eliminates carry propagation for lower nibbles.

The design was synthesized using **Cadence Genus** with **45nm CMOS technology** and validated on $(3\times3)$ **Sobel and Box kernels** for image smoothing and edge detection.

---

## 🚀 Key Features
* **Segmented Architecture:** Uses exact logic for the Upper Nibble (MSBs) and Proposed Approximate Logic (PAL) for the Lower Nibble (LSBs).
* **High Performance:** Significantly reduces **Critical Path Delay** compared to exact Ripple Carry Adders (RCA).
* **Energy Efficient:** Optimized for lower **Switching Power** and **Leakage Power**.
* **High Accuracy:** Achieves **90% accuracy** improvement over existing approximate designs (like EAL9).
* **Application Ready:** Validated with real-world image processing tasks (Edge Detection & Smoothing).

---

## 📂 Repository Structure

| Folder | Description |
| :--- | :--- |
| **`rtl/`** | Contains the **Verilog HDL** source codes for the PAL and Exact Adder, plus Synthesis scripts (TCL). |
| **`model/`** | Python scripts for **Error Analysis** (MED, NMED) and **Kernel Multiplication** modeling. |
| **`visualization/`** | MATLAB scripts used to generate performance graphs and comparative plots. |
| **`outputs/`** | Stores the generated results, including synthesized logs, processed images, and raw data. |
| **`assets/`** | Documentation files and diagrams. |

---

## 🛠️ Architecture
The Proposed Approximate Logic (PAL) simplifies the full adder circuit by making the Carry Output ($C_{out}$) independent of the Carry Input ($C_{in}$) for the lower bits. This breaks the carry chain and allows for parallel computation.

---

## 📊 Results Summary

| Metric | Result | Improvement |
| :--- | :--- | :--- |
| **Accuracy** | 90% vs EAL9 | High Precision |
| **Technology Node** | 45nm CMOS | Industry Standard |
| **Applications** | Sobel / Box Kernels | Real-world tested |

---

## 💻 How to Run

### **1. Hardware Synthesis (RTL)**
Requirements: **Cadence Genus** or **Xilinx Vivado**.
```bash
cd rtl/synthesis
# Run the synthesis script
genus -f script.tcl