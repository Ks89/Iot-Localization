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
	{14, 7},
	{16, 8},
	{18, 8},
	{20, 8},
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
