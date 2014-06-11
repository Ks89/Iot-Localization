#include "ApplicationDefinitions.h"
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
	    interface Receive;
	    interface Packet;
	    interface Timer<TMilli> as MilliTimer;
		interface CC2420Packet;
	}
}

implementation {
  
  uint16_t RSSI;
  uint16_t source;
  
  message_t packet;
  nodeMessage_t* message; 
 
    
  uint16_t getRSSI(message_t *msg);
  void sendPacket();
  
  
  event void Boot.booted() {
	printf("Base booted...\n");
	call RadioControl.start();
  }
  
    //***************** SplitControl interface ********************//
  event void RadioControl.startDone(error_t err){}
  
  event void RadioControl.stopDone(error_t err){}
  
  //***************** Retrieve RSSI Value ******************//
  uint16_t getRSSI(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }

  
  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf, void* payload, uint8_t len) {
	printf("Packet Received...");
	message = (nodeMessage_t*) payload;
	if(message->mode_type == MOBILE) {
		source = call AMPacket.source(buf);
		RSSI = getRSSI(buf);
		printf("RSSI: %d\n",RSSI);
			
		if ( message->msg_type == REQ ) {
			call MilliTimer.startPeriodic( SEND_INTERVAL_MS );
		}
	}
    return buf;


  }
  
  
  
  
  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
  	call MilliTimer.stop();
	sendPacket();
  }
  
  //*********************************************************//
  void sendPacket() {
  	
	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
	mess->msg_type = RESP;
	mess->rssi = RSSI;
	mess->mode_type = ANCHOR;
	 
	printf("Try to send a response to mobile node... \n");
	call AMSend.send(source,&packet,sizeof(nodeMessage_t));


  }
    
  
  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {

    if(&packet == buf && err == SUCCESS ) {
    }

  }
}
