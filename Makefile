TARGET_STEM = teatime
ARACHNE_DEVICE=1k
PACKAGE=tq144
ICETIME_DEVICE=hx1k
PROG_BIN=iceprog
TOP=top

PINS_FILE = pins.pcf

YOSYS_LOG  = synth.log
YOSYS_ARGS = -v3 -l $(YOSYS_LOG)

VERILOG_SRCS = $(wildcard *.v)

BIN_FILE  = $(TARGET_STEM).bin
ASC_FILE  = $(TARGET_STEM).asc
JSON_FILE = $(TARGET_STEM).blif

all: $(BIN_FILE)

$(JSON_FILE): $(VERILOG_SRCS)
	yosys $(YOSYS_ARGS) -p "synth_ice40 -json $(JSON_FILE) -top $(TOP)" \
		$(VERILOG_SRCS)

$(ASC_FILE): $(JSON_FILE) $(PINS_FILE)
	nextpnr-ice40 --hx1k --json $(JSON_FILE) --pcf $(PINS_FILE) \
		--asc $(ASC_FILE) --package $(PACKAGE)

$(BIN_FILE): $(ASC_FILE)
	icepack	$< $@

prog: $(BIN_FILE)
	$(PROG_BIN) $<

timings: $(ASC_FILE)
	icetime -tmd $(ICETIME_DEVICE) $<

utilisation: $(JSON_FILE)
	nextpnr-ice40 --hx1k --json $(JSON_FILE) --pcf $(PINS_FILE) \
		--package $(PACKAGE) --no-route --no-place

viz: $(JSON_FILE)
	nextpnr-ice40 --hx1k --json $(JSON_FILE) --pcf $(PINS_FILE) \
		--package $(PACKAGE) --gui

clean:
	rm -f $(BIN_FILE) $(ASC_FILE) $(JSON_FILE) $(YOSYS_LOG)

.PHONY:	all clean prog timings



