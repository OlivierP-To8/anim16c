OBJ_ASM = $(OBJ_DIR)tools/c6809.o
OBJ_SAPFS = $(OBJ_DIR)tools/sap/libsap.o $(OBJ_DIR)tools/sap/sapfs.o
OBJ_BMPANIM = $(OBJ_DIR)tools/bmpanim.o
OBJ_PAL = $(OBJ_DIR)tools/palette.o

all: c6809 sapfs bmpanim palette chien dragon disquette

c6809: $(OBJ_ASM)
	gcc -s -o tools/c6809 $(OBJ_ASM)

sapfs: $(OBJ_SAPFS)
	gcc -s -o tools/sapfs $(OBJ_SAPFS)

bmpanim: $(OBJ_BMPANIM) 
	gcc -s -o tools/bmpanim $(OBJ_BMPANIM)

palette: $(OBJ_PAL) 
	gcc -s -o tools/palette $(OBJ_PAL) -lm

$(OBJ_DIR)%.o: %.c
	gcc -c -W -Wall -std=c99 -o $@ $<

clean:
	rm tools/*.o tools/sap/*.o
	rm *.sap *.asm *.lst disk/*.BIN

chien:
	# création des binaires avec les données
	echo '(main)chien1.asm' > chienDat1.asm
	echo '   ORG $$A000' >> chienDat1.asm
	tools/bmpanim data/chien00.bmp data/chien01.bmp FND1 >> chienDat1.asm
	tools/bmpanim data/chien00.bmp data/chien02.bmp FND2 >> chienDat1.asm
	echo 'FRMEND' >> chienDat1.asm
	tools/c6809 chienDat1.asm disk/CHIEN1.BIN
	mv -f codes.lst chienDat1.lst

	echo '(main)chien2.asm' > chienDat2.asm
	echo '   ORG $$A000' >> chienDat2.asm
	tools/bmpanim data/chien01.bmp data/chien03.bmp FRM3 >> chienDat2.asm
	tools/bmpanim data/chien02.bmp data/chien04.bmp FRM4 >> chienDat2.asm
	tools/bmpanim data/chien03.bmp data/chien05.bmp FRM5 >> chienDat2.asm
	tools/bmpanim data/chien04.bmp data/chien06.bmp FRM6 >> chienDat2.asm
	tools/bmpanim data/chien05.bmp data/chien07.bmp FRM7 >> chienDat2.asm
	tools/bmpanim data/chien06.bmp data/chien08.bmp FRM8 >> chienDat2.asm
	tools/bmpanim data/chien07.bmp data/chien09.bmp FRM9 >> chienDat2.asm
	tools/bmpanim data/chien08.bmp data/chien10.bmp FRMA >> chienDat2.asm
	tools/bmpanim data/chien09.bmp data/chien11.bmp FRMB >> chienDat2.asm
	tools/bmpanim data/chien10.bmp data/chien12.bmp FRMC >> chienDat2.asm
	tools/bmpanim data/chien11.bmp data/chien01.bmp FRM1 >> chienDat2.asm
	tools/bmpanim data/chien12.bmp data/chien02.bmp FRM2 >> chienDat2.asm
	echo 'FRMEND' >> chienDat2.asm
	tools/c6809 chienDat2.asm disk/CHIEN2.BIN
	mv -f codes.lst chienDat2.lst

	# compilation du programme
	echo '(main)chien.asm' > chien.asm
	echo '   ORG $$8000' >> chien.asm
	echo 'BANKMIN EQU 4' >> chien.asm
	echo 'BANKMAX EQU 5' >> chien.asm
	echo 'BACKCOL EQU $$AA' >> chien.asm
	cat src/anim16c.asm >> chien.asm
	echo 'DEBFRAME' >> chien.asm
	grep -Po 'Label \K.*?(?= )' chienDat1.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> chien.asm
	grep -Po 'Label \K.*?(?= )' chienDat2.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> chien.asm
	echo 'FINFRAME' >> chien.asm
	tools/palette data/chien01.bmp PALET >> chien.asm
	tools/c6809 chien.asm disk/CHIEN.BIN

dragon:
	# création des binaires avec les données
	echo '(main)dragon1.asm' > dragon01.asm
	echo '   ORG $$A000' >> dragon01.asm
	tools/bmpanim data/dragon00.bmp data/dragon01.bmp FND1 >> dragon01.asm
	tools/bmpanim data/dragon00.bmp data/dragon02.bmp FND2 >> dragon01.asm
	echo 'FRMEND' >> dragon01.asm
	tools/c6809 dragon01.asm disk/DRAGON1.BIN
	mv -f codes.lst dragon01.lst

	echo '(main)dragon2.asm' > dragon02.asm
	echo '   ORG $$A000' >> dragon02.asm
	tools/bmpanim data/dragon01.bmp data/dragon03.bmp FRM03 >> dragon02.asm
	tools/bmpanim data/dragon02.bmp data/dragon04.bmp FRM04 >> dragon02.asm
	tools/bmpanim data/dragon03.bmp data/dragon05.bmp FRM05 >> dragon02.asm
	echo 'FRMEND' >> dragon02.asm
	tools/c6809 dragon02.asm disk/DRAGON2.BIN
	mv -f codes.lst dragon02.lst

	echo '(main)dragon3.asm' > dragon03.asm
	echo '   ORG $$A000' >> dragon03.asm
	tools/bmpanim data/dragon04.bmp data/dragon06.bmp FRM06 >> dragon03.asm
	tools/bmpanim data/dragon05.bmp data/dragon07.bmp FRM07 >> dragon03.asm
	tools/bmpanim data/dragon06.bmp data/dragon08.bmp FRM08 >> dragon03.asm
	echo 'FRMEND' >> dragon03.asm
	tools/c6809 dragon03.asm disk/DRAGON3.BIN
	mv -f codes.lst dragon03.lst

	echo '(main)dragon4.asm' > dragon04.asm
	echo '   ORG $$A000' >> dragon04.asm
	tools/bmpanim data/dragon07.bmp data/dragon09.bmp FRM09 >> dragon04.asm
	tools/bmpanim data/dragon08.bmp data/dragon10.bmp FRM10 >> dragon04.asm
	tools/bmpanim data/dragon09.bmp data/dragon11.bmp FRM11 >> dragon04.asm
	echo 'FRMEND' >> dragon04.asm
	tools/c6809 dragon04.asm disk/DRAGON4.BIN
	mv -f codes.lst dragon04.lst

	echo '(main)dragon5.asm' > dragon05.asm
	echo '   ORG $$A000' >> dragon05.asm
	tools/bmpanim data/dragon10.bmp data/dragon12.bmp FRM12 >> dragon05.asm
	tools/bmpanim data/dragon11.bmp data/dragon13.bmp FRM13 >> dragon05.asm
	tools/bmpanim data/dragon12.bmp data/dragon14.bmp FRM14 >> dragon05.asm
	echo 'FRMEND' >> dragon05.asm
	tools/c6809 dragon05.asm disk/DRAGON5.BIN
	mv -f codes.lst dragon05.lst

	echo '(main)dragon6.asm' > dragon06.asm
	echo '   ORG $$A000' >> dragon06.asm
	tools/bmpanim data/dragon13.bmp data/dragon15.bmp FRM15 >> dragon06.asm
	tools/bmpanim data/dragon14.bmp data/dragon16.bmp FRM16 >> dragon06.asm
	tools/bmpanim data/dragon15.bmp data/dragon17.bmp FRM17 >> dragon06.asm
	tools/bmpanim data/dragon16.bmp data/dragon18.bmp FRM18 >> dragon06.asm
	echo 'FRMEND' >> dragon06.asm
	tools/c6809 dragon06.asm disk/DRAGON6.BIN
	mv -f codes.lst dragon06.lst

	echo '(main)dragon7.asm' > dragon07.asm
	echo '   ORG $$A000' >> dragon07.asm
	tools/bmpanim data/dragon17.bmp data/dragon19.bmp FRM19 >> dragon07.asm
	tools/bmpanim data/dragon18.bmp data/dragon20.bmp FRM20 >> dragon07.asm
	tools/bmpanim data/dragon19.bmp data/dragon01.bmp FRM01 >> dragon07.asm
	tools/bmpanim data/dragon20.bmp data/dragon02.bmp FRM02 >> dragon07.asm
	echo 'FRMEND' >> dragon07.asm
	tools/c6809 dragon07.asm disk/DRAGON7.BIN
	mv -f codes.lst dragon07.lst

	# compilation du programme
	echo '(main)dragon.asm' > dragon.asm
	echo '   ORG $$8000' >> dragon.asm
	echo 'BANKMIN EQU 4' >> dragon.asm
	echo 'BANKMAX EQU 10' >> dragon.asm
	echo 'BACKCOL EQU $$AA' >> dragon.asm
	cat src/anim16c.asm >> dragon.asm
	echo 'DEBFRAME' >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon01.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon02.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon03.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon04.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon05.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon06.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	grep -Po 'Label \K.*?(?= )' dragon07.lst|awk '{for (i=NF; i>0; i--) {printf "   FDB $$%s ", $$i;} printf "\n"; }'|sort >> dragon.asm
	echo 'FINFRAME' >> dragon.asm
	tools/palette data/dragon01.bmp PALET >> dragon.asm
	tools/c6809 dragon.asm disk/DRAGON.BIN

disquette:
	cd disk; ../tools/sapfs -create ../anim16c.sap

	cd disk; ../tools/sapfs -add ../anim16c.sap CHIEN1.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap CHIEN2.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap CHIEN.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap CHIEN.BAS

	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON1.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON2.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON3.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON4.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON5.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON6.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON7.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON.BIN
	cd disk; ../tools/sapfs -add ../anim16c.sap DRAGON.BAS

