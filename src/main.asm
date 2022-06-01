; -----------------------------------------------------------
; Mikrokontroller alapu rendszerek hazi feladat
; Keszitette: Hanics Mihaly Peter
; Neptun code: UJ47SY
; Feladat leirasa: Az IRAM egy adott cellajaban egy megadott szamu bit bitindexenek kiszamitasa, ertekenek visszaadasa 11 biten.
;

; Breakpointot a 76. sorba erdemes tenni.

; -----------------------------------------------------------

$NOMOD51

$INCLUDE (SI_EFM8BB3_Defs.inc) ; regiszter és SFR definíciók

; Ugrastabla
	CSEG AT 0
	SJMP Main

myprog SEGMENT CODE			;kodszegmens letrehozas
RSEG myprog 				;illetve kivalasztas
; ------------------------------------------------------------
; Foprogram
; ------------------------------------------------------------
; Feladata: a szukseges inicializalasok elvegzese es a feladatot
;			 megvalosito szubrutinok meghivasa. A szubrutinok
;            lentebb talalhatoak.
; ------------------------------------------------------------
Main:  ; Foprogram
	CLR IE_EA ; interruptok tiltasa watchdog tiltas idejere
	MOV WDTCN,#0DEh ; watchdog timer tiltasa
	MOV WDTCN,#0ADh

	SETB IE_EA ; interruptengedelyezes

	; Parameterek elokeszitese szubrutin hivasokhoz

	; Bemenetek:
	MOV R1, #0xAC ; Elso parameter: IRAM cellaszam
	MOV R2, #0x07 ; Masodik parameter: Cellan beluli bit szama

	; Szubrutinba ugras:
	CALL CalculateBitIndex
	JMP $ ; vegtelen ciklusban varakozas

	; Kimenet:
	; A "bitindex" 11 bites ertek, ket 8-bites regiszterben tarolva.

; -----------------------------------------------------------
; CalculateBitIndex Szubrutin
; -----------------------------------------------------------
; Funkcio: Kap 2 darab 8 bites szamot az R1 es R2 bemeneten, felteve, hogy az R2 felso 5 bitje 0 (tehat 3 biten leirhato szam), R3 es R4 regiszteren
;			az also 11 biten tarolja az R1 8bites szam es R2 3 bites szam egymas utan fuzeset (MSB az R1 legfelso bitje, LSB az R2 also bitje).
; Bementek:		R1, R2: IRAM cellaszam ill. bitszam
; Kimenetek:  	R3: A bitindex ertekenek
; Ezen regisztereket modositja:
;				A, R3, R4
; -----------------------------------------------------------
CalculateBitIndex:
	; Biztonsagi lepes:
	; MOV A, R2
	; ANL A, #00000111b
	; MOV R2, A
	; Ez biztositja, hogy R2 nem legalabb 8, ha valami felhasznaloi hiba tortenne elozoleg
	MOV A, R1 ; ne valtoztassuk a bemeneti regiszterek erteket, az akkumulatorban szamoljunk
	RL A ; 3 darab balra shifteles, hogy a felso 3 bitje R1-nek az akkumulator also 3 bitjere keruljon
	RL A
	RL A
	MOV R4, A ; mar most betesszuk a masik regiszterbe a shiftelt szamot, hogy eltaroljuk erteket
	ANL A,#00000111b ; Az akkumulator also 3 bitjebol allo szamot kepezzuk, ez R1 felso 3 bitje
	MOV	R3, A ; Eltaroljuk a szamot a felso kimeneti regiszteren
	MOV A, R4 ; visszatoltjuk az elobb kimentett erteket
	ANL A, #11111000b ; maszkolunk hogy az akkumulatorban csak a felso 5 bit maradjon: ez R1 also 5 bitje
	ADD A, R2 ; betesszuk az also 3 bitre R2 erteket
	MOV R4, A ; kimentjuk az eredmenyt.
	; Breakpointot ide helyezzunk
	RET
END
