#include "RssiDemoMessages.h"
#include "message.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration RssiBaseAppC {
} implementation {
  components BaseStationC;
components PrintfC;
  components RssiBaseC as App;

  components CC2420ActiveMessageC;
  App -> CC2420ActiveMessageC.CC2420Packet;
  App-> BaseStationC.RadioIntercept[AM_RSSIMSG];
}
