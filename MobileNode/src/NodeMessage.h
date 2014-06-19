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

coord mobileCoord[16] = {
	{10, 20},
	{20, 30},
	{30, 30},
	{40, 20},
	{50, 10},
	{60, 10},
	{60, 30},
	{60, 20},
	{70, 20},
	{70, 30},
	{80, 40},
	{90, 30},
	{100, 20},
	{100, 20},
	{120, 30},
	{140, 10}		
};


#define REQ 1
#define RESP 2

#define MOBILE 1
#define ANCHOR 2

#define MOVE_INTERVAL_MOBILE 1000
#define AM_RSSIMSG 10

#endif
