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
	components ActiveMessageC;
	
	  //Send and Receive interfaces
	  App.Boot -> MainC.Boot;
	  App.RadioControl -> ActiveMessageC;
	  App.AMSend -> AMSenderC;
	  App.Packet -> AMSenderC;
	
	  //Interfaces to access package fields
	  App.AMPacket -> AMSenderC;
	  //Timer interface
	  App.TimeOut -> TimeOut;

}
