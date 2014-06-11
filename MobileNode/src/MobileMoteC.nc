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
  uint16_t RSSI_array[8];
  uint16_t firstEl, secondEl, thirdEl;
  int firstPos, secondPos, thirdPos;
  
  message_t packet;
  
  void calcDistance();
  void sendReq();
  void initRssiArray();

  
    //***************** Boot interface ********************//
  event void Boot.booted() {
	printf("Application booted.\n");
	initRssiArray();
	call RadioControl.start();
  }
  
    //***************** SplitControl interface ********************//
  event void RadioControl.startDone(error_t err){
		call MilliTimer.startOneShot( 0 );
  }
  
  event void RadioControl.stopDone(error_t err){}

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	sendReq();
  }

  void sendReq() {	
  	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
  	
  	printf("Request sended...");
	mess->msg_type = REQ;
	mess->mode_type = MOBILE;
	call AMSend.send(AM_BROADCAST_ADDR, &packet , sizeof(nodeMessage_t));
	call MilliTimer.startOneShot( SEND_INTERVAL_MOBILE );
  }

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	am_addr_t sourceNodeId;	
	nodeMessage_t* mess = (nodeMessage_t*) payload;
	int i=0;
	printf("Message received...\n");
	
	
	if ( mess->msg_type == RESP ) {
		RSSI = mess->rssi;	
		sourceNodeId = call AMPacket.source(buf);
		RSSI_array[sourceNodeId-1] = RSSI;
		
		//stampo array utile per debug
		for(i=0;i<8;i++) {
			printf("%d,",RSSI_array[i]);
		}
		
		printf("\nRSSI received: %d from %d\n",RSSI,sourceNodeId);
		
		//se e' ultimo nodo vuol dire che ho finito di ricevere
		//allora posso cercare i tre migliori e calcolare distanza
		if(sourceNodeId == ANCHOR_NODE_NUMBER) {
			int j;
			firstEl = RSSI_array[0];
			secondEl = RSSI_array[0];
			thirdEl = RSSI_array[0];
			firstPos=99;
			secondPos=99;
			thirdPos=99;
			for(j=1; j<ANCHOR_NODE_NUMBER; ++j) {
				if(RSSI_array[j]>firstEl) {
					firstEl = RSSI_array[j];
					firstPos = j+1;
				}
			}
			for(j=1; j<ANCHOR_NODE_NUMBER; ++j) {
				if(RSSI_array[j]>secondEl && j!=firstPos-1) {
					secondEl = RSSI_array[j];
					secondPos = j+1;
				}
			}
			for(j=1; j<ANCHOR_NODE_NUMBER ; ++j) {
				if(RSSI_array[j]>thirdEl && j!=firstPos-1 && j!=secondPos-1) {
					thirdEl = RSSI_array[j];
					thirdPos = j+1;
				}
			}
		
			calcDistance();
			initRssiArray();
					
		}
		
	}

    return buf;

  }
  
  void initRssiArray() {
  	int i=0;
  	for(i=0;i<8;i++) {
  		RSSI_array[i] = 0;
  	}
  }
  
  
  void calcDistance() {
  	printf("Best nodeID= %d with RSSI= %d\n",firstPos,firstEl);
  	printf("Second nodeID= %d with RSSI= %d\n",secondPos,secondEl);
  	printf("Third nodeID= %d with RSSI= %d\n",thirdEl,thirdEl);
  	
  }
  
  
}
