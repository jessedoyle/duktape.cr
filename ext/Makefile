.PHONY: libduktape clean

CURRENT := $(shell pwd)
EXT := $(CURRENT)
PREV := $(shell dirname `pwd`])
OUTPUT := $(PREV)/src/.build
LIBDIR := $(OUTPUT)/lib
INCLUDEDIR := $(OUTPUT)/include

CFLAGS ?= \
	-pedantic \
	-c \
	-std=c99 \
	-O2 \
	-fstrict-aliasing \
	-fomit-frame-pointer

libduktape: $(OUTPUT)/libduktape.o $(LIBDIR)/libduktape.a $(INCLUDEDIR)/duktape.h
$(OUTPUT)/libduktape.o: $(EXT)/duktape.c
	@mkdir -p $(OUTPUT)
	$(CC) -o $@ $(EXT)/duktape.c $(CFLAGS)
$(LIBDIR)/libduktape.a:
	@mkdir -p $(LIBDIR)
	ar rcs $(LIBDIR)/libduktape.a $(OUTPUT)/libduktape.o
$(INCLUDEDIR)/duktape.h:
	@mkdir -p $(INCLUDEDIR)
	cp $(EXT)/duktape.h $(EXT)/duk_config.h $(INCLUDEDIR)
clean:
	rm -rf $(OUTPUT)
	rm -rf $(CURRENT)/.crystal
