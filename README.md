# A MATLAB/Simulink-Based Sim2Real Control Framework for the Unitree G1 Using ROS 2 and MuJoCo

<p align="center">
  <img src="images/Pipeline.png" alt="Sim2Real Pipeline" width="900">
</p>

<p align="center">
  <a href="https://github.com/LefferTrochez/Sim2Real-Control-Framework-for-Unitree-G1-Simulink-ROS2-MuJoCo/releases/tag/v1.0.0"><img src="https://img.shields.io/badge/version-1.0-blue" alt="Version" valign="middle"></a>
  <a href="https://www.mathworks.com/products/matlab.html"><img src="https://img.shields.io/badge/MATLAB-Supported-orange" alt="MATLAB" valign="middle"></a>
  <a href="https://www.mathworks.com/products/simulink.html"><img src="https://img.shields.io/badge/Simulink-Based-orange" alt="Simulink" valign="middle"></a>
  <a href="https://docs.ros.org/"><img src="https://img.shields.io/badge/ROS2-Supported-blue" alt="ROS 2" valign="middle"></a>
  <a href="https://mujoco.readthedocs.io/"><img src="https://img.shields.io/badge/MuJoCo-Integrated-green" alt="MuJoCo" valign="middle"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-red" alt="License" valign="middle"></a>
  <a href="https://doi.org/10.5281/zenodo.19422874"><img src="https://zenodo.org/badge/1200109573.svg" alt="DOI" valign="middle"></a>
  <a href="https://la.mathworks.com/matlabcentral/fileexchange/183593-sim2real-control-framework-unitree-g1-simulink-ros2-mujoco"><img src="https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg" alt="File Exchange" height="20" valign="middle"></a>

</p>

---

## Table of Contents

1. [Introduction](#introduction)
2. [Framework Overview](#framework-overview)
3. [Representative Example: Ankle Motion](#representative-example-ankle-motion)
4. [Repository Structure](#repository-structure)
5. [Getting Started](#getting-started)
6. [How to Use](#how-to-use)
7. [Troubleshooting](#troubleshooting)
8. [Technical Notes](#technical-notes)
9. [Future Work](#future-work)
10. [Technologies Used](#technologies-used)
11. [Contact](#contact)
12. [Citation](#citation)
13. [License](#license)
14. [Acknowledgments](#acknowledgments)
15. [References](#references)

---

## Introduction

This repository presents Version 1.0 of a MATLAB/Simulink-based Sim2Real framework for the Unitree G1 humanoid robot, integrating MuJoCo and ROS 2 within a unified workflow for controller development, simulation-based validation, visualization, and real-robot deployment. The main objective of this repository is to provide a clean and control-oriented framework that preserves a common high-level interface across both simulation and real-robot execution backends.

---

## Framework Overview

The core idea of the framework is to allow the user to develop and organize control logic in MATLAB/Simulink, validate it in MuJoCo, and then transition toward ROS 2-based execution on the real Unitree G1 while maintaining a common structure. At the center of the repository is a Sim2Real Variant Subsystem, which enables switching between:

- **MuJoCo:** for simulation-based development and testing
- **ROS 2:** for communication and deployment with the real robot

<p align="center">
  <img src="images/Sim2Real.png" alt="Sim2Real Logo" width="300">
</p>

This design keeps the overall workflow modular, structured, and reusable. 

---


## Representative Example: Ankle Motion

This repository includes a standard ankle-motion command task example used to validate the Sim2Real workflow in a simple and clear way. In this example, the goal is to show that the same high-level workflow can be reused across simulation and real-robot execution without changing the overall organization of the framework. This also highlights the simplicity and modularity of the framework from a block-based perspective, where new control implementations can be tested through a straightforward procedure: select the execution mode, update the model, and run it.

https://github.com/user-attachments/assets/04d95202-4c3e-444c-940a-4de99ef791b5

---

## Repository Structure

The repository is organized as follows:

```text
.
├── docs/                # GitHub Pages source files for the project website
├── images/              # Figures, logos, and visual assets used in the README and documentation
├── resources/           # Main technical folder of the project
│   ├── examples/        # Example files built on top of the original Sim2Real framework (ankle-motion)
│   ├── MuJoCo files/    # MuJoCo simulation resources, XML robot model, meshes, and related files
│   ├── ROS 2 files/     # Custom Unitree ROS 2 messages and scripts for message generation/integration
│   └── Sim2Real files/  # Core reusable Sim2Real base, Variant Subsystem, and support files
├── videos/              # Video assets and demonstration media used by the project
├── Abstract.pdf         # Project abstract / submission summary
├── ICRA 2026 poster.pdf # Poster version 1.0 of the project
├── CITATION.cff         # Citation metadata for academic referencing
├── LICENSE              # Apache-2.0 license
└── README.md            # Main project documentation
```

In addition to the Variant Subsystem logic, the repository is organized around three main technical folders that support the full workflow depending on the selected `RUN_MODE`:

- `MuJoCo files/` contains the simulation-side resources used when the framework runs in MuJoCo. This includes the robot XML model, auxiliary files, and the `meshes/` folder, which must remain in the same directory as the XML for the model to load correctly. The MuJoCo model is based on the [Unitree G1 model from MuJoCo Menagerie](https://github.com/google-deepmind/mujoco_menagerie/tree/main/unitree_g1), but it was modified for this project. In particular, torso attachment points were added so the robot can be supported by a virtual crane during initialization. This was done to reproduce the same practical procedure used on the real robot, which is initially started while suspended. The MuJoCo-side environment therefore includes both the modified XML and a control function inside the MuJoCo SUBSYSTEM to actuate the virtual crane for lifting, lowering, and releasing the robot.
- `ROS 2 files/` contains the communication-side resources used when the framework runs with the real robot. This includes the `unitree_hg` custom message package required for this platform, as well as MATLAB scripts for generating and integrating the custom ROS 2 messages used by the Simulink model.
- `Sim2Real files/` contains the core reusable base of the framework. This is the main folder for building new implementations on top of the repository. It includes the base Simulink model `Sim2Real_variant_subsystem.slx` together with the live scripts that initialize and configure the environment:
  - `launcher.mlx`: main initialization script that calls the other required live scripts and prepares the model workspace.
  - `sim2real_config.mlx`: defines the main configuration parameters used by the framework.
  - `bus_definitions.mlx`: creates the Simulink bus objects used to keep signal organization structured and consistent.
  - `g1_constraints.mlx`: defines joint limits, channel groupings, and constraint-related parameters for the Unitree G1.

Together, these folders provide the base structure for developing new control implementations in a modular way. The `Sim2Real files/` folder defines the reusable framework itself, while the `MuJoCo files/` and `ROS 2 files/` folders complement that base according to the backend selected through `RUN_MODE`.

---

## Getting Started

This section outlines the required software, toolboxes, platform notes, installation steps, and initial configuration needed to set up the repository and begin using the framework.

### Platform and Compatibility

The framework is intended to be conceptually portable across operating systems. However, at the current stage of development, the workflow has been primarily tested on Windows 11, and this is the recommended environment for reproducing the setup described in this repository.

Additional notes:

- The MuJoCo Simulink Blockset has also been reported as tested on Ubuntu 20.04 and Ubuntu 22.04.
- ROS 2 is generally available on Windows, Linux, and macOS.
- In practice, support on Linux and macOS may be more limited depending on the toolchain, compiler, and integration details.

### Requirements

Before using the framework, make sure the following software is available on your machine:

- MATLAB R2025b
  - This workflow is intended for the desktop version of MATLAB. MATLAB Online is not supported.
- MuJoCo 3.3.2 
- Python 3.9 or 3.10
- Visual Studio 2022 or newer with C++ support
- Visual Studio Code
- A machine with:
  - A dedicated GPU for smoother MuJoCo simulation
  - A reasonably strong CPU for compilation and simulation tasks (MATLAB/Simulink workflows are primarily CPU-based)
- ROS 2 Jazzy Jalisco
  - This is the ROS 2 distribution used in the current MATLAB / ROS Toolbox workflow.

### Required MATLAB Toolboxes

The following MATLAB products are required for the current workflow:

- Simulink
- Simulink Coder
- MATLAB Coder
- GPU Coder
- ROS Toolbox
- Parallel Computing Toolbox
- Aerospace Toolbox
- Aerospace Blockset

### Optional MATLAB Toolboxes

The following products may be useful for future extensions, but are not mandatory for the current base setup:

- Computer Vision Toolbox
- Robotics System Toolbox
- Control System Toolbox

### Development Tools Setup

#### Visual Studio 2022 or newer

Install Visual Studio with the Desktop development with C++ workload enabled. In the Visual Studio Installer, go to Workloads, find and select Desktop development with C++, and make sure the following components are available:

- MSVC C++ compiler tools
- Windows SDK
- C++ build tools

If MATLAB does not detect the compiler correctly after installation, run the following commands in the MATLAB Command Window:

```matlab
mex -setup c++
mex -setup c
```

### MuJoCo Installation

To install the MuJoCo Simulink integration, follow the setup instructions provided in the [MuJoCo Simulink Blockset repository](https://github.com/mathworks-robotics/mujoco-simulink-blockset/tree/main). In addition, install the MuJoCo Python package from PowerShell:

```powershell
py -m pip install mujoco
py -m pip show mujoco
```

The second command is useful to verify that MuJoCo was installed correctly in the active Python environment.

### ROS Toolbox Setup

Install ROS Toolbox from the MATLAB Add-On Explorer, and make sure your system satisfies the official [ROS Toolbox system requirements](https://la.mathworks.com/help/ros/gs/ros-system-requirements.html). If ROS-related features do not work correctly, recreate the Python environment from MATLAB by going to Home > Settings > ROS Toolbox and explicitly pointing it to your local Python installation. A typical path looks like this:

```text
C:\Users\YOUR_USERNAME\AppData\Local\Programs\Python\Python39\python.exe
```

### ROS 2 Custom Messages

This framework uses the `unitree_hg` custom message package for ROS 2 communication. To generate the custom messages:

1. Run the script: `unitree_hg_msgs_creation.m`

2. Download the [unitree_hg](https://github.com/unitreerobotics/unitree_ros2/tree/master/cyclonedds_ws/src/unitree/unitree_hg) folder from the Unitree ROS 2 repository and place it here.

```text
C:\matlab_ros2_custom_msgs\src\unitree_hg
```

3. Then run the script: `generate_custom_msgs.m`

> **Note**  
> The exact custom message generation workflow is tied to the contents of the `ROS 2 files` folder in this repository.

### Initial Verification

Before attempting a full run, verify the following:

- MATLAB opens correctly and recognizes the configured C/C++ compiler.
- MuJoCo is installed in Python and visible from the intended environment.
- ROS Toolbox is installed and using the correct Python interpreter.
- The custom `unitree_hg` messages generate without errors.
- The main Simulink framework opens successfully.
- The MuJoCo-related MEX files are compiled and available.

### Recommended Windows Performance Settings

For better simulation performance on Windows, the following settings are recommended:

- Set Windows power mode to Best performance
- In the NVIDIA Control Panel:
  - Go to Manage 3D settings
  - Set Preferred graphics processor to High-performance NVIDIA processor
  - Apply the same preference under Program Settings if needed
- In the MuJoCo Plant block:
  - Set FPS to 30
  - Disable Depth output
  - Disable VSync

---

## How to Use

This section describes the basic execution workflow once the environment has already been configured.

### Basic Workflow

1. Open the main Simulink framework contained in the `Sim2Real files` folder.
2. Select the desired execution backend through the `RUN_MODE` setting inside the framework.
3. After changing the execution mode, press: `Ctrl + D` to update the model.
4. Run the framework directly from Simulink (`Run`).

> **Important**  
> Do not rely on an external launcher for the main workflow. The intended procedure is to open the Simulink model and press Run from there.

### Run in RUN_MODE: MuJoCo
To run the framework in simulation:

1. Open the main Simulink model.
2. Set `RUN_MODE` to the MuJoCo backend.
3. Press `Ctrl + D`.
4. Run the model.
5. Use the example files in the `examples` folder as references for minimal demonstrations and extensions.

### Run in RUN_MODE: ROS

To run the framework on the real Unitree G1 platform:

1. Make sure the robot is in development mode.
2. On the robot controller, enter development mode using `R2 + L2` for 20 seconds.
3. Confirm that the ROS 2 communication environment is available and that the expected topics are active.
4. Set `RUN_MODE` to the ROS 2 backend in Simulink.
5. Press `Ctrl + D`.
6. Run the model directly from Simulink.

> **Important**  
> When running on the real robot, keep the workflow focused on the active Simulink session. Based on the current setup notes, behavior may become intermittent if the workflow is not kept centered on the Simulink execution tab.

### Robot-Side Networking Note

For lower-latency and more stable communication, this workflow is intended to be used over Ethernet when running the model on the real robot. Wireless communication may also be possible, but it can introduce additional latency or instability depending on the network conditions.

If communication with the robot does not work correctly, confirm the Ethernet configuration, robot network settings, and ROS 2 middleware setup before running the model. A manual IPv4 configuration may be required on the host machine. The exact subnet and IP range can vary depending on the robot and network configuration. In the setup used for this project, addresses in the form `192.168.123.x` were used, where `x` is a valid host number, for example `192.168.123.100`. A typical Windows navigation path for manual IPv4 configuration is:

`Control Panel → Network and Internet → Network and Sharing Center → Change adapter settings → Ethernet → Properties → Internet Protocol Version 4 (TCP/IPv4) → Use the following IP address`

---

## Troubleshooting

This section collects the main setup and runtime issues observed during development, together with their current workarounds.

### MATLAB does not detect the C/C++ compiler

If MATLAB does not properly recognize the installed compiler, run:

```matlab
mex -setup c++
mex -setup c
```

Then restart MATLAB and verify that Visual Studio is selected as the active compiler.

### `mexhost` / `MATLABMexHost.exe` error in `mj_initbus.m`

A possible issue in the MuJoCo blockset setup is a failure related to `mexhost`, where MATLAB cannot launch the isolated external MEX process.

A representative error may mention:

```text
MATLABMexHost.exe
CreateProcessW
The parameter is incorrect [system:87]
```

In this case, a temporary workaround is to edit:

```text
/blocks/mj_initbus.m
```

and replace its behavior with a direct call to the MEX function:

```matlab
function [a,b,c,d,e] = mj_initbus(xmlPath)
% Temporary workaround: bypass mexhost and call MEX directly
[a,b,c,d,e] = mj_initbus_mex(xmlPath);
end
```

This workaround bypasses the external `mexhost` process and calls the MEX directly from MATLAB.

### ROS 2 custom message build fails because `source` already exists

If `generate_custom_msgs.m` fails with an error similar to this:

```text
Error using ros.internal.ROSProjectBuilder
The directory 'C:\Users\USERNAME\source' already exists, will cause the build in directory 'C:\matlab_ros2_custom_msgs\src\matlab_msg_gen\win64' to fail.
Remove or rename 'C:\Users\USERNAME\source', and retry the command.
```

then:

1. Go to your user folder:

```text
C:\Users\YOUR_USERNAME\
```

2. Find the folder named:

```text
source
```

3. Rename it to something like:

```text
source_old
```

Do not delete it if it still contains MuJoCo-related files.

4. If Windows does not allow the rename close MATLAB or restart the PC.

5. Then run again:

```matlab
generate_custom_msgs
```

### `Undefined C++ MEX function 'mj_initbus_mex'`

If Simulink reports:

```text
Undefined C++ MEX function 'mj_initbus_mex'
```

this may appear after the `source` folder rename or after a broken build state.

In that case, rerun the MuJoCo blockset build scripts:

```matlab
install
setupBuild
build
```

After rebuilding, reopen the model and test again.

### ROS communication instability

If ROS communication behaves unexpectedly:

1. Reset the network connection.
2. Restart the PC.
3. Switch the middleware to:

```text
rmw_cyclonedds_cpp
```

4. Recreate the ROS Toolbox Python environment if necessary.


---

## Technical Notes

This section clarifies a few implementation details that may raise questions when exploring the framework internals.

### Execution Model

The framework is intended to be executed from the main Simulink model. The expected workflow is:

1. Open the model
2. Choose the backend with `RUN_MODE`
3. Update the model with `Ctrl + D`
4. Press Run

The current setup notes explicitly recommend not relying on a separate launcher for the main workflow.

### Custom Messages and ROS 2 Integration

The ROS 2 backend depends on the `unitree_hg` custom message package. Message generation is therefore part of the setup process and is not optional for the real-robot communication pipeline.

### Real Robot Operation

When running on the real robot:

- Make sure the robot is in development mode
- Verify the network configuration
- Verify the relevant ROS 2 topics before running
- Keep the execution focused on the active Simulink workflow

### FAQ on Channel Mapping and Joint Usage

The current framework uses different channel counts depending on the role of each signal group:

- 29 channels correspond to the actively grouped body joints used by the current control structure: 6 for the left leg, 6 for the right leg, 3 for the waist, 7 for the left arm, and 7 for the right arm.
- 35 channels appear in internal constraint-related definitions because the framework reserves additional slots beyond the main 29 body joints, including placeholder entries for joints that are not currently used.
- 43 channels appear in the full command interface because the command bus also includes hand-related channels in addition to the body joints.
- Hand-related channels are present for interface completeness and future extensibility, but in the current version of the framework they are not actively commanded, so they remain zero.
- Waist roll and waist pitch are disabled in the current setup. Their limits are constrained in the framework configuration, and they are also effectively blocked in the MuJoCo XML model itself through near-zero joint ranges. Therefore, enabling them would require modifying both the constraint definitions and the XML model. As a concrete example, if `waist_roll_joint` is to be enabled, the corresponding joint definition in the MuJoCo XML must also be modified. For instance, this section:

```xml
<body name="waist_roll_link" pos="-0.0039635 0 0.035">
  <inertial pos="0 -0.000236 0.010111" quat="0.99979 0.020492 0 0" mass="0.047"
    diaginertia="7.515e-06 6.40206e-06 3.98394e-06" />
  <joint name="waist_roll_joint" pos="0 0 0" axis="1 0 0" limited="true" range="0 1e-6"
    actuatorfrcrange="-50 50" class="torso_motor"/>  <!-- range="-0.52 0.52" -->
```

would need to be updated by replacing `range="0 1e-6"` with `range="-0.52 0.52"` and removing `limited="true"`, in addition to updating the corresponding framework-side constraint definitions.
- Why must the files remain inside `resources`, and what must be updated if filenames change? The initialization logic assumes `resources` as the project root. Starting from the `.slx` model location, the `InitFcn` traverses upward until it finds the parent folder named `resources`, and then performs a recursive search inside that directory to locate `unitree_G1.xml`. The `.slx` model and `launcher.mlx` must remain in the same folder, since the launcher is referenced explicitly from the model directory. If the launcher filename is changed, the corresponding line in the `InitFcn` must also be updated (currently line 56). Likewise, if any additional live scripts called from the launcher are renamed, their names must also be updated inside `launcher.mlx`.
  
---

## Future Work

Planned future developments include:

- Adding more complete examples and demonstrations
- Improving integration with additional sensors and subsystems
- Extending the framework with more advanced humanoid control modules
- State-machine-level monitoring of robot operating modes
- Integration of finger actuation and finger pressure sensing
- Battery and system-status supervision
- Camera and LiDAR integration

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
Electronic Engineer, M.Sc. in Electronic and Computer Engineering, and Admitted to the Ph.D. in Engineering 
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

If you use this repository in academic work, research projects, technical reports, or derivative software developments, please cite the archived Zenodo release associated with this project.

This repository includes a `CITATION.cff` file in the root of the repository so that GitHub can expose a standard citation format through the **Cite this repository** feature. In addition, the public release of this project has been archived in Zenodo and assigned a DOI for versioned citation.

### How to cite

The repository can be cited as software in the following format:

```bibtex
@software{trochez2026sim2real,
  author       = {Leffer Trochez and Nicanor Quijano and Jorge Lopez-Jimenez and Carlos Francisco Rodriguez},
  title        = {A MATLAB/Simulink-Based Sim2Real Control Framework for the Unitree G1 Using ROS 2 and MuJoCo},
  year         = {2026},
  version      = {1.0},
  doi          = {10.5281/zenodo.19422874},
  url          = {https://doi.org/10.5281/zenodo.19422874}
}
```
### Citation note


GitHub supports citation outputs based on `CITATION.cff`, including APA and BibTeX. Zenodo archives public releases of the repository and assigns a persistent DOI for version-specific citation.

---

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for the full license text.

---

## Acknowledgments

The author would like to express sincere gratitude to [Manoj Velmurugan](https://vmanoj1996.github.io/) for having planted the initial seed of this work through the MuJoCo Simulink Blockset, which provided an important foundation and early inspiration for the development of this framework.

In addition, the author gratefully acknowledges [Álvaro Achury](https://academia.uniandes.edu.co/AcademyCv/au.achury33), leader of the laboratories and caretaker of the humanoid robot platform at Universidad de los Andes (AURA), for his valuable assistance in the handling and operation of the real robot platform.

Finally, the author also acknowledges the use of [ChatGPT (OpenAI)](https://openai.com/) as an auxiliary tool to improve selected visual materials and support parts of the code structuring process. All technical decisions, implementation, validation, and final content were carried out and verified by the author.

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
