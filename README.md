# Localization of a Mobile Node with a Sensor Network 
Project for the course of Internet of Things (2014) at Politecnico di Milano.

## Objectives
Simulate a WSN composed by 8 fixed anchors and a mobile node, which moves along a known trajectory (of your choice).<br>
The anchors periodically broadcast beacons, which are received by the mobile node. Upon reception, the mobile node estimates the RSSs of the beacons, converts it into distance measures and triangulates its position by using the best three beacons.
### Requirements:
1. CreateaspecificcomponenttosimulateRSSestimation.The
component acts as an oracle, knowing the trajectory of the mobile node and the position of all the anchors. Use a log-distance path loss model for power-to-distance conversion, e.g. P = P0 + 10log10(d/d0) + v, with v an additive Gaussian noise of known distance.
2. FromtheestimatedRSSI,retrieveadistancemeasure(onlyforthe best 3 anchor nodes).
3. UsetheGradientDescenttriangulationtechniquestoobtainthe position of the mobile node.
4. ComputeandplotthelocalizationerrorVStheGaussiannoise variance v.

## Results

## News

## Features

## Future extensions

## Images

## Usage

## Important things

## License

Copyright 2014-2015 Stefano Cappa, Jiang Wu, Eric Oswald Scarpulla (for Politecnico di Milano)

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
