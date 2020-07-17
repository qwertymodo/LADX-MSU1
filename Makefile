INPUT:=			ladx
TARGET:=		$(INPUT)-msu1.gbc
NMIADDRESS:=	0x1800
CFLAGS:=		-d input=$(INPUT).gbc -d MSU1BASE=$(NMIADDRESS)
ifdef REV
CFLAGS+=		-d ROM_VERSION_$(REV)
endif

all: patch

sgb/sgb_msu1.bin: sgb/sgb_msu1.sfc
	sgb/bin2cmd.py $< $@ ${NMIADDRESS}

%.gbc: ladx-msu1.asm sgb/sgb_msu1.bin sgb/*.asm
	bass ${CFLAGS} -o $@ $<

%.sfc: %.asm
	bass -d BASEADDRESS=${NMIADDRESS} -o $@ $<

checksum: ${TARGET}
	@printf "\0\0" \
	| dd of=${TARGET} bs=1 seek=334 count=2 conv=notrunc 2>/dev/null

	@printf "obase=16;(%s)%% 65536\n" "$$(od -An -t u1 -w1 -v ${TARGET})" \
	| paste -sd+ | bc | xxd -p -r \
	| dd of=${TARGET} bs=1 seek=334 count=2 conv=notrunc 2>/dev/null
	

patch: checksum
	flips-linux --create -b ${INPUT}.gbc ${TARGET}