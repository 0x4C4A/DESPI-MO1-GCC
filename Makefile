BUILDDIR = build

USER   = User
DEVICE = StartUp
PERIPH = FWLib
EPAPER = EPD_W21

SOURCES += $(PERIPH)/stm32f10x_gpio.c \
		   $(PERIPH)/stm32f10x_exti.c \
		   $(PERIPH)/stm32f10x_flash.c \
		   $(PERIPH)/stm32f10x_iwdg.c \
		   $(PERIPH)/stm32f10x_rcc.c \
		   $(PERIPH)/stm32f10x_spi.c \
		   $(PERIPH)/stm32f10x_tim.c \
		   $(PERIPH)/stm32f10x_usart.c \
		   $(PERIPH)/misc.c 


SOURCES += $(DEVICE)/system_stm32f10x.c
SOURCES += $(DEVICE)/core_cm3.c
SOURCES += $(DEVICE)/startup_stm32f10x_md.s

SOURCES += $(EPAPER)/Display_EPD_W21.c
SOURCES += $(EPAPER)/Display_EPD_W21_Aux.c 

SOURCES += $(USER)/stm32f10x_it.c
SOURCES += $(USER)/main.c

OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

INCLUDES += -I$(DEVICE) \
			-I$(PERIPH) \
			-I$(USER) \
			-I$(EPAPER) 

ELF = $(BUILDDIR)/program.elf
HEX = $(BUILDDIR)/program.hex
BIN = $(BUILDDIR)/program.bin

CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
AR = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy
 	
CFLAGS  = -O0 -g -Wall \
   -mcpu=cortex-m3 -mfpu=vfp -msoft-float -mthumb -mfix-cortex-m3-ldrd \
   $(INCLUDES) -DUSE_STDPERIPH_DRIVER -DGDE0213B1  -DSTM32F10X_MD

LDSCRIPT = $(DEVICE)/stm32_flash.ld
LDFLAGS += -T$(LDSCRIPT) -mthumb -mcpu=cortex-m3 -nostdlib

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(ELF): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

flash: $(BIN)
	st-flash write $(BIN) 0x8000000

jflash: $(BIN)
	JLinkExe -if swd -device STM32F103V8 -speed 1000 -autoconnect 1 -commanderscript flash.jlink

clean:
	rm -rf build