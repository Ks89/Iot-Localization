#ifndef SENDACK_H
#define SENDACK_H

typedef nx_struct my_msg {
	nx_uint8_t msg_type;
	nx_uint16_t msg_id;
	nx_uint16_t value;
	nx_int16_t rssi;
} my_msg_t;

#define REQ 1
#define RESP 2

enum{
AM_MY_MSG = 6,
AM_RSSIMSG = 10
};

#endif
