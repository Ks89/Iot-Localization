#include "ApplicationDefinitions.h"
#include "RssiDemoMessages.h" 
#include "printf.h" 

module RssiBaseC {
  uses interface Intercept as RssiMsgIntercept;

  uses interface CC2420Packet;
}

implementation {

  uint16_t getRssi(message_t *msg);
  
  event bool RssiMsgIntercept.forward(message_t *msg,
				      void *payload,
				      uint8_t len) {
    RssiMsg *rssiMsg = (RssiMsg*) payload;
    rssiMsg->rssi = getRssi(msg);
    printf("valore %d\n", rssiMsg->rssi);
    
    return TRUE;
  }

  uint16_t getRssi(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }
}
