/*
Copyright 2014-2015 Stefano Cappa, Jiang Wu, Eric Scarpulla
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#ifndef NODEMESSAGE_H
#define NODEMESSAGE_H

typedef nx_struct NodeMessage {
	nx_uint8_t mode_type;
	nx_uint8_t msg_type;
	nx_float x;
	nx_float y;
} nodeMessage_t;

typedef struct coordinate {
  	float x;
  	float y;
} coord;

coord anchorCoord[8] = {
	{5, 5},
	{10, 5},
	{15, 5},
	{20, 5},
	{5, 10},
	{10, 10},
	{15, 10},
	{20, 10}
};  

#define NUMCOORD 9
coord mobileCoord[NUMCOORD] = {
	{6, 6},
	{8, 8},
	{12, 6},
	{12, 7},
	{14, 8},
	{16, 8},
	{18, 12},
	{19, 10},
	{22, 9}		
};


#define BEACON 1
#define SWITCHOFF 2
#define SYNCPACKET 3

#define MOVE_INTERVAL_MOBILE 1000
#define SEND_INTERVAL_ANCHOR 250
#define RECEIVE_INTERVAL_ANCHOR 180
#define AM_RSSIMSG 10

#endif
