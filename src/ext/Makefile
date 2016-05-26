.PHONY: libduktape clean

CURRENT := $(shell pwd)
EXT := $(CURRENT)
PREV := $(shell dirname `pwd`])
OUTPUT := $(PREV)/.build
LIBDIR := $(PREV)/.build/lib
INCLUDEDIR := $(PREV)/.build/include

define DUK_TIMEOUT_C
struct timeout_data \
{ \
	struct timeval start; \
	struct timeval timeout; \
}; \
DUK_INTERNAL_DECL duk_bool_t duk_cr_timeout(void *udata) \
{ \
	if (udata) \
	{ \
		duk_ret_t rc; \
		struct timeout_data data = *(struct timeout_data*) udata; \
		struct timeval now; \
		struct timeval diff; \
		rc = gettimeofday(&now, NULL); \
		if (rc != 0) \
		{ \
			return 1; \
		} \
		diff.tv_sec = now.tv_sec - data.start.tv_sec; \
		diff.tv_usec = now.tv_usec - data.start.tv_usec; \
		if (diff.tv_sec > data.timeout.tv_sec) \
		{ \
			return 1; \
		} \
		else if ((diff.tv_sec == data.timeout.tv_sec) && (diff.tv_usec > data.timeout.tv_usec)) \
		{ \
			return 1; \
		} \
		else \
		{	\
			return 0; \
		}	\
	} \
	else \
	{ \
		return 0; \
	} \
}
endef
export DUK_TIMEOUT_C

DUK_OPTS = \
	-DDUK_OPT_DEBUGGER_SUPPORT \
	-DDUK_OPT_INTERRUPT_COUNTER \
	-DDUK_OPT_FASTINT \
	-DDUK_OPT_DECLARE="$$DUK_TIMEOUT_C" \
	-DDUK_OPT_EXEC_TIMEOUT_CHECK="duk_cr_timeout" \
	-DDUK_OPT_TARGET_INFO=\"duktape.cr\"
CFLAGS = \
	-Wpedantic \
	-c \
	-std=c99 \
	-O2 \
	-fstrict-aliasing \
	-fomit-frame-pointer

libduktape: $(OUTPUT)/libduktape.o $(LIBDIR)/libduktape.a $(INCLUDEDIR)/duktape.h
$(OUTPUT)/libduktape.o: $(EXT)/duktape.c
	@mkdir -p $(OUTPUT)
	$(CC) -o $@ $(EXT)/duktape.c $(CFLAGS) $(DUK_OPTS)
$(LIBDIR)/libduktape.a:
	@mkdir -p $(LIBDIR)
	ar rcs $(LIBDIR)/libduktape.a $(OUTPUT)/libduktape.o
$(INCLUDEDIR)/duktape.h:
	@mkdir -p $(INCLUDEDIR)
	cp $(EXT)/duktape.h $(EXT)/duk_config.h $(INCLUDEDIR)
clean:
	rm -rf $(OUTPUT)
	rm -rf $(CURRENT)/.crystal
