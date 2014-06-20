#include "NodeMessage.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration MobileMoteAppC {
}

implementation {
  components SerialPrintfC;
  components MainC;  
  components new AMSenderC(AM_RSSIMSG);
  components new AMReceiverC(AM_RSSIMSG);
  components new TimerMilliC() as TimeOut250;
  components new TimerMilliC() as TimeOut180;
  components ActiveMessageC;
  components MobileMoteC as App;
  components RandomC;
  
  App.RadioControl -> ActiveMessageC;
  App.Boot -> MainC.Boot;
  App.TimeOut250 -> TimeOut250;
  App.TimeOut180 -> TimeOut180;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;
 
  App.Random -> RandomC;
}
