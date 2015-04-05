# Localization of a Mobile Node with a Wireless Sensor Network 
Project for the course called "Internet of Things" at Politecnico di Milano.

## Objectives
Simulate a WSN composed by 8 fixed anchors and a mobile node, which moves along a known trajectory (of your choice).<br>
The anchors periodically broadcast beacons, which are received by the mobile node. Upon reception, the mobile node estimates the RSSs of the beacons, converts it into distance measures and triangulates its position by using the best three beacons.
### Requirements:
1. Create a specific component to simulate RSS estimation. The component acts as an oracle, knowing the trajectory of the mobile node and the position of all the anchors. Use a log-distance path loss model for power-to-distance conversion, e.g. P = P0 + 10log10(d/d0) + v, with v an additive Gaussian noise of known distance.
2. From the estimated RSSI, retrieve a distance measure (only for the best 3 anchor nodes).
3. Use the Gradient Descent triangulation techniques to obtain the position of the mobile node.
4. Compute and plot the localization error VS the Gaussian noise variance v.

## Results

The plot with the localization error on Y and the Gaussian noise variance on X is:

![alt tag](http://www.stefanocappa.it/publicfiles/Github_repositories_images/IotLocalization/1-results.png)
<br>
![alt tag](http://www.stefanocappa.it/publicfiles/Github_repositories_images/IotLocalization/3-cooja-results.png)


## News
- *04/05/2015* - **IOT Localization** 1.0.0 released

## Contents
- 2 projects in one repository. AnchoreNode and MobileNode projects for Eclipse (with Yeti 2 TinyOS plugin).
- Sources
- Binary files ready to use
- Report of the project and the ".csc" simulation's files for Cooja
- Log file

## Future extensions
- [ ] Test this software on real sensors.

## Usage
Step 1. Download Instant Contiki VM [HERE](http://sourceforge.net/projects/contiki/files/Instant%20Contiki/).<br>
Step 2. In the VM, download the ".zip" file from the page "Releases" of this project.<br>
Step 3. Download in ~/git this source code with: git clone <link https of this project> <br>
Step 4. Execute these commands:
```bash
    $ cd ~/git/<name of this project>/AnchorNode
    $ mkdir build
    $ cd build
    $ mkdir telosb
    $ cd ~/git/<name of this project>/MobileNode
    $ mkdir build
    $ cd build
    $ mkdir telosb
```
Step 5. In the downloaded files extracted from the ".zip" copy Binary-files/AnchorNode/main.exe in 
```bash
    $ cp ~/Downloads/<extracted files folder>/Binary-files/AnchorNode/build/telosb/main.exe ~/git/<name of this project>/AnchorNode/build/telosb/main.exe
    $ cp ~/Downloads/<extracted files folder>/Binary-files/MobileNode/build/telosb/main.exe ~/git/<name of this project>/MobileNode/build/telosb/main.exe
```
Step 6. Run Cooja with:
```bash
    $ cd ~/contiki-2.7/tools/cooja
    $ ant run
```
Step 7. In Cooja, load the ".csc" file in the released ".zip", and click on the "Start" button to start the simulation.

![alt tag](http://www.stefanocappa.it/publicfiles/Github_repositories_images/IotLocalization/2-cooja-running.png)

## Eclipse instructions
Step 1. If you want to compile this softwares with Eclipse, download Eclipse C++ [HERE](https://eclipse.org/).<br>
Step 2. Intall Yeti 2 Plugin, using this "Software Site": http://tos-ide.ethz.ch/update/site.xml
Step 3. Import AnchorNode from the downloaded files in ~/git/<name of this project>/AnchorNode in a project
Step 4. Import MobileNode from the downloaded files in ~/git/<name of this project>/MobileNode in a different project
Step 5. Initialize the VM to download TinyOS using this tutrial http://tinyprod.net/repos/debian/ and 
Step 6. Download TinyOS using this tutorial http://tinyos.stanford.edu/tinyos-wiki/index.php/Automatic_installation
Step 7. Restart Eclipse, go in Window->Preferences->TinyOS->Environments->TinyOS 2.x unix-environment and set the path of "TinyOS Root Directory"
Step 8. Include "printf.h" in Project->Properties->TinyOS Build->2.Includes and check that ncc=consider and Include=system
Step 9. Include "math.h" in Eclipse only in the MobileNode's project.



## Images

TODO TODO

## License

Copyright 2014-2015 Stefano Cappa, Jiang Wu, Eric Oswald Scarpulla

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

**Created by Stefano Cappa, Jiang Wu, Eric Scarpulla**
