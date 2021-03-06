# This makefile was generated by autochaos 0.2.0. Please do not
# tamper with it unless you are very certain about what you are doing.

ALL_ARGUMENTS = 

PREFIX = /mnt/chaos
PACKAGE = stormG2

# Compiler flags.

CFLAGS = -Wall -W -Wshadow -Wpointer-arith -Waggregate-return \
-Wstrict-prototypes -Wredundant-decls -Winline -Wmissing-prototypes \
-Werror -Wcast-align -Wsign-compare \
-Wmissing-declarations -Wmissing-noreturns -pipe \
-Wnested-externs -O3 -fno-builtin -funsigned-char -g -fomit-frame-pointer -ffreestanding $(EXTRA_CFLAGS) $(DEFINES)

INCLUDES = \
-I../include \
-I.. \
-I. -I$(PREFIX)/data/programming/c/headers

SUB_DIRECTORIES = \
include \
generic \
ia32
ALL_OBJECTS = \
generic/id.o \
generic/list.o \
generic/memory_global.o \
generic/multiboot.o \
generic/slab.o \
ia32/init.o \
ia32/debug.o \
ia32/dispatch.o \
ia32/exception.o \
ia32/gdt.o \
ia32/idt.o \
ia32/main.o \
ia32/memory_virtual.o \
ia32/memory_physical.o \
ia32/process.o \
ia32/thread.o

STATIC_LIBRARY_PATH = $(PREFIX)/data/programming/libraries/static

# Ideally, this would be -lwhatever, but we have not started patching
# the GNU tools yet...

LIBS = 
HEADER_PATH = $(PREFIX)/data/programming/c/headers/$(PACKAGE)/.

# TODO: Those should be overridable.

CC = gcc
NASM = nasm
AR = ar
RANLIB = ranlib
GZIP = gzip -f

%.o: %.c
	@echo Compiling $<...
	@$(CC) -o $(@) $(CFLAGS) $(INCLUDES) $(DEFS) -c $<
	@$(CC) -M $< $(CFLAGS) $(INCLUDES) $(DEFS) > $(*F).dep

%.o: %.S
	@echo Compiling $<...
	@$(CC) -o $(@) $(CFLAGS) $(INCLUDES) $(DEFS) -c $<
	@$(CC) -M $< $(CFLAGS) $(INCLUDES) $(DEFS) > $(*F).dep

%.o: %.asm
	$(NASM) -o $(@) $< -f elf

.PHONY: splash all clean install package-source package-check package

all: splash makefile 
	@for sub_directory in $(SUB_DIRECTORIES) ; do (cd $$sub_directory && echo -e "\n  Compiling directory: $$sub_directory\n" && $(MAKE)) || exit ; done
	@$(MAKE) stormG2

clean: makefile
	@for sub_directory in $(SUB_DIRECTORIES) ; do (cd $$sub_directory && $(MAKE) clean) || exit ; done
	rm -f stormG2
	rm -f *.dep
	-$(MAKE) clean-local
makefile: configure
	@./configure

splash:
	@echo -e "\n  Compiling kernel: stormG2...\n"

configure: autochaos.rules
	@autochaos


LDFLAGS = -nostdlib -Wl,-T,current-arch/kernel.ld -lgcc -Wn $(EXTRA_LDFLAGS)

stormG2: $(OBJECTS) $(ALL_OBJECTS)
	@echo "Linking..."
	@$(CC) -o $(@) $(OBJECTS) $(ALL_OBJECTS) $(LIBS) $(LDFLAGS)

install: all
	@for sub_directory in $(SUB_DIRECTORIES) ; do (cd $$sub_directory && $(MAKE) install) || exit ; done
	mkdir -p $(PREFIX)/system/kernel
	cp stormG2 $(PREFIX)/system/kernel
	strip -R .note -R .comment -R .eh_frame $(PREFIX)/system/kernel/stormG2
	$(GZIP) $(PREFIX)/system/kernel/stormG2 # > $(PREFIX)/system/kernel/stormG2.gz

package-source:
	@for sub_directory in $(SUB_DIRECTORIES) ; do (cd $$sub_directory && $(MAKE) package-source) || exit ; done
	mkdir -p /home/plundis/Projects/chaos/stormG2/package-source/.
	-cp -f autochaos.rules changelog configure COPYING README AUTHORS TODO INSTALL /home/plundis/Projects/chaos/stormG2/package-source/.
	-cp -f makefile.template $(EXTRA_FILES) /home/plundis/Projects/chaos/stormG2/package-source/.
package-check: package-source
	     cd package-source && ./configure $(ALL_ARGUMENTS) && $(MAKE) && $(MAKE) clean
	     find package-source -name makefile -exec rm {} ';'
	     rm package-source/config.h
package: package-check
	rm -rf stormG2-0.0.1
	mv package-source stormG2-0.0.1
	tar cvIf stormG2-0.0.1.tar.bz2 stormG2-0.0.1
	     

# $Id$
# Local rules.

stormG2: current-arch

# FIXME: Make this detect the architecture in some way.

current-arch:
	ln -sf ia32 current-arch

clean-local:
	rm -f current-arch
