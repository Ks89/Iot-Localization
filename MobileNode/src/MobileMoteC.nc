#include "NodeMessage.h"
#include "Timer.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h" 
#include "math.h"

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
	
  struct rssiArrayElement {
  	int nodeId;
  	int16_t rssiVal;
  };
	 
  struct rssiArrayElement RSSI_array[8];
  struct rssiArrayElement firstEl={-999,-999}, secondEl={-999,-999}, thirdEl={-999,-999};
  
  message_t packet;
  
  void calcDistance();
  void initRssiArray();
  uint16_t getRSSI(message_t *msg);
  
  
    //***************** Boot interface ********************//
  event void Boot.booted() {
	printf("Mobile Mote booted.\n");
	initRssiArray();
	call RadioControl.start();
  }
  
    //***************** RadioControl interface ********************//
  event void RadioControl.startDone(error_t err){}
  
  event void RadioControl.stopDone(error_t err){}

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {  }
  
   //***************** Retrieve RSSI Value ******************//
  uint16_t getRSSI(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	am_addr_t sourceNodeId = call AMPacket.source(buf);	
	nodeMessage_t* mess = (nodeMessage_t*) payload;
	printf("Message received from %d...\n", sourceNodeId);
	mess->rssi = getRSSI(buf);
	
	if ( mess->msg_type == REQ && mess->mode_type == ANCHOR ) {
		
		RSSI_array[sourceNodeId-1].rssiVal = mess->rssi;
		RSSI_array[sourceNodeId-1].nodeId = sourceNodeId;
		printf("RSSI received: %d from %d\n",mess->rssi,sourceNodeId);
		
		//se e' ultimo nodo vuol dire che ho finito di ricevere
		//allora posso cercare i tre migliori e calcolare distanza
		/*if(sourceNodeId == ANCHOR_NODE_NUMBER) {
			
			for(j=0; j<ANCHOR_NODE_NUMBER; ++j) {
				if(RSSI_array[j].rssiVal>firstEl.rssiVal) {
					firstEl = RSSI_array[j];
				}
			}
			RSSI_array[firstEl.nodeId-1].rssiVal = 0;
			for(j=0; j<ANCHOR_NODE_NUMBER; ++j) {
				if(RSSI_array[j].rssiVal>secondEl.rssiVal ) {
					secondEl = RSSI_array[j];
				}
			}
			RSSI_array[secondEl.nodeId-1].rssiVal = 0;
			for(j=0; j<ANCHOR_NODE_NUMBER ; ++j) {
				if(RSSI_array[j].rssiVal>thirdEl.rssiVal) {
					thirdEl = RSSI_array[j];
				}
			}

			calcDistance();
			initRssiArray();
					
		}*/
		
	}

    return buf;

  }
  
  void initRssiArray() {
  	int i=0;
  	for(i=0;i<8;i++) {
  		RSSI_array[i].rssiVal = 0;
  		RSSI_array[i].nodeId = 99;
  	}
  }
  
  
  void calcDistance() {
  	printf("Best nodeID= %d with RSSI= %d\n",firstEl.nodeId,firstEl.rssiVal);
  	printf("Second nodeID= %d with RSSI= %d\n",secondEl.nodeId,secondEl.rssiVal);
  	printf("Third nodeID= %d with RSSI= %d\n",thirdEl.nodeId,thirdEl.rssiVal);
  	//esponenziale si fa cn pow(x,y))
  }
  
  
}
