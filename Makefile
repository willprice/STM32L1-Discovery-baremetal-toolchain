## USER DEFINED VARIABLES ##
PROJ_NAME = main
SRC = main.c


## COMPILER VARIABLES ##
CC_PREFIX = arm-none-eabi-
CC        = $(CC_PREFIX)gcc
OBJCOPY   = $(CC_PREFIX)objcopy
STARTUP   = startup_stm32l1xx_md.s
CFLAGS    = -mthumb -mcpu=cortex-m3 -mfix-cortex-m3-ldrd -msoft-float -O -g


## OPENOCD VARIABLES  ##
OOCD_BOARD = stm32ldiscovery.cfg


## TARGETS ##
# List of all binaries to build
all: program

program: $(PROJ_NAME).hex
	openocd -f board/$(OOCD_BOARD) \
					-c "init" -c "targets" -c "halt" \
					-c "flash write_image erase $(PROJ_NAME).hex" \
					-c "verify_image $(PROJ_NAME).hex" \
					-c "reset run" \
					-c "shutdown"

clean:
	@rm -f *.elf
	@rm -f *.hex

# Create a raw binary file from the ELF version
%.hex: %.elf
	$(Q)$(OBJCOPY) -Oihex $^ $@

# Create the ELF version by mixing together the startup file,
# application, and linker file
%.elf: $(STARTUP) $(SRC)
	$(CC) -o $@ $(CFLAGS) -nostartfiles -Wl,-Tstm32.ld $^

.PHONY: all program
