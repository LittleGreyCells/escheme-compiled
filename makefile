# GNU C++/C Compilers
CXXC = g++
CC   = gcc

CWD = $(shell pwd)

APP    = escheme2

SRCLOC = $(CWD)/src
EVAL   = $(SRCLOC)/eval
CORE   = $(SRCLOC)/core
NOISE  = $(SRCLOC)/linenoise
INCLUDES = -I$(SRCLOC)

SRCS	= \
	$(EVAL)/eval.cxx \
	$(EVAL)/eceval.cxx \
	$(EVAL)/bceval.cxx \
	$(EVAL)/assem.cxx \
	$(CORE)/sexpr.cxx \
	$(CORE)/escheme.cxx \
	$(CORE)/rep.cxx \
	$(CORE)/error.cxx \
	$(CORE)/tstack.cxx \
	$(CORE)/argstack.cxx \
	$(CORE)/regstack.cxx \
	$(CORE)/intstack.cxx \
	$(CORE)/reader.cxx \
	$(CORE)/printer.cxx \
	$(CORE)/symtab.cxx \
	$(CORE)/funtab.cxx \
	$(CORE)/func.cxx \
	$(CORE)/math.cxx \
	$(CORE)/memory.cxx \
	$(CORE)/framestore.cxx \
	$(CORE)/varpool.cxx \
	$(CORE)/pio.cxx \
	$(CORE)/tio.cxx \
	$(CORE)/ipcsoc.cxx \

OBJS	= $(SRCS:.cxx=.o)

#DEBUG_FLAGS = -g
#DEBUG_FLAGS = -O
DEBUG_FLAGS = -O2
#DEBUG_FLAGS = -O3

#CFLAGS = $(DEBUG_FLAGS) -fno-operator-names -fpermissive -std=c++11
#CFLAGS = $(DEBUG_FLAGS) -Wall -Wextra -std=c++11
#CFLAGS = $(DEBUG_FLAGS) -pedantic -std=c++11 -g
CFLAGS = $(DEBUG_FLAGS) -pedantic -std=c++11

LFLAGS = $(DEBUG_FLAGS) -v -lm

DEFINES = 
#DEFINES += -DDO_ECE_CHECK
#DEFINES += -DDO_TRACEINT
#DEFINES += -DGC_STATISTICS_DETAILED
DEFINES += -DBYTE_CODE_EVALUATOR
DEFINES += -DOBJECT_CACHE

$(APP) : $(OBJS) $(NOISE)/linenoise.o
	$(CXXC) -o $@ $(OBJS) $(NOISE)/linenoise.o $(LFLAGS)

%.o	: %.cxx
	$(CXXC) $(DEFINES) $(INCLUDES) -c $(CFLAGS) $< -o $@

$(NOISE)/linenoise.o : $(NOISE)/linenoise.c
	$(CC) -Wall -W -Os -c $< -o $@

clean 	:
	find . -name "*.o" -delete
	find . -name "*~" -delete

install : $(APP)
	mkdir -p /usr/share/$(APP)
	mkdir -p /usr/share/$(APP)/boot
	mkdir -p /usr/share/$(APP)/macros
	mkdir -p /usr/share/$(APP)/compiler
	mkdir -p /usr/share/$(APP)/imager

	cp escheme.scm    /usr/share/$(APP)
	cp boot/*.scm     /usr/share/$(APP)/boot
	cp macros/*.scm   /usr/share/$(APP)/macros
	cp compiler/*.scm /usr/share/$(APP)/compiler
	cp imager/*.scm   /usr/share/$(APP)/imager

	cp $(APP) /usr/local/bin/$(APP)_c
	echo 'ESCHEME=/usr/share/$(APP) $(APP)_c $$@' > /usr/local/bin/$(APP)
	chmod +x /usr/local/bin/$(APP)

uninstall :
	if [ -d /usr/share/$(APP) ]; \
	then \
	   rm -rf /usr/share/$(APP); \
	   rm -f /usr/local/bin/$(APP); \
	   rm -f /usr/local/bin/$(APP)_c; \
	fi
