#include "NodeMessage.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration AnchorNodeAppC {} 

implementation {
	components MainC;
	components SerialPrintfC;
	components AnchorNodeC as App;
	components new AMSenderC(AM_RSSIMSG);
	components new AMReceiverC(AM_RSSIMSG);
	components new TimerMilliC() as TimeOut;
	components new TimerMilliC() as Time10Sec;
	components new TimerMilliC() as Time10;
	components ActiveMessageC;
	
	  App.Boot -> MainC.Boot;
	  App.RadioControl -> ActiveMessageC;
	 
	  App.AMSend -> AMSenderC;
	  App.Packet -> AMSenderC;
	  App.Receive -> AMReceiverC;
	  App.AMPacket -> AMSenderC;
	 
	  App.TimeOut -> TimeOut;
	  App.Time10Sec -> Time10Sec;
	  App.Time10 -> Time10;

}
