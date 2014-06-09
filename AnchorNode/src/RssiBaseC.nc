#include "ApplicationDefinitions.h"
#include "Message.h" 
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
    nodeMessage_t *message = (nodeMessage_t*) payload;
    message->rssi = getRssi(msg);
    printf("valore %d\n", message->rssi);
    
    return TRUE;
  }

  uint16_t getRssi(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }
}
