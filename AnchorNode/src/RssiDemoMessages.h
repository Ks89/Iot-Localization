#ifndef RSSIDEMOMESSAGES_H__
#define RSSIDEMOMESSAGES_H__

enum {
  AM_RSSIMSG = 10
};

typedef nx_struct RssiMsg{
  nx_int16_t rssi;
} RssiMsg;

#endif //RSSIDEMOMESSAGES_H__
