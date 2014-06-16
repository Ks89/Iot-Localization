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
		interface Timer<TMilli> as TimeOut;
		interface CC2420Packet;
	}
}


implementation {
	
	struct rssiArrayElement {
		int nodeId;
		int16_t rssiVal;
	};
 	
 	struct coordinateElement {
		float x;
		float y;
	};
 
	//vettore degli rssi ricevuti, con associato il nodo
	struct rssiArrayElement RSSI_array[8] = {{-999,-999},{-999,-999},{-999,-999},
		{-999,-999},{-999,-999},{-999,-999},{-999,-999},{-999,-999}};
	
	//vettore con i 3 nodi in ordine crescente di potenza
	struct rssiArrayElement topThreeNode[8] = {{-999,-999},{-999,-999},{-999,-999}};
	struct rssiArrayElement RSSI_saved[8];
	
	//vettore con le distanze calcolate per i 3 nodi. Qui le distance
	//sono in ordine decrescente. Cioe' nodo con piu' potenza e' piu' vicino
	//e quindi con distanza minore
	float distanceArray[3] = {-999,-999,-999};
	
	//vettore con le coordinate di ogni anchorNode
	struct coordinateElement anchorCoord[8] = {{-999,-999},{-999,-999},{-999,-999},
		{-999,-999},{-999,-999},{-999,-999},{-999,-999},{-999,-999}};
	
	//posizione stimata del nodo mobile
	float posX, posY;
	
	message_t packet;
 
	void calcDistance();
	void createTopThreeNode();
	void initRssiArray();
	void initTopThreeNode();
	void initDistanceArray();
	uint16_t getRSSI(message_t *msg);
	float distanceFromRSSI(int16_t RSSI, float v);
	void getMobileNodePosition();
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

 
	//***************** Retrieve RSSI Value ******************//
	uint16_t getRSSI(message_t *msg){
		return (uint16_t) call CC2420Packet.getRssi(msg);
	}

	//********************* AMSend interface ****************//
	event void AMSend.sendDone(message_t* buf,error_t err) {
	}


	event void TimeOut.fired(){
		int j=0;
	
		for(j=0;j<8;j++) {
			RSSI_saved[j] = RSSI_array[j];
		}
	
		createTopThreeNode();
		calcDistance();
		initRssiArray();
		initTopThreeNode();
		initDistanceArray();
	}


	//***************************** Receive interface *****************//
	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

		am_addr_t sourceNodeId = call AMPacket.source(buf);	
		nodeMessage_t* mess = (nodeMessage_t*) payload;
		printf("Message received from %d...\n", sourceNodeId);
		mess->rssi = getRSSI(buf);
	
		if ( mess->msg_type == REQ && mess->mode_type == ANCHOR ) {
			
			//sottraggo 45 perche' per il telosb bisogna fare cosi'
			RSSI_array[sourceNodeId-1].rssiVal = mess->rssi-45;
			RSSI_array[sourceNodeId-1].nodeId = sourceNodeId;
			printf("RSSI received: %d from %d\n",mess->rssi,sourceNodeId);
	
			if(!(call TimeOut.isRunning())) {
				call TimeOut.startOneShot(MOVE_INTERVAL_MOBILE);
			}
		}
		return buf;
	}
 
	void initRssiArray() {
		int i;
		for(i=0;i<8;i++) {
			RSSI_array[i].rssiVal = -999;
		}
	}
 
	void initTopThreeNode() {
		int i;
		for(i=0;i<3;i++) {
			topThreeNode[i].rssiVal = -999;
		}
	}
 
	void initDistanceArray() {
		int i;
		for(i=0;i<3;i++) {
			distanceArray[i] = -999;
		}
	}
 
	//metodo che crea la top 3 dei nodi con potenza piu' alta ordinati 
	//in [0],[1] e [2] in modo crescente  
	void createTopThreeNode(){
		int j;
		for(j=0;j<8;j++) {
			printf("Node=%d, RSSI=%d\n", RSSI_array[j].nodeId, RSSI_array[j].rssiVal);
		}
	
		for(j=0; j<8; ++j) {
			if(RSSI_array[j].rssiVal>topThreeNode[0].rssiVal) {
				topThreeNode[0] = RSSI_array[j];
			}
		}
		RSSI_array[topThreeNode[0].nodeId-1].rssiVal = -999;
		for(j=0; j<8; ++j) {
			if(RSSI_array[j].rssiVal>topThreeNode[1].rssiVal ) {
				topThreeNode[1] = RSSI_array[j];
			}
		}
		RSSI_array[topThreeNode[1].nodeId-1].rssiVal = -999;
		for(j=0; j<8 ; ++j) {
			if(RSSI_array[j].rssiVal>topThreeNode[2].rssiVal) {
				topThreeNode[2] = RSSI_array[j];
			}
		}
	
		printf("Best nodeID= %d with RSSI= %d\n",topThreeNode[0].nodeId,topThreeNode[0].rssiVal);
		printf("Second nodeID= %d with RSSI= %d\n",topThreeNode[1].nodeId,topThreeNode[1].rssiVal);
		printf("Third nodeID= %d with RSSI= %d\n",topThreeNode[2].nodeId,topThreeNode[2].rssiVal);
	}
 
	//funzione che partendo dalla top 3 dei nodi con piu' potenza ne calcola la distanza
	//strimata dal nodo mobile
	void calcDistance() {
		float v;
		int i;

		//per i tre nodi (se sono nel range di ricezione del mobile)
		//cioe' non ci sono -999 come nodo e come rssi cacolo distanza
		//e metto nel vettore delle distanze
		for(i=0;i<3;i++) {
			if(topThreeNode[i].nodeId!=-999 && topThreeNode[i].rssiVal!=-999) {
				v = 0; //fare gauss
				distanceArray[i] = distanceFromRSSI(topThreeNode[i].rssiVal,v);   
			}
		}
	
		//stampo array distanze per vedere i risultati
		for(i=0;i<3;i++) {
			if(distanceArray[i]!=-999) {
				printf("\n>>>Position in chart %d, distance = ", i+1);
				printfFloat(distanceArray[i]);
			}
		}
		printf("\n");	
	}
	
	//funzione per calcolare distanza da rssi
	//l'rssi in ingresso deve essere gia' il valore reale.
	//nel caso del telosb bisogna averlo sottratto di 45, prima
	//di chiamare questa funzione
	float distanceFromRSSI(int16_t RSSI, float v) {
		float res, p;
		p = (-60+v-RSSI)/10;
		res = powf(10, p);
		return res;
	}
 
 	//funzione per calcolare la posizione stimata del nodo mobile.
	//presuppone di avere gia' tutti i dati e soprattutto le posizioni dei nodi anchor
	//nel vettore anchorCoord
	void getMobileNodePosition() {
		int i,j;
		float x=0,y=0, sqrtValue, partOne, sumX=0, sumY=0, sumFunct=0;
		float alpha = 0.1; //messo a caso
		float functToMin, functToMinPrev=9999;
	
	
		while(functToMin<functToMinPrev) {
			sumFunct = 0;
			sumX = 0;
			sumY = 0;
			
			//calcolo x e y
			for(i=0;i<3;i++) {
				sqrtValue = sqrtf(powf(x-anchorCoord[topThreeNode[i].nodeId].x,2) 
						+ powf(y-anchorCoord[topThreeNode[i].nodeId].y,2));
				partOne = 1 - (distanceArray[topThreeNode[i].nodeId]/sqrtValue);
				sumX = sumX + (partOne * (x - anchorCoord[topThreeNode[i].nodeId].x));
				sumY = sumY + (partOne * (y - anchorCoord[topThreeNode[i].nodeId].y));
				
				sumFunct = sumFunct + powf((sqrtValue - distanceArray[topThreeNode[i].nodeId]),2);
	
			}
			
			//calcolo x e y stimate 
			x = x - (alpha * sumX);
			y = y - (alpha * sumY);
	
			//aggiiorno funzione precedente con l'attuale
			functToMinPrev = functToMin;
			
			//calcolo la funzione da minimizzare
			functToMin = (0.5) * sumFunct;
		}
		
		//uscito dal while ho i 2 volari di x e y stimati finali
		//perche' la funzione e' minimizzata, visto che al passo successivo
		//aumenta, quindi la funzione minimizzata finale e' dentro a functToMinPrev
	}
 
	//utility
	//https://www.millennium.berkeley.edu/pipermail/tinyos-help/2008-June/034691.html
	void printfFloat(float toBePrinted) {
		uint32_t fi, f0, f1, f2, f3, f4, f5;
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
		f0 = f*10;   	f0 %= 10;
		f1 = f*100;  	f1 %= 10;
		f2 = f*1000; 	f2 %= 10;
		f3 = f*10000; 	f3 %= 10;
		f4 = f*100000; 	f4 %= 10;
		f5 = f*1000000; f5 %= 10;
		printf("%c%ld.%d%d%d%d%d%d", c, fi, (uint8_t) f0, (uint8_t) f1, (uint8_t) f2, (uint8_t) f3, (uint8_t) f4, (uint8_t) f5);
	}
}
