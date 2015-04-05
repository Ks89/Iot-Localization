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
