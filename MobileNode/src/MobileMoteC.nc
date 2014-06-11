#include "ApplicationDefinitions.h"
#include "NodeMessage.h"
#include "Timer.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h" 

module MobileMoteC {
  
  uses {
  		interface SplitControl as RadioControl;
  		interface Boot;
	    interface AMPacket;
	    interface AMSend;
	    interface Packet;
	    interface Receive;
	    interface Timer<TMilli> as MilliTimer;
		interface CC2420Packet;
	}
}


implementation { 
  uint16_t RSSI;

  message_t packet;
  
  void calcDistance(am_addr_t source);
  void sendReq();

  
    //***************** Boot interface ********************//
  event void Boot.booted() {
	printf("Application booted.\n");
	call RadioControl.start();
  }
  
    //***************** SplitControl interface ********************//
  event void RadioControl.startDone(error_t err){
		call MilliTimer.startPeriodic( 0 );
  }
  
  event void RadioControl.stopDone(error_t err){}

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
  	call MilliTimer.stop();
	sendReq();
  }

  void sendReq() {	
  	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
  	
  	printf("Request sended...");
	mess->msg_type = REQ;
	mess->mode_type = MOBILE;
	call AMSend.send(AM_BROADCAST_ADDR, &packet , sizeof(nodeMessage_t));
	call MilliTimer.startPeriodic( SEND_INTERVAL_MS );
  }

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	nodeMessage_t* mess = (nodeMessage_t*) payload;
	
	
	printf("Message received...\n");
	
	if ( mess->msg_type == RESP ) {
		RSSI = mess->rssi;	
		calcDistance(call AMPacket.source(buf));
	}

    return buf;

  }
  void calcDistance(am_addr_t source) {
  	printf("RSSI received: %d from %d\n",RSSI,source);
  	
  }
  
  
}
