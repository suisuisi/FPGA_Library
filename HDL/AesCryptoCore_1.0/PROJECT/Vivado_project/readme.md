# Vivado project template

This directory structure serves as a template for versioning Vivado project with minimum set of sources. This is one of the approaches recommended by Xilinx in [UG892](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_2/ug892-vivado-design-flows-overview.pdf). Here is a quick run-down of how different project parts are versioned in this approach:

| Parts      | Approach |
| ----------- | ----------- |
| Project, runs      | All project-related content like xpr file, run results, run settings, source sets are (re)created by proj/create_project.tcl. All generated content will be placed into proj/, but only create_project.tcl is versioned. An example is provided in the template and must be manually updated whenever there are changes that must be versioned.      |
| Block design   | Only present in project based on block design. Exported as a tcl script to src/bd/. Create_project.tcl should call the bd tcl to re-create the block design during project re-generation.       |
| Design sources | VHDL, Verilog sources are versioned in src/hdl. All files found there are automatically added to the project by create_project.tcl upon re-generation. |
| Design constraints | XDC constraints are versioned in src/constraints. All files found there are automatically added to the project by create_project.tcl upon re-generation. |
| SDK projects | Application projects are versioned in sdk/. |
| SDK BSPs | The mss file of base support packages are versioned in sdk/<subfolder>. The generated sources are not versioned and their re-generation must be manually requested after import. |
| SDK workspace | SDK workspace is targeted to sdk/. However, the workspace itself is not versioned and must be re-created manually by importing all the application projects and BSPs in sdk/. |
| Custom IP definitions | Versioned in repo/local. Other libraries, like [vivado-library](https://github.com/Digilent/vivado-library/) can be included as Git submodules in repo/.|

 

# Workflows
## Save
 - Build bitstream
 - Export hardware definition to hw_handoff/
 - Export block design tcl to src/bd/
 - Manually edit create_project.tcl to include any changes in project or run settings
 - Commit, push

## (Re)Load
 - Browse to proj/. Remove ALL generated, non-versioned content with cleanup.cmd. Anything not saved with the Save workflow will be deleted
 - Open Vivado GUI, Tools, Run Script..., select proj/create_project.tcl.
 - Watch for errors in the console. If none, the project should be re-created and opened.

## SDK
 - Upon fresh clone the workspace needs to be re-created. Choose Import, Existing Projects into Workspace, sdk/ as root directory. Tick projects, BSPs and HW platforms you wish to import.
 - If you have custom repositories for drivers or libs, add them with Xilinx, Repositories, Local Repositories.
 - Import new hardware changes (if any) by right-clicking on the imported hw platform and choosing Change Hardware Platform Specification. Choose the hdf file in hw_handoff/.
 - Right-click the BSP an choose Re-generate BSP sources.
 - Choose Project/Build All

## Folder Organization
For illustrative purposes the current organization of the repository is shown below.

 ```
<project_name>
|--hw_handoff
|  `--<top_level>.hdf
|--proj
|  |--cleanup.cmd
|  |--cleanup.sh
|  `--create_project.tcl
|--repo
|  |--if
|  |  `--<interface_v1_1>
|  |     |--<interface>.xml
|  |     `--<interface_rtl>.xml
|  `--ip
|     `--<ip_v3_8>
|        |--docs
|        |  `--<ip_v3_8>.pdf
|        |--src
|        |  |--ip
|	     |  |  `--<fifo>
|        |  |     `--<fifo>.xci
|        |  |--<source>.vhd
|        |  `--<edid>.txt
|        |--xgui
|        |  `--<ip_v3_8>.tcl
|        `--component.xml
|--sdk
|  |--<hw_platform>
|  |--<project_bsp>
|  |  |--.cproject
|  |  |--.project
|  |  |--.sdkproject
|  |  |--Makefile
|  |  `--system.mss
|  `--<project>
|     |--src
|     |  |--<whatever>
|     |  |  `--<whatever>.c
|     |  |--<main>.c
|     |  `--lscript.ld
|     |--.cproject
|     `--.project
|--src
|  |--bd
|  |  `--<bd_name>.tcl
|  |--hdl
|  |  `--<iic_slave>.vhd
|  |--constraints
|  |  `--<board>.xdc
|  |--ip
|  `--others
|     `--<mig>.prj
|--.gitignore
|--depedences.txt
`--readme.txt
```

## Process for setting up a new project
1.Initialize a new global repository
* Within the appropriate folder initialize a bare git repository:
* git –bare init

2.Initialize a new local repository
* a.Within your working directory clone a new git repository
* git clone
* b.Go to your cloned local repository and when inside proj folder make sure the directory does not contain a project with the same name. You may run cleanup.cmd (linux: cleanup.sh) to delete everything except the utility files
* c.Either source proj/create_project.tcl in Vivado Tcl shell or use Run Script in the GUI

3.Now you can work on your newly created project and modify/populate your local repository with the files you wish to add to the project and hence submit to version control

4.Once project editing completed, to make sure the changes are checked into Git:
* a. Export block design, if there is one, to src/bd/. By having the block design opened in Vivado GUI go to File->Export->Export Block Design
* b. If there are changes to the Vivado project settings (e.g. Implementation strategy changed to PerformanceExplore) go to File->Write Project TCL and export it anywhere. Copy relevant Tcl commands to proj/create_project.tcl.
Note: this is the only project-relevant file checked into Git
* c. Make sure all the new sources have been created in the src/ folder and that the existing ones have been modified and saved to the src/ folder
    * i. Any IPs instantiated OUTSIDE BLOCK DESIGNS need to be created in src/ip/
    * ii. Use the IP Location button in the IP customization wizard to specify a target directory
    * iii. Only *.xci and *.prj files are checked in from src/ip/
    * iv. Design files go into src/hdl/, constraint files into src/constraints
    * v. If using MIG outside block designs, manually move the MIG IP to the src/ip/ folder
* d. Stage all the modifications and new files. With the git bash inside your local repository type:
git add –all 
* e. Commit the staged modifications:
git commit –m “Your world-saving modification” –m “Your uber-cool file added” –m “This is a comment”
* f. Last you need to push the local repository changes to the global repository
git push

It is strongly advised to commit and push your design efforts often. This provides as a backup method as well as gives the developer the ability to revert to previous changes with higher resolution.

## Tutorial
* https://www.atlassian.com/git/tutorials 

## Platforms
* https://www.atlassian.com/git
* https://www.sourcetreeapp.com/
* https://desktop.github.com/

 