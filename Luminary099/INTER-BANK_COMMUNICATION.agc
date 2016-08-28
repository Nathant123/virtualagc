### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	INTER-BANK_COMMUNICATION.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	998-1001
# Mod history:	2009-05-24 RSB	Adapted from the corresponding 
#				Luminary131 file, using page 
#				images from Luminary 1A.
#		2011-05-08 JL	Removed workaround.

# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the MIT Museum.  The digitization
# was performed by Paul Fjeld, and arranged for by Deborah Douglas of
# the Museum.  Many thanks to both.  The images (with suitable reduction
# in storage size and consequent reduction in image quality as well) are
# available online at www.ibiblio.org/apollo.  If for some reason you
# find that the images are illegible, contact me at info@sandroid.org
# about getting access to the (much) higher-quality images which Paul
# actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 001 of AGC program LMY99 by NASA 2021112-61
#	16:27 JULY 14, 1969 

# Page 998
# THE FOLLOWING ROUTINE CAN BE USED TO CALL A SUBROUTINE IN ANOTHER BANK. IN THE BANKCALL VERSION, THE
# CADR OF THE SUBROUTINE IMMEDIATELY FOLLOWS THE TC BANKCALL INSTRUCTION, WITH C(A) AND C(L) PRESERVED.

		BLOCK	02
		COUNT*	$$/BANK
BANKCALL	DXCH	BUF2		# SAVE INCOMING A,L.
		INDEX	Q		# PICK UP CADR.
		CA	0
		INCR	Q		# SO WE RETURN TO THE LOC. AFTER THE CADR.

# SWCALL IS  IDENTICAL TO BANKCALL, EXCEPT THAT THE CADR ARRIVES IN A.

SWCALL		TS	L
		LXCH	FBANK		# SWITCH BANKS, SAVING RETURN.
		MASK	LOW10		# GET SUB-ADDRESS OF CADR.
		XCH	Q		# A,L NOW CONTAINS DP RETURN.
		DXCH	BUF2		# RESTORING INPUTS IF THIS IS A BANKCALL.
		INDEX	Q
		TC	10000		# SETTING Q TO SWRETURN.

SWRETURN	XCH	BUF2 	+1	# COMES HERE TO RETURN TO CALLER. C(A,L)
		XCH	FBANK		# ARE PRESERVED FOR RETURN.
		XCH	BUF2 	+1
		TC	BUF2

# THE FOLLOWING ROUTINE CAN BE USED AS A UNILATERAL JUMP WITH C(A,L) PRESERVED AND THE CADR IMMEDIATELY
# FOLLOWING THE TC POSTJUMP INSTRUCTION.

POSTJUMP	XCH	Q		# SAVE INCOMING C(A).
		INDEX	A		# GET CADR.
		CA	0

# BANKJUMP IS THE SAME AS POSTJUMP, EXCEPT THAT THE CADR ARRIVES IN A.

BANKJUMP	TS	FBANK
		MASK	LOW10
		XCH	Q		# RESTORING INPUT C(A) IF THIS WAS A
Q+10000		INDEX	Q		# POSTJUMP.
PRIO12		TCF	10000		# PRIO12 = TCF	10000 = 12000

# Page 999
# THE FOLLOWING ROUTINE GETS THE RETURN CADR SAVED BY SWCALL OR BANKCALL AND LEAVES IT IN A.

MAKECADR	CAF	LOW10
		MASK	BUF2
		AD	BUF2 	+1
		TC	Q

SUPDACAL	TS	MPTEMP
		XCH	FBANK		# SET FBANK FOR DATA.
		EXTEND
		ROR	SUPERBNK	# SAVE FBANK IN BITS 15-11, AND
		XCH	MPTEMP		# SUPERBANK IN BITS 7-5.
		MASK	LOW10
		XCH	L		# SAVE REL. ADR. IN BANK, FETCH SUPERBITS
		INHINT			# BECAUSE RUPT DOES NOT SAVE SUPERBANK.
		EXTEND
		WRITE	SUPERBNK	# SET SUPERBANK FOR DATA.
		INDEX	L
		CA	10000		# PINBALL (FIX MEM DISP) PREVENTS DCA HERE
		XCH	MPTEMP		# SAVE 1ST WD, FETCH OLD FBANK AND SBANK.
		EXTEND
		WRITE	SUPERBNK	# RESTORE SUPERBANK.
		RELINT
		TS	FBANK		# RESTORE FBANK.
		CA	MPTEMP		# RECOVER FIRST WORD OF DATA.
		RETURN			# 24 WDS. DATACALL 516 MU, SUPDACAL 432 MU

# Page 1000
# THE FOLLOWING ROUTINES ARE IDENTICAL TO BANKCALL AND SWCALL EXCEPT THAT THEY ARE USED IN INTERRUPT.

IBNKCALL	DXCH	RUPTREG3	# USES RUPTREG3,4 FOR DP RETURN ADDRESS.
		INDEX	Q
		CAF	0
		INCR	Q

ISWCALLL	TS	L
		LXCH	FBANK
		MASK	LOW10
		XCH	Q
		DXCH	RUPTREG3
		INDEX	Q
		TC	10000

ISWRETRN	XCH	RUPTREG4
		XCH	FBANK
		XCH	RUPTREG4
		TC	RUPTREG3

# 2. USPRCADR ACCESSES INTERPRETIVE CODING IN OTHER THAN THE USER'S FBANK.  THE CALLING SEQUENCE IS AS FOLLOWS:
#	L	TC	USPRCADR
#	L+1	CADR	INTPRETX	# INTPRETX IS THE INTERPRETIVE CODING
#					# RETURN IS TO L+2

USPRCADR	TS	LOC		# SAVE A
		CA	BIT8
		TS	EDOP		# EXIT INSTRUCTION TO EDOP
		CA	BBANK
		TS	BANKSET		# USER'S BBANK TO BANKSET
		INDEX	Q
		CA	0
		TS	FBANK		# INTERPRETIVE BANK TO FBANK
		MASK	LOW10		# YIELDS INTERPRETIVE RELATIVE ADDRESS
		XCH	Q		# INTERPRETIVE ADDRESS TO Q, FETCHING L+1
		XCH	LOC		# L+1 TO LOC, RETRIEVING ORIGINAL A
		TCF	Q+10000

# Page 1001
# THERE ARE FOUR POSSIBLE SETTINGS FOR CHANNEL 07.  (CHANNEL 07 CONTAINS SUPERBANK SETTING.)
#
#					PSEUDO-FIXED	  OCTAL PSEUDO
# SUPERBANK	SETTING	S-REG. VALUE	BANK NUMBERS	   ADDRESSES
# ---------	-------	------------	------------	   ---------
# SUPERBANK 3	  OXX	 2000 - 3777	   30 - 37	 70000 - 107777		(WHERE XX CAN BE ANYTHING AND
#										WILL USUALLY BE SEEN AS 11)
# SUPERBANK 4	  100	 2000 - 3777	   40 - 47	110000 - 127777		(AS FAR AS IT CAN BE SEEN,
#										ONLY BANKS 40-43 WILL EVER BE
#										AND ARE PRESENTLY AVAILABLE)
# SUPERBANK 5	  101	 2000 - 3777	   50 - 57	130000 - 147777		(PRESENTLY NOT AVAILABLE TO
#										THE USER)
# SUPERBANK 6	  110	 2000 - 3777	   60 - 67	150000 - 167777		(PRESENTLY NOT AVAILABLE TO
#										THE USER)
# *** THIS ROUTINE MAY BE CALLED BY ANY PROGRAM LOCATED IN BANKS 00 - 27.  I.E., NO PROGRAM LIVING IN ANY
# SUPERBANK SHOULD USE SUPERSW. ***
#
# SUPERSW MAY BE CALLED IN THIS FASHION:
#	CAF	ABBCON		WHERE -- ABBCON  BBCON  SOMETHING --
#	TCR	SUPERSW		(THE SUPERBNK BITS ARE IN THE BBCON)
#	...	  ...
#	 .	   .
#	 .	   .
# OR IN THIS FASHION:
#	CAF	SUPERSET	WHERE SUPERSET IS ONE OF THE FOUR AVAILABLE
#	TCR	SUPERSW		SUPERBANK BIT CONSTANTS:
#	...	  ...			SUPER011 OCTAL  60
#	 .	   .			SUPER100 OCTAL 100
#	 .	   .			SUPER101 OCTAL 120
#					SUPER110 OCTAL 140

SUPERSW		EXTEND
		WRITE	SUPERBNK	# WRITE BITS 7-6-5 OF THE ACCUMULATOR INTO
					# CHANNEL 07
		TC	Q		# TC TO INSTRUCTION FOLLOWING
					# 	TC SUPERSW
		
