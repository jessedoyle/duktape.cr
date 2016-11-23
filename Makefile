.PHONY: all spec duktape libduktape clean cleanlib

CRYSTAL_BIN := $(shell which crystal)
SOURCES := $(shell find src -name '*.cr')
SPEC_SOURCES := $(shell find spec -name '*.cr')
CURRENT := $(shell pwd)
EXT := $(CURRENT)/ext
OUTPUT := $(CURRENT)/.build

all: duktape
duktape: $(OUTPUT)/duktape
libduktape:
	$(MAKE) -C $(EXT) libduktape
spec: all_spec
	$(OUTPUT)/all_spec
all_spec: $(OUTPUT)/all_spec
$(OUTPUT)/all_spec: $(SOURCES) $(SPEC_SOURCES)
	@mkdir -p $(OUTPUT)
	$(CRYSTAL_BIN) build -o $@ spec/all_spec.cr 2>/dev/null
$(OUTPUT)/duktape: $(SOURCES)
	@mkdir -p $(OUTPUT)
	$(CRYSTAL_BIN) build -o $@ src/duktape.cr 2>/dev/null
clean:
	rm -rf $(OUTPUT)
	rm -rf $(CURRENT)/.crystal
cleanlib:
	$(MAKE) -C $(EXT) clean
