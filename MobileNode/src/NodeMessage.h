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

coord mobileCoord[6] = {
	{4, 8},
	{8, 8},
	{12, 8},
	{12, 10},
	{15, 8},
	{22, 8}		
};


#define REQ 1
#define RESP 2

#define MOBILE 1
#define ANCHOR 2
#define SYNCPACKET 3

#define MOVE_INTERVAL_MOBILE 1000
#define SEND_INTERVAL_ANCHOR 250
#define RECEIVE_INTERVAL_ANCHOR 180
#define AM_RSSIMSG 10

#endif
