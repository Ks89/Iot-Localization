#include "NodeMessage.h" 
#include "Timer.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module AnchorNodeC {
  	uses {
  		interface SplitControl as RadioControl;
  		interface Boot;
	    interface AMPacket;
	    interface AMSend;
	    interface Packet;
	    interface Timer<TMilli> as TimeOut;
	}
}

implementation {
  message_t packet;
    
  void sendPacket();
  
  
  event void Boot.booted() {
	printf("Anchor Mote %d booted...\n", TOS_NODE_ID);
	call RadioControl.start();
  }
  
    //***************** RadioControl interface ********************//
  event void RadioControl.startDone(error_t err){
  	call TimeOut.startOneShot(SEND_INTERVAL_ANCHOR);
  }
  
  event void RadioControl.stopDone(error_t err){}
  
  //***************** MilliTimer interface ********************//
  event void TimeOut.fired() {
	sendPacket();
  }
  
  //*********************************************************//
  void sendPacket() {
  	
	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
	mess->msg_type = REQ;
	mess->mode_type = ANCHOR;
	mess->x = anchorCoord[TOS_NODE_ID].x;
	mess->y = mobileCoord[TOS_NODE_ID].y;
	 
	printf("Try to broadcast the message... \n");
	call AMSend.send(AM_BROADCAST_ADDR,&packet,sizeof(nodeMessage_t));
	
	call TimeOut.startOneShot(SEND_INTERVAL_ANCHOR);
	printf("Starting new timer...");

  }
 
  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {

    if(&packet == buf && err == SUCCESS ) {
    
    }

  }
}
