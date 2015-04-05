/*
Copyright 2014-2015 Stefano Cappa, Jiang Wu, Eric Scarpulla
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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
