#ifndef NODEMESSAGE_H
#define NODEMESSAGE_H

typedef nx_struct NodeMessage {
	nx_uint8_t mode_type;
	nx_uint8_t msg_type;
	nx_int16_t rssi;
} nodeMessage_t;

#define REQ 1
#define RESP 2

#define MOBILE 1
#define ANCHOR 2

enum{
AM_RSSIMSG = 10
};

#endif
