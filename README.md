# A MATLAB/Simulink-Based Sim2Real Control Framework for the Unitree G1 Using ROS 2 and MuJoCo

<p align="center">
  <img src="images/Pipeline.png" alt="Sim2Real Pipeline" width="1000">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/MATLAB-Supported-orange" alt="MATLAB">
  <img src="https://img.shields.io/badge/Simulink-Based-orange" alt="Simulink">
  <img src="https://img.shields.io/badge/ROS2-Supported-blue" alt="ROS 2">
  <img src="https://img.shields.io/badge/MuJoCo-Integrated-green" alt="MuJoCo">
  <img src="https://img.shields.io/badge/license-Apache--2.0-red" alt="License">
</p>

---

## Table of Contents

1. [Introduction](#introduction)
2. [Framework Overview](#framework-overview)
3. [Repository Structure](#repository-structure)
4. [Material Folder Contents](#material-folder-contents)
5. [Technologies Used](#technologies-used)
6. [Getting Started](#getting-started)
7. [How to Use](#how-to-use)
8. [Current Scope](#current-scope)
9. [Future Work](#future-work)
10. [Contact](#contact)
11. [Citation](#citation)
12. [License](#license)
13. [Acknowledgments](#acknowledgments)

---

## Introduction

This repository presents Version 1.0 of a MATLAB/Simulink-based Sim2Real framework for the Unitree G1 humanoid robot, integrating MuJoCo and ROS 2 within a unified workflow for controller development, simulation-based validation, visualization, and real-robot deployment.

The main objective of this repository is to provide a clean and research-oriented framework that preserves a common high-level interface across both simulation and real-robot execution backends.

---

## Framework Overview

The core idea of the framework is to allow the user to develop and organize control logic in MATLAB/Simulink, validate it in MuJoCo, and then transition toward ROS 2-based execution on the real Unitree G1 while maintaining a common structure.

At the center of the repository is a Sim2Real Variant Subsystem, which enables switching between:

- **MuJoCo:** for simulation-based development and testing
- **ROS 2:** for communication and deployment with the real robot

<p align="center">
  <img src="images/Sim2Real.png" alt="Sim2Real Logo" width="300">
</p>

This design keeps the overall workflow modular, structured, and reusable.

---

## Repository Structure

The repository is organized as follows:

```text
.
├── images/
└── material/
    ├── examples/
    ├── MuJoCo files/
    ├── ROS 2 files/
    └── Sim2Real files/
```

### `images/`

This folder contains the figures used in the repository documentation, including the main welcome image shown at the top of this README.

### `material/`

This is the main technical folder of the repository. It contains the reusable framework base, the example files, the MuJoCo simulation resources, and the ROS 2 communication files.

---

## Material Folder Contents

### `examples/`

This folder contains example files built on top of the original Sim2Real Variant Subsystem. The current example corresponds to a representative ankle-motion task, intended to show how the base framework can be reused and extended for specific demonstrations.

### `MuJoCo files/`

This folder contains the resources required for MuJoCo-based simulation, including the main XML robot model, the meshes folder, and additional files related to the simulator model and its structure.

### `ROS 2 files/`

This folder contains the custom ROS 2 message package together with the scripts required to create and generate those messages. These files provide the communication base needed by the framework for ROS 2 integration.

### `Sim2Real files/`

This folder contains the main reusable base of the project. It includes the original Sim2Real Variant Subsystem and the core Simulink support files required to initialize and use the framework. Users can take this folder as the starting point for building new examples, controllers, or extensions on top of the original framework structure.

---

## Technologies Used

This project is built around the following technologies:

- MATLAB
- Simulink
- MuJoCo
- ROS 2
- ROS Toolbox
- Simulink Blockset for MuJoCo Simulator

---

## Getting Started

### Requirements

To use this repository, the following components are expected:

- MATLAB
- Simulink
- ROS Toolbox
- Simulink Blockset for MuJoCo Simulator
- A ROS 2 environment
- Access to the Unitree G1 platform if real-robot execution is intended

### Initial Setup

1. Clone the repository.
2. Open the main Simulink framework files.
3. Review the `Sim2Real files` folder.
4. Explore the example files if you want a minimal demonstration of the workflow.
5. Make sure all dependencies are correctly installed in your local environment.

---

## How to Use

1. Open the main Simulink framework contained in the `Sim2Real files` folder.
2. Use the `RUN_MODE` selection inside the framework to choose the desired backend:
   - **MuJoCo**
   - **ROS 2**
3. After changing the selected execution mode, press `Ctrl + D` to update the model.
4. Run the framework from Simulink.
5. Use the example files in the `examples` folder as a reference for building new demonstrations on top of the framework base.

---

## Current Scope

At its current stage, the repository includes:

- A Simulink-centered Sim2Real workflow
- A reusable Variant Subsystem structure
- Integration of MuJoCo and ROS 2 under a common framework logic
- A modular base for future control, estimation, and deployment developments
- A representative example demonstrating how the framework can be extended

---

## Future Work

Planned future developments include:

- Adding more complete examples and demonstrations
- Expanding the documentation and setup instructions
- Improving integration with additional sensors and subsystems
- Extending the framework with more advanced humanoid control modules
- Incorporating additional validation cases in both simulation and real-robot execution

---

## Contact

**Leffer Trochez**  
Universidad de los Andes, GIAP Research Group

**Email:** your_email_here  
**LinkedIn:** your_linkedin_here

---

## Citation

If you use this repository in academic work, please cite the associated repository and future software record.

A `CITATION.cff` file will be added to this repository, and a DOI-based citation is planned for a future release.

### How to cite

You may cite this project in the following format until a DOI is available:

```bibtex
@software{trochez2026sim2real,
  author       = {Leffer Trochez},
  title        = {A MATLAB/Simulink-Based Sim2Real Control Framework for the Unitree G1 Using ROS 2 and MuJoCo},
  year         = {2026},
  institution  = {Universidad de los Andes, GIAP Research Group},
  version      = {1.0},
  url          = {https://github.com/your-username/your-repository-name}
}
```

Once a DOI is generated, this section can be updated with the final citation entry.

---

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

This project builds upon or interacts with technologies and platforms such as:

- Unitree Robotics
- MathWorks
- ROS 2
- MuJoCo

All third-party software, SDKs, and dependencies remain subject to their respective licenses and terms of use.
