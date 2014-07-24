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
	{20, 10},
	{40, 10},
	{60, 10},
	{80, 10},
	{20, 40},
	{40, 40},
	{60, 40},
	{80, 40}
};   

#define REQ 1
#define RESP 2

#define MOBILE 1
#define ANCHOR 2
#define SYNCPACKET 3

#define SEND_INTERVAL_ANCHOR 250
#define WAIT_BEFORE_SYNC 10000
#define AM_RSSIMSG 10


#endif
