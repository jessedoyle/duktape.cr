.PHONY: libduktape clean

CURRENT			:= $(shell pwd)
EXT					:= $(CURRENT)
PREV				:= $(shell dirname `pwd`])
OUTPUT			:= $(PREV)/.build
LIBDIR			:= $(PREV)/.build/lib
INCLUDEDIR	:= $(PREV)/.build/include

libduktape: $(OUTPUT)/libduktape.o $(LIBDIR)/libduktape.a $(INCLUDEDIR)/duktape.h
$(OUTPUT)/libduktape.o: $(EXT)/duktape.c
	@mkdir -p $(OUTPUT)
	gcc -o $@ $(EXT)/duktape.c -c -Wall -std=c99 -Os -fstrict-aliasing -fomit-frame-pointer -DDUK_OPT_DEEP_C_STACK -DDUK_OPT_DEBUGGER_SUPPORT -DDUK_OPT_INTERRUPT_COUNTER -DDUK_OPT_FASTINT -lm
$(LIBDIR)/libduktape.a:
	@mkdir -p $(LIBDIR)
	ar rcs $(LIBDIR)/libduktape.a $(OUTPUT)/libduktape.o
$(INCLUDEDIR)/duktape.h:
	@mkdir -p $(INCLUDEDIR)
	cp $(EXT)/duktape.h $(INCLUDEDIR)/duktape.h
clean:
	rm -rf $(OUTPUT)
	rm -rf $(CURRENT)/.crystal
