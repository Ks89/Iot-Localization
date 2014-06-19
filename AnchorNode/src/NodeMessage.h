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

#define REQ 1
#define RESP 2

#define MOBILE 1
#define ANCHOR 2
#define SYNCPACKET 3

#define SEND_INTERVAL_ANCHOR 250
#define WAIT_BEFORE_SYNC 5000
#define AM_RSSIMSG 10
#define TIMESLOT 7


#endif
