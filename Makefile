#
# ARMv5T -- GLISS2 implementation of ARMv5T
# Copyright (C) 2011  IRIT - UPS
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# configuration
GLISS_PREFIX	= ../gliss2
WITH_EABI		= 1	# comment it to enable EABI support (no system call)
WITH_DISASM		= 1	# comment it to prevent disassembler building
WITH_SIM		= 1	# comment it to prevent simulator building
WITH_THUMB		= 1	# comment it to prevent use of THUMB mode

# definitions
GFLAGS= \
	-m loader:old_elf \
	-m code:code \
	-m env:void_env \
	-m mem:vfast_mem \
	-m sys_call:extern/sys_call \
	-v \
	-a disasm.c \
	-S

ifdef WITH_THUMB
MAIN_NMP	=	arm-thumb.nmp
else
MAIN_NMP	=	arm.nmp
endif
NMP = \
	nmp/$(MAIN_NMP) \
	nmp/condition.nmp \
	nmp/dataProcessingMacro.nmp \
	nmp/dataProcessing.nmp \
	nmp/loadStoreM.nmp \
	nmp/loadStoreM_Macro.nmp \
	nmp/othersInstr.nmp \
	nmp/othersInstrMacro.nmp \
	nmp/shiftedRegister.nmp \
	nmp/simpleType.nmp \
	nmp/stateReg.nmp \
	nmp/tempVar.nmp


# goals definition
GOALS		=
SUBDIRS		=	src
CLEAN		=	arm.nml arm.irg
DISTCLEAN	=	include src $(CLEAN)

ifdef WITH_DISASM
GOALS		+=	arm-disasm
SUBDIRS		+=	disasm
DISTCLEAN	+= 	disasm
GFLAGS		+= -a disasm.c
endif

ifdef WITH_SIM
GOALS		+=	arm-sim
SUBDIRS		+=	sim
DISTCLEAN	+=	sim
endif


# rules
all: lib $(GOALS)

arm.nml: $(NMP)
	cd nmp &&  ../$(GLISS_PREFIX)/gep/gliss-nmp2nml.pl $(MAIN_NMP) ../$@  && cd ..

arm.irg: arm.nml
	$(GLISS_PREFIX)/irg/mkirg $< $@
	$(GLISS_PREFIX)/irg/print_irg -i $@ > arm.out

src include: arm.irg
	$(GLISS_PREFIX)/gep/gep $(GFLAGS) $<

lib: src include/arm/config.h src/disasm.c
	(cd src; make)

arm-disasm:
	cd disasm; make

include/arm/config.h: config.tpl
	test -d src || mkdir src
	cp config.tpl $@
ifdef WITH_THUMB
	echo "#define ARM_THUMB" >> $@
endif

src/disasm.c: arm.irg
	$(GLISS_PREFIX)/gep/gliss-disasm arm.nml -o $@ -c

arm-sim:
	cd sim; make

clean:
	rm -rf $(CLEAN)

distclean:
	rm -Rf $(DISTCLEAN) arm.irg arm.out
