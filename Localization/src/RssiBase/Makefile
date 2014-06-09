COMPONENT=RssiBaseAppC

INCLUDES= -I..               \
          -I../InterceptBase

CFLAGS += $(INCLUDES)
CFLAGS += -I$(TOSDIR)/lib/printf
#CFLAGS += -DNEW_PRINTF_SEMANTICS

ifneq ($(filter iris,$(MAKECMDGOALS)),) 
	CFLAGS += -DRF230_RSSI_ENERGY
endif


include $(MAKERULES)
