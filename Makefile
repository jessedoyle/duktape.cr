.PHONY: all spec duktape libduktape clean

CRYSTAL_BIN  := $(shell which crystal)
SOURCES 		 := $(shell find src -name '*.cr')
SPEC_SOURCES := $(shell find spec -name '*.cr')
CURRENT			 := $(shell pwd)
EXT					 := $(CURRENT)/src/ext
OUTPUT			 := $(CURRENT)/.build
LIBDIR			 := $(CURRENT)/src/.build/lib
INCLUDEDIR   := $(CURRENT)/src/.build/include

all: duktape
duktape: $(OUTPUT)/duktape
libduktape: $(OUTPUT)/libduktape.o $(LIBDIR)/libduktape.a $(INCLUDEDIR)/duktape.h
libdebug:
	@mkdir -p $(OUTPUT)
	gcc -o .build/libduktape.o $(EXT)/duktape.c -c -Wall -std=c99 -DDUK_OPT_DEEP_C_STACK -DDUK_OPT_DEBUGGER_SUPPORT -DDUK_OPT_INTERRUPT_COUNTER -DDUK_OPT_ASSERTIONS
spec: all_spec
	$(OUTPUT)/all_spec
all_spec: $(OUTPUT)/all_spec
$(OUTPUT)/all_spec: $(SOURCES) $(SPEC_SOURCES)
	@mkdir -p $(OUTPUT)
	$(CRYSTAL_BIN) build -o $@ spec/all_spec.cr 2>/dev/null
$(OUTPUT)/duktape: $(SOURCES)
	@mkdir -p $(OUTPUT)
	$(CRYSTAL_BIN) build -o $@ src/duktape.cr 2>/dev/null
$(OUTPUT)/libduktape.o: $(EXT)/duktape.c
	@mkdir -p $(OUTPUT)
	gcc -o $@ $(EXT)/duktape.c -c -Wall -std=c99 -Os -fstrict-aliasing -fomit-frame-pointer -DDUK_OPT_DEEP_C_STACK -DDUK_OPT_DEBUGGER_SUPPORT -DDUK_OPT_INTERRUPT_COUNTER -DDUK_OPT_FASTINT
$(LIBDIR)/libduktape.a:
	@mkdir -p $(LIBDIR)
	ar rcs $(LIBDIR)/libduktape.a $(OUTPUT)/libduktape.o
$(INCLUDEDIR)/duktape.h:
	@mkdir -p $(INCLUDEDIR)
	cp $(EXT)/duktape.h $(INCLUDEDIR)/duktape.h
clean:
	rm -rf $(OUTPUT)
	rm -rf $(CURRENT)/.crystal
cleanlib:
	rm $(LIBDIR)/libduktape.a
	rm $(INCLUDEDIR)/duktape.h
