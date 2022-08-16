INPUT:=			ladx
TARGET:=		${INPUT}-msu1.gbc
NMIADDRESS:=	0x1800
CFLAGS:=		-d input=${INPUT}.gbc -d MSU1BASE=${NMIADDRESS}
ifdef REV
CFLAGS+=		-d ROM_VERSION_${REV}
endif

SRCFILES:=	ladx-msu1.asm				\
			macros.inc					\
			constants.inc				\
			sgb/sgb_msu1.asm			\
			sgb/sgb.asm					\
			sgb/commands.asm			\
			sgb/patches.asm				\
			sgb/sgb_user_palette.asm	\
			sgb/sgb_user_commands.asm	\
			sgb/sgb_code_loading_screen.asm

BINFILES:=		sgb/loadingtiles.bin	\
				sgb/loadingtilemap.bin

SCRIPTS:=		sgb/bin2cmd.py

REVISIONS:= j10 j11 j12 u10 u11 u12 f10 f11 g10 g11

.PHONY: all dist dist-src ${REVISIONS}

all: ${REVISIONS}

dist: ${REVISIONS}
#	@tar -zcvf "${INPUT}-msu1_$$(date '+%Y%m%d').tar.gz" ${INPUT}_*-msu1.bps CHANGELOG.txt
	@zip "${INPUT}-msu1_$$(date '+%Y%m%d').zip" ${INPUT}_*-msu1.bps CHANGELOG.txt

dist-src: ${SRCFILES} ${BINFILES} ${SCRIPTS}
#	@tar -zcvf "${INPUT}-msu1_$$(date '+%Y%m%d')-src.tar.gz" Makefile $^
	@zip "${INPUT}-msu1_$$(date '+%Y%m%d')-src.zip" Makefile $^

j10:
	make -B patch REV=JP_1_0 INPUT=ladx_j1.0

j11:
	make -B patch REV=JP_1_1 INPUT=ladx_j1.1

j12:
	make -B patch REV=JP_1_2 INPUT=ladx_j1.2

u10:
	make -B patch REV=US_1_0 INPUT=ladx_u1.0

u11:
	make -B patch REV=US_1_1 INPUT=ladx_u1.1

u12:
	make -B patch REV=US_1_2 INPUT=ladx_u1.2

f10:
	make -B patch REV=FR_1_0 INPUT=ladx_f1.0

f11:
	make -B patch REV=FR_1_1 INPUT=ladx_f1.1

g10:
	make -B patch REV=DE_1_0 INPUT=ladx_g1.0

g11:
	make -B patch REV=DE_1_1 INPUT=ladx_g1.1

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