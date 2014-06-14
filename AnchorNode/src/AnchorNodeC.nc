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
	    interface Timer<TMilli> as MilliTimer;
	}
}

implementation {
  
  uint16_t RSSI;
  uint16_t source;
  
  message_t packet;
  nodeMessage_t* message; 
 
    
  void sendPacket();
  
  
  event void Boot.booted() {
	printf("Anchor Mote %d booted...\n", TOS_NODE_ID);
	call RadioControl.start();
  }
  
    //***************** SplitControl interface ********************//
  event void RadioControl.startDone(error_t err){
  	call MilliTimer.startOneShot(SEND_INTERVAL_ANCHOR);
  }
  
  event void RadioControl.stopDone(error_t err){}
  
  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	sendPacket();
  }
  
  //*********************************************************//
  void sendPacket() {
  	
	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
	mess->msg_type = REQ;
	mess->mode_type = ANCHOR;
	 
	printf("Try to broadcast the message... \n");
	call AMSend.send(AM_BROADCAST_ADDR,&packet,sizeof(nodeMessage_t));
	call MilliTimer.startOneShot(SEND_INTERVAL_ANCHOR);
	printf("Starting new timer...");

  }
 
  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {

    if(&packet == buf && err == SUCCESS ) {
    
    }

  }
}
