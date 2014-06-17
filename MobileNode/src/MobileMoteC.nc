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
	}
}


implementation {
	
	typedef struct rssiArrayElement {
		int nodeId;
		int16_t rssiVal;
	} nodeValue;

	//vettore degli rssi ricevuti, con associato il nodo
	nodeValue RSSIArray[8];
	nodeValue RSSISaved[8];
	
	//vettore con i 3 nodi in ordine crescente di potenza
	nodeValue topNode[3];
	
	//vettore con le distanze calcolate per i 3 nodi. Qui le distance
	//sono in ordine decrescente. Cioe' nodo con piu' potenza e' piu' vicino
	//e quindi con distanza minore
	float distArray[3];
	
	//posizione stimata del nodo mobile
	float posX, posY;
	int time = 0;
	
	message_t packet;
 	
 	int16_t calcRSSI(float x, float y);
 	
	void calcDist();
	void findTopNode();
	void initNodeArray(nodeValue *array);
	void initDistArray();
	float distFromRSSI(int16_t RSSI);
	void getPosition();
	void printfFloat(float toBePrinted);
	int16_t getGaussian();
 
 
	//***************** Boot interface ********************//
	event void Boot.booted() {
		printf("Mobile Mote booted.\n");
		initNodeArray(RSSIArray);
		initNodeArray(RSSISaved);
		initNodeArray(topNode);
		initDistArray();
		call RadioControl.start();
	}
 
	//***************** RadioControl interface ********************//
	event void RadioControl.startDone(error_t err){}
 
	event void RadioControl.stopDone(error_t err){}

	//********************* AMSend interface ****************//
	event void AMSend.sendDone(message_t* buf,error_t err) {
	}


	event void TimeOut.fired(){
		int j=0;
	
		for(j=0;j<8;j++) {
			RSSISaved[j] = RSSIArray[j];
		}
	
		findTopNode();
		calcDist();
		getPosition();
		initNodeArray(RSSIArray);
		initNodeArray(RSSISaved);
		initNodeArray(topNode);
		initDistArray();
		time++;
	}


	//***************************** Receive interface *****************//
	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

		am_addr_t sourceNodeId = call AMPacket.source(buf);	
		nodeMessage_t* mess = (nodeMessage_t*) payload;
		printf("Message received from %d...\n", sourceNodeId);
	
		if ( mess->msg_type == REQ && mess->mode_type == ANCHOR ) {
			
			RSSIArray[sourceNodeId-1].rssiVal = calcRSSI(mess->x,mess->y);
			RSSIArray[sourceNodeId-1].nodeId = sourceNodeId;
			printf("RSSI calculated: %d from %d\n",RSSIArray[sourceNodeId-1].rssiVal,sourceNodeId);
	
			if(!(call TimeOut.isRunning())) {
				call TimeOut.startOneShot(MOVE_INTERVAL_MOBILE);
			}
		}
		return buf;
	}
 
	void initNodeArray(nodeValue *array) {
		int i;
		for(i=0;i<sizeof(array)/sizeof(array[0]);i++) {
			array[i].nodeId = -999;
			array[i].rssiVal = -999;
		}
	}

 
	void initDistArray() {
		int i;
		for(i=0;i<3;i++) {
			distArray[i] = -999;
		}
	}
 
	//metodo che crea la top 3 dei nodi con potenza piu' alta ordinati 
	//in [0],[1] e [2] in modo crescente  
	void findTopNode(){
		int j;
		for(j=0;j<8;j++) {
			printf("Node=%d, RSSI=%d\n", RSSISaved[j].nodeId, RSSISaved[j].rssiVal);
		}
	
		for(j=0; j<8; ++j) {
			if(RSSISaved[j].rssiVal>topNode[0].rssiVal) {
				topNode[0] = RSSISaved[j];
			}
		}
		RSSISaved[topNode[0].nodeId-1].rssiVal = -999;
		for(j=0; j<8; ++j) {
			if(RSSISaved[j].rssiVal>topNode[1].rssiVal ) {
				topNode[1] = RSSISaved[j];
			}
		}
		RSSISaved[topNode[1].nodeId-1].rssiVal = -999;
		for(j=0; j<8 ; ++j) {
			if(RSSISaved[j].rssiVal>topNode[2].rssiVal) {
				topNode[2] = RSSISaved[j];
			}
		}
	
		printf("Best nodeID = %d with RSSI = %d\n",topNode[0].nodeId,topNode[0].rssiVal);
		printf("Second nodeID = %d with RSSI = %d\n",topNode[1].nodeId,topNode[1].rssiVal);
		printf("Third nodeID = %d with RSSI = %d\n",topNode[2].nodeId,topNode[2].rssiVal);
	}
	
	int16_t calcRSSI(float x, float y) {
		int16_t rssi;
		float distance;
		distance = sqrtf(powf(x-mobileCoord[time].x,2)+powf(y-mobileCoord[time].y,2));
		rssi = -60 + 10 * logf10(distance)+getGaussian();
		return rssi;
	}
	
	int16_t getGaussian() {
		return 0;
	}
	
	//funzione che partendo dalla top 3 dei nodi con piu' potenza ne calcola la distanza
	//stimata dal nodo mobile
	void calcDist() {
		float v;
		int i;

		//per i tre nodi (se sono nel range di ricezione del mobile)
		//cioe' non ci sono -999 come nodo e come rssi cacolo distanza
		//e metto nel vettore delle distanze
		for(i=0;i<3;i++) {
			if(topNode[i].nodeId!=-999 && topNode[i].rssiVal!=-999) {
				distArray[i] = distFromRSSI(topNode[i].rssiVal);   
			}
		}
	
		//stampo array distanze per vedere i risultati
		for(i=0;i<3;i++) {
			if(distArray[i]!=-999) {
				printf("\n>>>Position in chart %d, distance = ", i+1);
				printfFloat(distArray[i]);
			}
		}
		printf("\n");	
	}

	float distFromRSSI(int16_t RSSI) {
		float res, p;
		p = (-60-RSSI)/10;
		res = powf(10, p);
		return res;
	}
 
 	//funzione per calcolare la posizione stimata del nodo mobile.
	//presuppone di avere gia' tutti i dati e soprattutto le posizioni dei nodi anchor
	//nel vettore anchorCoord
	void getPosition() {
		int i;
		float x = mobileCoord[time].x, y = mobileCoord[time].y;
		float sqrtValue, partOne, sumX=0, sumY=0, sumFunct=0;
		float alpha = 0.5; //parte da un valore elevato apposta
		float functToMin=9998, functToMinPrev=9999;
	
		while(functToMin<functToMinPrev) {
			printf("CICLO WHILE\nfunctToMin= ");
			
			
			sumFunct = 0;
			sumX = 0;
			sumY = 0;
			
			//calcolo x e y
			for(i=0;i<3;i++) {
				sqrtValue = sqrtf(powf(x-anchorCoord[topNode[i].nodeId-1].x,2) 
						+ powf(y-anchorCoord[topNode[i].nodeId-1].y,2));
				partOne = 1 - (distArray[topNode[i].nodeId-1]/sqrtValue);
				sumX = sumX + (partOne * (x - anchorCoord[topNode[i].nodeId-1].x));
				sumY = sumY + (partOne * (y - anchorCoord[topNode[i].nodeId-1].y));
				
				sumFunct = sumFunct + powf((sqrtValue - distArray[topNode[i].nodeId-1]),2);
	
				printf("\nCICLO FOR %d, sqrtValue ", i);
				printfFloat(sqrtValue);
				printf("\npartOne ");
				printfFloat(partOne);
				printf("\nsumX ");
				printfFloat(sumX);
				printf("\nsumY ");
				printfFloat(sumY);
				printf("\nsumFunct ");
				printfFloat(sumFunct);
				printf("\n");
			}
			
			//calcolo x e y stimate 
			x = x - (alpha * sumX);
			y = y - (alpha * sumY);
	
			printf("\nX ");
			printfFloat(x);
			printf("\nY ");
			printfFloat(y);
			printf("\n");
			
			//aggiorno funzione precedente con l'attuale
			functToMinPrev = functToMin;
			
			//calcolo la funzione da minimizzare
			functToMin = (0.5) * sumFunct;
			
			printf("\nfunctToMin= ");
			printfFloat(functToMin);
			printf("\nfunctToMinPrev= ");
			printfFloat(functToMinPrev);
			printf("\n");
		}
		
		//uscito dal while ho i 2 volari di x e y stimati finali
		//perche' la funzione e' minimizzata, visto che al passo successivo
		//aumenta, quindi la funzione minimizzata finale e' dentro a functToMinPrev
		printf("\nfunctToMin= ");
			printfFloat(functToMin);
			printf("\nfunctToMinPrev= ");
			printfFloat(functToMinPrev);
			printf("\n");
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
