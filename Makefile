CLEAN=include src sim disasm arm.nml arm.irg
GFLAGS= \
	-m loader:old_elf \
	-m code:code \
	-m env:void_env \
	-m mem:vfast_mem \
	-m sys_call:extern/sys_call \
	-v \
	-a disasm.c \
	-S

NMP = nmp/arm.nmp nmp/condition.nmp \
	nmp/dataProcessingMacro.nmp nmp/dataProcessing.nmp \
	nmp/othersInstr.nmp nmp/othersInstrMacro.nmp \
	nmp/simpleType.nmp nmp/stateReg.nmp \
	nmp/tempVar.nmp nmp/shiftedRegister.nmp \
	nmp/loadStoreM.nmp nmp/loadStoreM_Macro.nmp

GLISS_PATH=../gliss2

all: lib arm-disasm arm-sim

arm.nml: $(NMP)
	cd nmp &&  ../$(GLISS_PATH)/gep/gliss-nmp2nml.pl arm.nmp ../$@  && cd ..

arm.irg: arm.nml
	$(GLISS_PATH)/irg/mkirg $< $@
	$(GLISS_PATH)/irg/print_irg -i $@ > arm.out

src include: arm.irg
	$(GLISS_PATH)/gep/gep $(GFLAGS) $<

lib: src include/arm/config.h src/disasm.c
	(cd src; make)

arm-disasm:
	cd disasm; make

include/arm/config.h: config.tpl
	test -d src || mkdir src
	cp config.tpl include/arm/config.h

src/disasm.c: arm.irg
	$(GLISS_PATH)/gep/gliss-disasm arm.nml -o $@ -c

arm-sim:
	cd sim; make

clean:
	rm -rf $(CLEAN)

distclean:
	rm -Rf $(CLEAN) arm.irg arm.out
