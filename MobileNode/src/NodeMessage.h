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
	{1, 0},
	{1, 1},
	{1, 2},
	{1, 3},
	{-1, 0},
	{-1, 1},
	{-1, 2},
	{-1, 3}
};  

coord mobileCoord[5] = {
	{0, 1},
	{1, 1},
	{1, 0},
	{1, 2},
	{2, 1}
};


#define REQ 1
#define RESP 2

#define MOBILE 1
#define ANCHOR 2

#define MOVE_INTERVAL_MOBILE 1000
#define AM_RSSIMSG 10

#endif
