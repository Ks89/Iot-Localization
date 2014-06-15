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
		interface Timer<TMilli> as TimeOut;
		interface CC2420Packet;
	}
}


implementation {
	
	struct rssiArrayElement {
		int nodeId;
		int16_t rssiVal;
	};
 
	struct rssiArrayElement RSSI_array[8] = {{-999,-999},{-999,-999},{-999,-999},
		{-999,-999},{-999,-999},{-999,-999},{-999,-999},{-999,-999}};
	struct rssiArrayElement firstEl={-999,-999}, secondEl={-999,-999}, thirdEl={-999,-999};
 
	message_t packet;
 
	void calcDistance();
	void initRssiArray();
	uint16_t getRSSI(message_t *msg);
	void printfFloat(float toBePrinted);
 
 
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


	event void TimeOut.fired(){
		calcDistance();
		initRssiArray();
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
	
			if(!(call TimeOut.isRunning())) {
				call TimeOut.startOneShot(MOVE_INTEVAL_MOBILE);
			}
		}
		return buf;
	}
 
	void initRssiArray() {
		int i=0;
		for(i=0;i<8;i++) {
			RSSI_array[i].rssiVal = -999;
			RSSI_array[i].nodeId = -999;
		}
	}
 
 
	void calcDistance() {
		float v,d ;
		int j=0;
		for(j=0;j<8;j++) {
			printf("i=%d, Node=%d, RSSI=%d\n", j, RSSI_array[j].nodeId, RSSI_array[j].rssiVal);
		}
	
		for(j=0; j<8; ++j) {
			if(RSSI_array[j].rssiVal>firstEl.rssiVal) {
				firstEl = RSSI_array[j];
			}
		}
		RSSI_array[firstEl.nodeId-1].rssiVal = -999;
		for(j=0; j<8; ++j) {
			if(RSSI_array[j].rssiVal>secondEl.rssiVal ) {
				secondEl = RSSI_array[j];
			}
		}
		RSSI_array[secondEl.nodeId-1].rssiVal = -999;
		for(j=0; j<8 ; ++j) {
			if(RSSI_array[j].rssiVal>thirdEl.rssiVal) {
				thirdEl = RSSI_array[j];
			}
		}
	
		printf("Best nodeID= %d with RSSI= %d\n",firstEl.nodeId,firstEl.rssiVal);
		printf("Second nodeID= %d with RSSI= %d\n",secondEl.nodeId,secondEl.rssiVal);
		printf("Third nodeID= %d with RSSI= %d\n",thirdEl.nodeId,thirdEl.rssiVal);

		//valori temporanei buttati un po' a caso per ora
		//secondo il web bisogna sottrarre 45 all'rssi....boh
		//NOTA BENE:  d = pow(10,-((firstEl.rssiVal-45+60-v)/10));  
		//non va perche' pow non e' trovata e con math.h non compila
		//Su internet dicono di usare senza math e compilare con make telosb -lm
		//in effetti compila (non ricordo se con pow o powf)
		//Cm non sono nemmeno fiducioso che funzioni davvero
		v = -2; //fare gauss
		printf("firstEl = ");
		d = -((firstEl.rssiVal-45+60-v)/10);   
		printfFloat(d);
		printf("\nsecondEl = ");
		d = -((secondEl.rssiVal-45+60-v)/10);   
		printfFloat(d);
		printf("\nthirdEl = ");
		d = -((thirdEl.rssiVal-45+60-v)/10);   
		printfFloat(d);
		printf("\n");
	}
 
 
 
	//utility
	//https://www.millennium.berkeley.edu/pipermail/tinyos-help/2008-June/034691.html
	void printfFloat(float toBePrinted) {
		uint32_t fi, f0, f1, f2;
		char c;
		float f = toBePrinted;

		if (f<0){
			c = '-'; f = -f;
		} else {
			c = ' ';
		}

		// integer portion.
		fi = (uint32_t) f;

		// decimal portion...get index for up to 3 decimal places.
		f = f - ((float) fi);
		f0 = f*10;   f0 %= 10;
		f1 = f*100;  f1 %= 10;
		f2 = f*1000; f2 %= 10;
		printf("%c%ld.%d%d%d", c, fi, (uint8_t) f0, (uint8_t) f1, (uint8_t) f2);
	}
 


}
