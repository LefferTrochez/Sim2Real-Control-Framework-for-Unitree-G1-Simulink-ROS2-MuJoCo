# Sim2Real-Framework-Unitree-G1-Simulink-ROS2-MuJoCo
Version 1.0 of a MATLAB/Simulink-based Sim2Real framework for the Unitree G1 humanoid robot, integrating MuJoCo and ROS 2 in a unified workflow for controller development, simulation, visualization, and real-robot deployment.

# Unitree G1 Sim2Real Framework - Simulink, ROS 2 and MuJoCo

<p align="center">
  <img src="Images/Sim2Real_Framework.png" alt="Unitree G1 Sim2Real Framework" width="700">
</p>

![Version](https://img.shields.io/badge/version-1.0-blue)
![MATLAB](https://img.shields.io/badge/MATLAB-Supported-orange)
![Simulink](https://img.shields.io/badge/Simulink-Based-orange)
![ROS2](https://img.shields.io/badge/ROS2-Supported-blue)
![MuJoCo](https://img.shields.io/badge/MuJoCo-Integrated-green)
![License](https://img.shields.io/badge/license-Apache--2.0-red)

---

## Table of Contents

1. [Introduction](#introduction)
2. [Framework Overview](#framework-overview)
3. [Repository Contents](#repository-contents)
4. [Technologies Used](#technologies-used)
5. [Getting Started](#getting-started)
6. [How to Use](#how-to-use)
7. [Current Scope](#current-scope)
8. [Future Work](#future-work)
9. [Contact](#contact)
10. [Citation](#citation)
11. [License](#license)
12. [Acknowledgments](#acknowledgments)

---

## Introduction

This repository presents **Version 1.0** of a **MATLAB/Simulink-based Sim2Real framework** for the **Unitree G1 humanoid robot**. The framework integrates **MuJoCo simulation** and **ROS 2 communication** into a unified workflow for controller development, simulation-based validation, visualization, and real-robot deployment. It is intended as a research-oriented framework layer for humanoid robotics in MATLAB/Simulink. :contentReference[oaicite:1]{index=1}

This repository complements the academic work and poster associated with the project and provides the main files required to understand and use the current framework version. The overall objective is to reduce fragmented development workflows by preserving a common high-level control structure across both simulation and real-robot execution. :contentReference[oaicite:2]{index=2}

---

## Framework Overview

The framework is built around a **Sim2Real Variant Subsystem** that allows the user to switch between two execution backends:

- **MuJoCo**, for simulation-based development and validation
- **ROS 2**, for communication with the real Unitree G1 robot

Both subsystems preserve a compatible input-output structure, so the high-level control logic does not need to be rewritten when switching between simulation and real-robot execution. This is one of the main design principles of the framework. :contentReference[oaicite:3]{index=3}

---

## Repository Contents

Below is a summary of the main files included in this repository:

```text
.
├── Sim2Real_variant_subsystem.slx
├── launcher.mlx
├── sim2real_config.mlx
├── bus_definitions.mlx
├── g1_constraints.mlx
└── MuJoCo files/
    ├── unitree_G1.xml
    └── meshes/
