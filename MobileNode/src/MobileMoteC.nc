/*
Copyright 2014-2015 Stefano Cappa, Jiang Wu, Eric Scarpulla
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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
		interface Timer<TMilli> as TimeOut250;
		interface Timer<TMilli> as TimeOut180;
		interface Random;
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
	float X = 0,Y = 0;
	
	//----->GRAFICO FINALE = errore nel determinare la posizione (cioe' distanze tra posizione stimata e reale)
	float errorDist[24];
	
	//----->GRAFICO FINALE = i valori crescenti di varianza che sono fissi
	float variance[NUMCOORD];
	
	//movimento del nodo mobile, ogni istante di tempo (time)
	//cycle rappresenta la misurazione eseguita nello stesso intervallo di tempo
	//che poi verra' mediata con le altre nello stesso time
	int time = 0;
	int cycle = 0;
	
	message_t packet;
	
	int16_t calcRSSI(float x, float y);
	
	void calcDist();
	void findTopNode();
	void initNodeArray(nodeValue *array);
	void initTopArray(nodeValue *array);
	void initDistArray();
	void initErrorDistanceArray();
	float distFromRSSI(int16_t RSSI);
	void getPosition();
	void getError();
	void printfFloat(float toBePrinted);
	float getGaussian();
	float rand_gauss();
	void fillVarianceArray();
	void sendSwitchOff();
 
 
	//***************** Boot interface ********************//
	event void Boot.booted() {
		printf("[MOBILE] Mote booted.\n");
		initNodeArray(RSSIArray);
		initNodeArray(RSSISaved);
		initNodeArray(topNode);
		initDistArray();
		initErrorDistanceArray();
		fillVarianceArray();
		call RadioControl.start();
	}
 
	//***************** RadioControl interfaces ********************//
	event void RadioControl.startDone(error_t err){}
	event void RadioControl.stopDone(error_t err){}

	//********************* AMSend interface ****************//
	event void AMSend.sendDone(message_t* buf,error_t err) {}

	event void TimeOut250.fired(){
		call TimeOut250.startOneShot(SEND_INTERVAL_ANCHOR);
	}
	
	
	//Timer di 180 ms in cui il nodo mobile riceve i pacchetti dalle ancore
	event void TimeOut180.fired() {
		int j=0;
		
		if(time == NUMCOORD) {
			sendSwitchOff();
			call TimeOut250.stop();			
			return;
		}
	
		for(j=0;j<8;j++) {
			RSSISaved[j] = RSSIArray[j];
		}
		
		printf("[MOBILE] Node current position (");
		printfFloat(mobileCoord[time].x);
		printf(",");
		printfFloat(mobileCoord[time].y);
		printf(")\n");
	
		findTopNode();
		calcDist();
		getPosition();
		
		//calcolo errore sui valori ottenuti
		X += posX; Y += posY;
		if(cycle %  4 == 3 && cycle != 0) {
			posX = X / 4.0;
			posY = Y / 4.0;
			getError();
		}
		
		//inizializzo per il movimento successivo, cioe' nell'istante di tempo time++
		initNodeArray(RSSISaved);
		initTopArray(topNode);
		initDistArray();
		initErrorDistanceArray();
		cycle++;
		if(cycle %  4 == 0) {
			X = 0; Y = 0;
			//dopo aver preso le 4 misurazioni muovo il nodo mobile
			time++;	
		}
	}
	
	 //************************Invia pacchetto di switch off*********************************//
  void sendSwitchOff() {
	nodeMessage_t* mess = (nodeMessage_t*) (call Packet.getPayload(&packet,sizeof(nodeMessage_t)));
	mess->msg_type = SWITCHOFF;
	 
	printf("[MOBILE] Broadcasting SWITCHOFF beacon... \n");
	call AMSend.send(AM_BROADCAST_ADDR,&packet,sizeof(nodeMessage_t));
	call RadioControl.stop();
  }
 

	//***************************** Receive interface *****************//
	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
		am_addr_t sourceNodeId = call AMPacket.source(buf);	
		nodeMessage_t* mess = (nodeMessage_t*) payload;
		printf("[MOBILE] Message received from anchor %d... type %d\n", sourceNodeId, mess->msg_type);
	
		if ( mess->msg_type == BEACON ) {
			printf("[MOBILE] RSSI Before: %d from %d\n",RSSIArray[sourceNodeId-1].rssiVal,sourceNodeId);
			RSSIArray[sourceNodeId-1].rssiVal = calcRSSI(mess->x,mess->y);
			RSSIArray[sourceNodeId-1].nodeId = sourceNodeId;
			printf("[MOBILE] RSSI Calculated: %d from %d\n",RSSIArray[sourceNodeId-1].rssiVal,sourceNodeId);
			
			//se gia non sto ricevendo, attivo il timer180
			if(!(call TimeOut180.isRunning())) {
				call TimeOut180.startOneShot(RECEIVE_INTERVAL_ANCHOR);
			}		
		} //nel caso il messaggio ricevuto e' di sync avvio timer delle misurazione eseguite nel cycle
		else if(mess->msg_type == SYNCPACKET) {
			call TimeOut250.startOneShot(SEND_INTERVAL_ANCHOR);
		}
		return buf;
	}
 
	void initNodeArray(nodeValue *array) {
		int i;
		for(i=0;i<8;i++) {
			array[i].nodeId = -999;
			array[i].rssiVal = -999;
		}
	}
	
	void initTopArray(nodeValue *array) {
		int i;
		for(i=0;i<3;i++) {
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
	
	void initErrorDistanceArray() {
		int i;
		for(i=0;i<24;i++) {
			errorDist[i] = -999;
		}
	}
	
	//metodo che crea la top 3 dei nodi con potenza piu' alta ordinati 
	//in [0],[1] e [2] in modo crescente  
	void findTopNode(){
		int j;
		for(j=0;j<8;j++) {
			printf("[MOBILE] Node = %d, RSSI = %d\n", RSSISaved[j].nodeId, RSSISaved[j].rssiVal);
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
	
		printf("[MOBILE] First nodeID = %d with RSSI = %d\n",topNode[0].nodeId,topNode[0].rssiVal);
		printf("[MOBILE] Second nodeID = %d with RSSI = %d\n",topNode[1].nodeId,topNode[1].rssiVal);
		printf("[MOBILE] Third nodeID = %d with RSSI = %d\n",topNode[2].nodeId,topNode[2].rssiVal);
	}
	
	int16_t calcRSSI(float x, float y) {
		int16_t rssi;
		float distance;
		distance = sqrtf(powf(x-mobileCoord[time].x,2)+powf(y-mobileCoord[time].y,2));
		rssi = -60 - 10 * log10f(distance)+getGaussian();
		return rssi;
	}
	
	//	ottengo valore gaussiano v con varianza specificata dal vettore variance[cycle]
	float getGaussian() {
		float var = variance[time]; 
		float gauss;
		float randGauss = rand_gauss();
		printf("[MOBILE] RandGaussian value: ");
		printfFloat(randGauss);
		printf(" _ variance = ");
		printfFloat(var);
		printf(" _ cycle = %d and time= %d ", cycle, time);

		//0 e' la media che deve restare nulla perche' detto dalle specifiche
		gauss = ( randGauss * var ) + 0;
		printf("\n[MOBILE] Gaussian value: ");
		printfFloat(gauss);
		printf("\n");
		return gauss;
	}
	
	//funzione che partendo dalla top 3 dei nodi con piu' potenza ne calcola la distanza
	//stimata dal nodo mobile
	void calcDist() {
		int i;

		//per i tre nodi (se sono nel range di ricezione del mobile)
		//cioe' non ci sono -999 come nodo e come rssi calcolo la distanza
		//e la metto nel vettore delle distanze
		for(i=0;i<3;i++) {
			if(topNode[i].nodeId!=-999 && topNode[i].rssiVal!=-999) {
				distArray[i] = distFromRSSI(topNode[i].rssiVal);   
			}
		}
	
		//stampo array distanze per vedere i risultati
		for(i=0;i<3;i++) {
			if(distArray[i]!=-999) {
				printf("\n[MOBILE] Position in chart %d, distance = ", i+1);
				printfFloat(distArray[i]);
			}
		}
		printf("\n");	
	}

	float distFromRSSI(int16_t RSSI) {
		float res, p;
		float rssi = RSSI;
	
		//senza la conversione in float la formula viene approssimata male
		p = (-60-rssi)/10;
		res = powf(10, p);
		return res;
	}
 
	//funzione per calcolare la posizione stimata del nodo mobile.
	//presuppone di avere gia' tutti i dati e soprattutto le posizioni dei nodi anchor
	//nel vettore anchorCoord
	void getPosition() {
		int i,j=0;
		float sqrtValue, partOne, sumX=0, sumY=0, sumFunct=0;
		float alpha = 0.8; //parte da un valore elevato apposta
		float functToMin=9998, functToMinPrev=9999;
		float contX=0, contY=0;
	
	
		//calcolo le posX e posY evitando i nodi che hanno -999 come id, cioe' non sono in range
		for(i=0;i<3;i++) {
			if(topNode[i].nodeId!=-999 && topNode[i].rssiVal!=-999) {
				posX = posX + anchorCoord[topNode[i].nodeId-1].x;
				contX++;
				posY = posY + anchorCoord[topNode[i].nodeId-1].y;
				contY++;
			}
		}
	
		//se ho gia' pututo ottenere dei valori di coordinate iniziali mediate
		//non ci sono problemi. Se invece ho un solo nodo, e' ovvio che la formula di sqrt
		//dara' sempre 0, allora sommo apposta 5 (valore scelto a caso), per introdurre
		//una piccola variazione nelle coordinate e far si che l'algoritmo possa
		//generare risultati diversi da 0...molto sbagliati, ovvio, ha solo l'info di un nodo.
		if(contX>=2 && contY >=2) {
			posX = posX / contX;
			posY = posY / contY;
		} else {
			posX = anchorCoord[topNode[0].nodeId-1].x + 5;
			posY = anchorCoord[topNode[0].nodeId-1].y + 5;
		}
	
	
		printf("[MOBILE] Initial calculated position (");
		printfFloat(posX);
		printf(",");
		printfFloat(posY);
		printf(")");
	
		//functToMinPrev e' la funzione costo al passo precedente.
		//functToMin e' quella al passo attuale 
		while(functToMin < functToMinPrev ) {
			j++;
			sumFunct = 0;
			sumX = 0;
			sumY = 0;
	
			//per ridurre il numero di iterzioni uso un'alpha adattativo
			//che diminuisce col passare del tempo (cioe' all'aumentare delle iterazioni).
			//Questo per far si che l'algoritmo diventi piu' preciso man mano che si avvicina
			//alla soluzione. 
			if(j>3 && j<=10) {
				alpha = 0.6;
			} else {
				if(j>10 && j<=20) {
					alpha = 0.5;
				} else {
					alpha = 0.1;
				}	
			}

			//calcolo x e y
			for(i=0;i<3;++i) {
				if(topNode[i].nodeId!=-999 || topNode[i].rssiVal!=-999 || distArray[i]!=-999) {
					sqrtValue = sqrtf(powf(posX-anchorCoord[topNode[i].nodeId-1].x,2) 
							+ powf(posY-anchorCoord[topNode[i].nodeId-1].y,2));
					partOne = 1 - (distArray[i]/sqrtValue);
					sumX = sumX + (partOne * (posX - anchorCoord[topNode[i].nodeId-1].x));
					sumY = sumY + (partOne * (posY - anchorCoord[topNode[i].nodeId-1].y));
	
					sumFunct = sumFunct + powf((sqrtValue - distArray[i]),2);
				}
			}
	
			//calcolo x e y stimate 
			posX = posX - (alpha * sumX);
			posY = posY - (alpha * sumY);
	
			//aggiorno funzione precedente con l'attuale
			functToMinPrev = functToMin;
	
			//calcolo la funzione da minimizzare
			functToMin = (0.5) * sumFunct;
		}
	
		//uscito dal while ho i 2 volari di x e y stimati finali
		//perche' la funzione e' minimizzata, visto che al passo successivo
		//aumenta, quindi la funzione minimizzata finale e' dentro a functToMinPrev
		printf("\n[MOBILE] Estimated position (");
		printfFloat(posX);
		printf(" , ");
		printfFloat(posY);
		printf(")\n");
		printf("[MOBILE] After %d WHILE iteration \n",j);
	}
 
	//funzione per calcolare l'errore, cioe'  la distanza tra posizione stimata e quella reale (sara' asse y
	//del grafico finale da mettere nelle specifiche)
	void getError() {
		errorDist[time] = sqrtf(powf(mobileCoord[time].x - posX,2) 
				+ powf(mobileCoord[time].y - posY,2));
		
		
		printf("[MOBILE] ERROR - Final estimated position (");
		printfFloat(posX);
		printf(",");
		printfFloat(posY);
		printf(")\n");
		
		printf("[MOBILE] ERROR - Current position (");
		printfFloat(mobileCoord[time].x);
		printf(",");
		printfFloat(mobileCoord[time].y);
		printf(")\n");
		
		printf("[MOBILE] ERROR - Estimated error: ");
		printfFloat(errorDist[time]);
		printf(" at time: %d, with variance: ", time);
		printfFloat(variance[time]);
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
	
	
	//http://c-faq.com/lib/gaussian.html
	float rand_gauss (void) {
		static float V1, V2, S;
		static int phase = 0;
		float Xg;

		if(phase == 0) {
			do {
				float U1 = (float)(call Random.rand16()) / 30000;
				float U2 = (float)(call Random.rand16()) / 30000;

				V1 = 2 * U1 - 1;
				V2 = 2 * U2 - 1;
				S = V1 * V1 + V2 * V2;
			} while(S >= 1 || S == 0);

			Xg = V1 * sqrtf(-2 * log10f(S) / S);
		} else
			Xg = V2 * sqrtf(-2 * log10f(S) / S);

		phase = 1 - phase;

		return Xg;
	}
	
	
	//funzione che crea la serie di 6 valori di varianza predefiniti che vengono utilizzati 
	//dalla funzione getGaussian()
	void fillVarianceArray() {
		int i;
		for (i=1; i <= NUMCOORD; i++) {
			variance[i-1] = i/(NUMCOORD/4.0);
		}
	}	
}
