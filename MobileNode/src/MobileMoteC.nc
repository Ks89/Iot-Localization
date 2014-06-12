#include "ApplicationDefinitions.h"
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
		sourceNodeId = call AMPacket.source(buf);
		RSSI_array[sourceNodeId-1].rssiVal = mess->rssi;
		RSSI_array[sourceNodeId-1].nodeId = sourceNodeId;
		
		//stampo array utile per debug
		for(i=0;i<8;i++) {
			printf("%d_%d,",RSSI_array[i].nodeId, RSSI_array[i].rssiVal);
		}
		
		printf("\nRSSI received: %d from %d\n",mess->rssi,sourceNodeId);
		
		//se e' ultimo nodo vuol dire che ho finito di ricevere
		//allora posso cercare i tre migliori e calcolare distanza
		if(sourceNodeId == ANCHOR_NODE_NUMBER) {
			int j;
			//metto tutto a 0 (per ora, poi mettere a -999)
			firstEl.nodeId=0;
			firstEl.rssiVal=0;
			secondEl.nodeId=0;
			secondEl.rssiVal=0;
			thirdEl.nodeId=0;
			thirdEl.rssiVal=0;
			
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
					
		}
		
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
