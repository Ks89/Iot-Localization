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
  components ActiveMessageC;
  components MobileMoteC as App;
  components RandomC;
  
  
  //Radio Control
  App.RadioControl -> ActiveMessageC;
  App.Boot -> MainC.Boot;
  App.TimeOut250 -> TimeOut250;
  
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;

  //Interfaces to access package fields
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;
 
 App.Random -> RandomC;
}
