#include "ApplicationDefinitions.h"
#include "RssiDemoMessages.h"

module SendingMoteC {
  uses interface Boot;
  uses interface Timer<TMilli> as SendTimer;
  
  uses interface AMSend as RssiMsgSend;
  uses interface SplitControl as RadioControl;
}


implementation {
  message_t msg;
  
  event void Boot.booted(){
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t result){
    call SendTimer.startPeriodic(SEND_INTERVAL_MS);
  }

  event void RadioControl.stopDone(error_t result){}


  event void SendTimer.fired(){
    call RssiMsgSend.send(AM_BROADCAST_ADDR, &msg, sizeof(RssiMsg));    
  }

  event void RssiMsgSend.sendDone(message_t *m, error_t error){}
}
