TARGET := app

OBJ_DIR := ./obj

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

RM=rm -f
CORE=3
CPUFLAGS=-mthumb -mcpu=cortex-m$(CORE)
LDFLAGS = -T user/stm32_flash.ld -Wl,-cref,-u,Reset_Handler -Wl,-Map=$(OBJ_DIR)/$(TARGET).map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group\
		-D STM32F10X_HD -fdata-sections -ffunction-sections\

CFLAGS=-g -o

C_SOURCES =  \
	user/main.c \
	user/system_stm32f10x.c\
	core/core_cm3.c\
	stm32f10x_fwlib/src/misc.c\
	stm32f10x_fwlib/src/stm32f10x_adc.c\
	stm32f10x_fwlib/src/stm32f10x_bkp.c\
	stm32f10x_fwlib/src/stm32f10x_can.c\
	stm32f10x_fwlib/src/stm32f10x_cec.c\
	stm32f10x_fwlib/src/stm32f10x_crc.c\
	stm32f10x_fwlib/src/stm32f10x_dac.c\
	stm32f10x_fwlib/src/stm32f10x_dbgmcu.c\
	stm32f10x_fwlib/src/stm32f10x_exti.c\
	stm32f10x_fwlib/src/stm32f10x_flash.c\
	stm32f10x_fwlib/src/stm32f10x_fsmc.c\
	stm32f10x_fwlib/src/stm32f10x_gpio.c\
	stm32f10x_fwlib/src/stm32f10x_i2c.c\
	stm32f10x_fwlib/src/stm32f10x_iwdg.c\
	stm32f10x_fwlib/src/stm32f10x_pwr.c\
	stm32f10x_fwlib/src/stm32f10x_rcc.c\
	stm32f10x_fwlib/src/stm32f10x_rtc.c\
	stm32f10x_fwlib/src/stm32f10x_sdio.c\
	stm32f10x_fwlib/src/stm32f10x_spi.c\
	stm32f10x_fwlib/src/stm32f10x_tim.c\
	stm32f10x_fwlib/src/stm32f10x_usart.c\
	stm32f10x_fwlib/src/stm32f10x_wwdg.c\
	system/delay/delay.c\
	system/sys/sys.c\
	hardware/led/led.c\
	system/usart/usart.c\

ASM_SOURCES =  \
	core/startup_stm32f103zetx.S\

AS_INCLUDES = 

C_INCLUDES =  \
	-Iuser \
	-Icore \
	-Istm32f10x_fwlib/inc \
	-Isystem/delay\
	-Isystem/sys\
	-Isystem/usart\
	-Ihardware/led\

$(TARGET):startup_stm32f103zetx.o c_sources.o
	$(CC) $(OBJ_DIR)/*.o *.o $(C_INCLUDES) $(CPUFLAGS) $(LDFLAGS) $(CFLAGS) $(OBJ_DIR)/$(TARGET).elf
	make bin
	make hex

c_sources.o:$(C_SOURCES)
	$(CC) -c $^ $(C_INCLUDES) $(CPUFLAGS) $(LDFLAGS) # $(CFLAGS) $(OBJ_DIR)/$@


startup_stm32f103zetx.o:$(ASM_SOURCES)
	$(CC) -c $< $(CPUFLAGS) $(AS_INCLUDES) $(CFLAGS) $(OBJ_DIR)/$@

bin:
	$(OBJCOPY) $(OBJ_DIR)/$(TARGET).elf $(OBJ_DIR)/$(TARGET).bin
hex:
	$(OBJCOPY) $(OBJ_DIR)/$(TARGET).elf -Oihex $(OBJ_DIR)/$(TARGET).hex

burn:
	openocd -f /usr/share/openocd/scripts/interface/stlink-v2.cfg -f /usr/share/openocd/scripts/target/stm32f1x.cfg
	# telnet localhost 4444
	# halt
	# flash write_image erase obj/app.hex
	# reset								#可要可不要
	# exit
clean:
	$(RM) $(OBJ_DIR)/*.o $(OBJ_DIR)/$(TARGET).* *.o $(OBJ_DIR)/*

