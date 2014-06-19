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
	    interface Timer<TMilli> as TimeOut;
	    interface Timer<TMilli> as Time10Sec;
	    interface Timer<TMilli> as Time10;
	}
}

implementation {
  message_t packet;
  void sendPacket();
  
  event void Boot.booted() {
	printf("Anchor Mote %d booted...\n", TOS_NODE_ID);
	call RadioControl.start();
	call Time10Sec.startOneShot(WAIT_BEFORE_SYNC);
  }
  
  event void RadioControl.startDone(error_t err){}
  
  event void RadioControl.stopDone(error_t err){}
  
  event void TimeOut.fired() {
	call Time10.startOneShot(TIMESLOT*TOS_NODE_ID);
  }
  
  event void Time10.fired() {
  	sendPacket();
  }
  
  //************************Invia pacchetto al mobile node*********************************//
  void sendPacket() {
	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
	mess->msg_type = REQ;
	mess->mode_type = ANCHOR;
	mess->x = anchorCoord[TOS_NODE_ID-1].x;
	mess->y = anchorCoord[TOS_NODE_ID-1].y;
	 
	printf("Try to broadcast the message... \n");
	call AMSend.send(AM_BROADCAST_ADDR,&packet,sizeof(nodeMessage_t));
	
	call TimeOut.startOneShot(SEND_INTERVAL_ANCHOR);
	printf("Starting new timer...");

  }
 
 
 //************************Invia pacchetto di sync*********************************//
  void sendPacketSync() {
	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
	mess->msg_type = SYNCPACKET;
	 
	printf("Try to broadcast the sync message... \n");
	call AMSend.send(AM_BROADCAST_ADDR,&packet,sizeof(nodeMessage_t));
  }
 
 
  //*********************AMSend interface****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
    if(&packet == buf && err == SUCCESS ) {}
  }

	event void Time10Sec.fired(){
		//prima mando sync, solo se sono l'ancora 1
		if(TOS_NODE_ID == 1) {
			sendPacketSync();			
			
			//dopo avvio broadcast normale in TDMA per ancora 1
			call Time10.startOneShot(TIMESLOT*TOS_NODE_ID);
		}
	}

	event message_t * Receive.receive(message_t* buf,void* payload, uint8_t len) {
		am_addr_t sourceNodeId = call AMPacket.source(buf);	
		nodeMessage_t* mess = (nodeMessage_t*) payload;
	
		if ( mess->msg_type == SYNCPACKET) {
			printf("Anchor %d -> SyncPacket received from anchor %d...\n", TOS_NODE_ID, sourceNodeId);
			
			//avvio dopo un tempo definito in modo da creare gli slot
			//di fatto implementando il TDMA per i nodi restanti
			call Time10.startOneShot(TIMESLOT*TOS_NODE_ID);
		}
		return buf;
	}
}
