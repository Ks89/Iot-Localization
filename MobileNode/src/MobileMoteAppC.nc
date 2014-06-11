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
  components new TimerMilliC() as MilliTimer;
  components CC2420ActiveMessageC, ActiveMessageC;
  components MobileMoteC as App;
  
  
  //Radio Control
  App.RadioControl -> ActiveMessageC;
  App.Boot -> MainC.Boot;
  App.MilliTimer -> MilliTimer;
  
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;

  //Interfaces to access package fields
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;
  App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;
  
}
