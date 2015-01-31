PROJ_NAME = main
SRC = main.c

CC_PREFIX = arm-none-eabi-
CC        = $(CC_PREFIX)gcc
OBJCOPY   = $(CC_PREFIX)objcopy
STARTUP   = startup_stm32l1xx_md.s
CFLAGS    = -mthumb -mcpu=cortex-m3 -mfix-cortex-m3-ldrd -msoft-float -O -g



OOCD_BOARD = stm32ldiscovery.cfg

program: $(PROJ_NAME).hex
	openocd -f board/$(OOCD_BOARD) \
					-c "init" -c "targets" -c "halt" \
					-c "flash write_image erase $(PROJ_NAME).hex" \
					-c "verify_image $(PROJ_NAME).hex" \
					-c "reset run" \
					-c "shutdown"

# List of all binaries to build
all: $(PROJ_NAME).bin

# Create a raw binary file from the ELF version
${PROJ_NAME}.hex: ${PROJ_NAME}.elf
	$(Q)$(OBJCOPY) -Oihex $^ $@

# Create the ELF version by mixing together the startup file,
# application, and linker file
${PROJ_NAME}.elf: $(STARTUP) $(SRC)
	$(CC) -o $@ $(CFLAGS) -nostartfiles -Wl,-Tstm32.ld $^
	
