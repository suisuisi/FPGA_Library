# 2D-median-filter-algorithm-HLS
Using high-level synthesis, develop a hardware version of the 2D median filter algorithm (HLS). Then, apply HLS to accelerate the code utilising FPGA hardware. The hardware implementation should be optimised so that it can denoise the test image in less than 3 milliseconds while consuming less than 25 percent of the available PL resources.


Overview

This project contains the implementation of a 2D Median Filter algorithm using High-Level Synthesis (HLS), which is accelerated using FPGA hardware. The project aims at denoising a test image in less than 3 milliseconds while consuming less than 25 percent of the available PL resources.
Features

    Designed for optimized hardware implementation using Vivado HLS.
    Contains efficient data type management with arbitrary precision data types.
    Employs HLS pragmas to ensure optimal system performance.
    Validated with multiple test cases.

Contents

The repository contains the following:

    Source code files for the 2D Median Filter Algorithm
    C Simulation files
    Co-Simulation files
    Synthesis files
    CSV files containing clean and noisy image data
    Screenshots of the simulation and synthesis process

Setup and Installation

This project has been designed and tested in Vivado HLS. To set up and run the project:

    Clone this repository: git clone <repository_link>
    Open the Vivado HLS software and import the project.
    Load the CSV files containing the image data.
    Run the C Simulation to ensure the algorithm is functioning correctly.
    Proceed with synthesis and co-simulation.

Usage

After importing the project into Vivado HLS:

    Run C simulation to validate the functionality of the median filter.
    Perform the synthesis process to view the resource utilization report and make necessary adjustments.
    Perform Co-simulation to ensure the synthesised design behaves as expected.

Please note: You may need to adjust the HLS pragmas in the code for optimal performance based on the specific FPGA board being used.
Results

The final design, when applied on test data, achieved denoising in less than 12 milliseconds with an overall PL resource utilization of approximately 13%.


License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details

Acknowledgements
Thanks to everyone who contributed to the project and OpenAI for providing the necessary support and knowledge.
