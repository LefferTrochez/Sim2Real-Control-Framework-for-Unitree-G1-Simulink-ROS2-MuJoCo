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

This repository presents Version 1.0 of a MATLAB/Simulink-based Sim2Real framework for the Unitree G1 humanoid robot, integrating MuJoCo and ROS 2 within a unified workflow for controller development, simulation-based validation, visualization, and real-robot deployment. The main objective of this repository is to provide a clean and research-oriented framework that preserves a common high-level interface across both simulation and real-robot execution backends.

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

├── images/              # Figures used in the documentation and README
└── material/            # Main technical folder of the project
    ├── examples/        # Example files built on top of the original Sim2Real framework (ankle-motion)
    ├── MuJoCo files/    # MuJoCo simulation resources, XML robot model, meshes, and related files
    ├── ROS 2 files/     # Custom Unitree ROS 2 messages and scripts for message generation/integration
    └── Sim2Real files/  # Core reusable Sim2Real base, Variant Subsystem, and support files
```

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

## Technologies Used

<p align="center">
  <img src="images/MatlabSimulink.jpg" alt="MATLAB and Simulink" height="45">
  &nbsp;&nbsp;&nbsp;
  <img src="images/Mujoco.jpeg" alt="MuJoCo" height="40">
  &nbsp;&nbsp;&nbsp;
  <img src="images/Unitree.png" alt="Unitree" height="40">
  &nbsp;&nbsp;&nbsp;
  <img src="images/ROS.jpg" alt="ROS 2" height="40">
</p>

---

## Contact

Leffer Trochez <br>
Electronic Engineer and M.Sc. in Electronic and Computer Engineering  
Universidad de los Andes  
Faculty of Engineering  
Department of Electrical and Electronic Engineering  
GIAP Research Group  
Bogotá D.C., Colombia  
<p>
  <a href="mailto:l.trochez@uniandes.edu.co"><img src="images/Email.png" alt="Email" height="28" valign="middle"></a>
  &nbsp;
  <a href="https://www.linkedin.com/in/leffer-trochez/"><img src="images/LinkedIn.png" alt="LinkedIn" height="28" valign="middle"></a>
  &nbsp;
  <a href="https://scholar.google.com/citations?user=Ve1E4AEAAAAJ&hl=es&oi=ao"><img src="images/GoogleScholar.png" alt="Google Scholar" height="28" valign="middle"></a>
  &nbsp;
  <a href="https://orcid.org/0009-0002-5321-7652"><img src="images/ORCID.png" alt="ORCID" height="28" valign="middle"></a>
</p>

---

## Citation

If you use this repository in academic work, research projects, technical reports, or derivative software developments, please cite it appropriately.

This repository includes a `CITATION.cff` file in the root of the repository so that GitHub can expose a standard citation format through the Cite this repository feature. Once a public release is archived through Zenodo, this section can be updated with the corresponding DOI-based citation.

### How to cite

Until a DOI is available, the repository can be cited as software in the following format:

```bibtex
@software{trochez2026sim2real,
  author       = {Leffer Trochez and Nicanor Quijano and Jorge Lopez-Jimenez and Carlos Francisco Rodriguez},
  title        = {A MATLAB/Simulink-Based Sim2Real Control Framework for the Unitree G1 Using ROS 2 and MuJoCo},
  year         = {2026},
  version      = {1.0},
  institution  = {Universidad de los Andes},
  url          = {https://github.com/LefferTrochez/Sim2Real-Control-Framework-for-Unitree-G1-Simulink-ROS2-MuJoCo}
}
```

### Citation note

GitHub currently supports citation outputs based on `CITATION.cff`, including APA and BibTeX. If this framework contributes to a thesis, paper, report, or software-based research output, please cite the repository and, once available, its DOI-linked release record.

---

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for the full license text.

---

## Acknowledgments

The author would like to express sincere gratitude to [Manoj Vasudevan](https://vmanoj1996.github.io/) for having planted the initial seed of this work through the MuJoCo Simulink Blockset, which provided an important foundation and early inspiration for the development of this framework.

The author also gratefully acknowledges [Álvaro Achury](https://academia.uniandes.edu.co/AcademyCv/au.achury33), leader of the laboratories and caretaker of the humanoid robot platform at Universidad de los Andes (AURA), for his valuable assistance in the handling and operation of the real robot platform.

This project also builds upon or interacts with important technologies and platforms, including:

- Unitree Robotics
- MathWorks
- ROS 2
- MuJoCo

All third-party software, SDKs, libraries, and dependencies remain subject to their respective licenses and terms of use.

---

## References

This project builds upon the following software tools, repositories, and official resources:

1. Google DeepMind. *MuJoCo Documentation*. Official documentation website. Available at: https://mujoco.readthedocs.io/

2. Zakka, K., Tassa, Y., and MuJoCo Menagerie Contributors. *MuJoCo Menagerie: A collection of high-quality simulation models for MuJoCo*. GitHub repository, 2022. Available at: https://github.com/google-deepmind/mujoco_menagerie

3. MathWorks. *MATLAB Documentation*. Official documentation website. Available at: https://www.mathworks.com/help/matlab/index.html

4. MathWorks. *Simulink Documentation*. Official documentation website. Available at: https://www.mathworks.com/help/simulink/index.html

5. MathWorks. *ROS Toolbox Documentation*. Official documentation website. Available at: https://www.mathworks.com/help/ros/index.html

6. MathWorks Robotics. *Simulink Blockset for MuJoCo Simulator*. GitHub repository. Available at: https://github.com/mathworks-robotics/mujoco-simulink-blockset

7. Unitree Robotics. *unitree_sdk2*. GitHub repository. Available at: https://github.com/unitreerobotics/unitree_sdk2

8. Unitree Robotics. *unitree_ros2*. GitHub repository. Available at: https://github.com/unitreerobotics/unitree_ros2
