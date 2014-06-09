#include "RssiDemoMessages.h"

configuration SendingMoteAppC {
}

implementation {
  components ActiveMessageC, MainC;  
  components new AMSenderC(AM_RSSIMSG) as RssiMsgSender;
  components new TimerMilliC() as SendTimer;

  components SendingMoteC as App;

  App.Boot -> MainC;
  App.SendTimer -> SendTimer;
  
  App.RssiMsgSend -> RssiMsgSender;
  App.RadioControl -> ActiveMessageC;
}
