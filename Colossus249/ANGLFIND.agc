### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	ANGLFIND.agc
# Purpose:	Part of the source code for Colossus, build 249.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), possibly for Apollo 8 and 9.
# Assembler:	yaYUL
# Reference:	pp. 394-406 of 1701.pdf.
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Mod history:	08/10/04 RSB.	Began transcribing.
#
# The contents of the "Colossus249" files, in general, are transcribed 
# from a scanned document obtained from MIT's website,
# http://hrst.mit.edu/hrs/apollo/public/archive/1701.pdf.  Notations on this
# document read, in part:
#
#	Assemble revision 249 of AGC program Colossus by NASA
#	2021111-041.  October 28, 1968.  
#
#	This AGC program shall also be referred to as
#				Colossus 1A
#
#	Prepared by
#			Massachusetts Institute of Technology
#			75 Cambridge Parkway
#			Cambridge, Massachusetts
#	under NASA contract NAS 9-4065.
#
# Refer directly to the online document mentioned above for further information.
# Please report any errors (relative to 1701.pdf) to info@sandroid.org.
#
# In some cases, where the source code for Luminary 131 overlaps that of 
# Colossus 249, this code is instead copied from the corresponding Luminary 131
# source file, and then is proofed to incorporate any changes.

# Page 394
		BANK	15
		SETLOC	KALCMON1
		BANK
		
		EBANK=	BCDU
		
		COUNT	22/KALC
		
KALCMAN3	TC	INTPRET
		RTB
			READCDUK	# PICK UP CURRENT CDU ANGLES
		STORE	BCDU		# STORE THE INITIAL S/C ANGLES
		AXC,2	TLOAD		# COMPUTE THE TRANSFORMATION FROM
			MIS		# INITIAL S/C AXES TO STABLE MEMBER AXES
			BCDU		# (MIS)
		CALL
			CDUTODCM	
		AXC,2	TLOAD		# COMPUTE THE TRANSFORMATION FROM
			MFS		# FINAL S/C AXES TO STABLE MEMBER AXES
			CPHI		# (MFS)
		CALL
			CDUTODCM
SECAD		AXC,1	CALL		# MIS AND MFS ARRAYS CALCULATED
			MIS
			TRANSPOS
		VLOAD
		STADR
		STOVL	TMIS	+12D
		STADR
		STOVL	TMIS	+6
		STADR
		STORE	TMIS		# TMIS = TRANSPOSE(MIS) SCALED BY 2
		AXC,1	AXC,2
			TMIS
			MFS
		CALL
			MXM3
		VLOAD	STADR
		STOVL	MFI	+12D
		STADR
		STOVL	MFI	+6
		STADR
		STORE	MFI		# MFI = TMIS MFS (SCALED BY 4)
		SETPD	CALL		# TRANSPOSE MFI IN PD LIST
			18D
			TRNSPSPD
		VLOAD	STADR
		STOVL	TMFI	+12D
		STADR
		STOVL	TMFI	+6
# Page 395
		STADR
		STORE	TMFI		# TMFI = TRANSPOSE (MFI) SCALED BY 4
		
# CALCULATE COFSKEW AND MFISYM

		DLOAD	DSU
			TMFI	+2
			MFI	+2
		PDDL	DSU		# CALCULATE COF SCALED BY 2/SIN(AM)
			MFI	+4
			TMFI	+4
		PDDL	DSU
			TMFI	+10D
			MFI	+10D
		VDEF
		STORE	COFSKEW		# EQUALS MFISKEW
		
# CALCULATE AM AND PROCEED ACCORDING TO ITS MAGNITUDE

		DLOAD	DAD
			MFI
			MFI	+16D
		DSU	DAD
			DP1/4TH
			MFI	+8D
		STORE	CAM		# CAM = (MFI0+MFI4+MFI8-1)/2 HALF-SCALE
		ARCCOS
		STORE	AM		# AM=ARCCOS(CAM)  (AM SCALED BY 2)
		DSU	BPL
			MINANG
			CHECKMAX
		EXIT			# MANEUVER LESS THAN 0.25 DEG
		INHINT			# GO DIRECTLY INTO ATTITUDE HOLD
		CS	ONE		# ABOUT COMMANDED ANGLES
		TS	HOLDFLAG	# NOGO WILL STOP ANY RATE AND SET UP FOR A
		TC	LOADCDUD	# GOOD RETURN
		TCF	NOGO
		
CHECKMAX	DLOAD	DSU
			AM
			MAXANG
		BPL	VLOAD
			ALTCALC		# UNIT
			COFSKEW		# COFSKEW
		UNIT
		STORE	COF		# COF IS THE MANEUVER AXIS
		GOTO			# SEE IF MANEUVER GOES THRU GIMBAL LOCK
			LOCSKIRT
ALTCALC		VLOAD	VAD		# IF AM GREATER THAN 170 DEGREES
			MFI
# Page 396
			TMFI
		VSR1
		STOVL	MFISYM
			MFI	+6
		VAD	VSR1
			TMFI	+6
		STOVL	MFISYM	+6
			MFI	+12D
		VAD	VSR1
			TMFI	+12D
		STORE	MFISYM	+12D	# MFISYM=(MFI+TMFI)/2	SCALED BY 4
		
# CALCULATE COF

		DLOAD	SR1
			CAM
		PDDL	DSU		# PD0 CAM
			DPHALF
			CAM
		BOVB	PDDL		# PDL 1 - CAM
			SIGNMPAC
			MFISYM	+16D
		DSU	DDV
			0
			2
		SQRT	PDDL		# COFZ = SQRT(MFISYM8-CAM)/(1-CAM)
			MFISYM	+8D
		DSU	DDV
			0
			2
		SQRT	PDDL		# COFY = SQRT(MFISYM4-CAM)/(1-CAM)
			MFISYM
		DSU	DDV
			0
			2
		SQRT	VDEF		# COFX = SQRT(MFISYM-CAM)/(1-CAM)
		UNIT
		STORE	COF
		
# DETERMINE LARGEST COF AND ADJUST ACCORDINGLY

COFMAXGO	DLOAD	DSU
			COF
			COF	+2
		BMN	DLOAD		# COFY G COFX
			COMP12
			COF
		DSU	BMN
			COF	+4
# Page 397
			METHOD3		# COFZ G COFX OR COFY
		GOTO
			METHOD1		# COFX G COFY OR COFZ
COMP12		DLOAD	DSU
			COF	+2
			COF	+4
		BMN
			METHOD3		# COFZ G COFY OR COFX
			
METHOD2		DLOAD	BPL		# COFY MAX
			COFSKEW	+2	# UY
			U2POS
		VLOAD	VCOMP
			COF
		STORE	COF
U2POS		DLOAD	BPL
			MFISYM	+2	# UX UY
			CKU21
		DLOAD	DCOMP		# SIGN OF UX OPPOSITE TO UY
			COF
		STORE	COF
CKU21		DLOAD	BPL
			MFISYM	+10D	# UY UZ
			LOCSKIRT
		DLOAD	DCOMP		# SIGN OF UZ OPPOSITE TO UY
			COF	+4
		STORE	COF	+4
		GOTO
			LOCSKIRT
METHOD1		DLOAD	BPL		# COFX MAX
			COFSKEW		# UX
			U1POS
		VLOAD	VCOMP
			COF
		STORE	COF
U1POS		DLOAD	BPL
			MFISYM	+2	# UX UY
			CKU12
		DLOAD	DCOMP
			COF	+2	# SIGN OF UY OPPOSITE TO UX
		STORE	COF	+2
CKU12		DLOAD	BPL
			MFISYM	+4	# UX UZ
			LOCSKIRT
		DLOAD	DCOMP		# SIGN OF UZ OPPOSITE TO UY
			COF	+4
		STORE	COF	+4
		GOTO
			LOCSKIRT
METHOD3		DLOAD	BPL		# COFZ MAX
# Page 398
			COFSKEW	+4	# UZ
			U3POS
		VLOAD	VCOMP
			COF
		STORE	COF
U3POS		DLOAD	BPL
			MFISYM	+4	# UX UZ
			CKU31
		DLOAD	DCOMP
			COF		# SIGN OF UX OPPOSITE TO UZ
		STORE	COF
CKU31		DLOAD	BPL
			MFISYM	+10D	# UY UZ
			LOCSKIRT
		DLOAD	DCOMP
			COF	+2	# SIGN OF UY OPPOSITE TO UZ
		STORE	COF	+2
		GOTO
			LOCSKIRT

# Page 399
# MATRIX OPERATIONS

MXM3		SETPD			# MXM3 MULTIPLIES 2 3X3 MATRICES
			0		# AND LEAVES RESULT IN PD LIST
		DLOAD*	PDDL*		# ADDRESS OF 1ST MATRIX IN XR1
			12D,2		# ADDRESS OF 2ND MATRIX IN XR2
			6,2
		PDDL*	VDEF		# DEFINE VECTOR M2(COL 1)
			0,2
		MXV*	PDDL*		# M1XM2(COL 1) IN PD
			0,1
			14D,2
		PDDL*	PDDL*
			8D,2
			2,2
		VDEF	MXV*		# DEFINE VECTOR M2(COL 2)
			0,1
		PDDL*	PDDL*		# M1XM2(COL2) IN PD
			16D,2
			10D,2
		PDDL*	VDEF		# DEFINE VECTOR M2(COL 3)
			4,2
		MXV*	PUSH		# M1XM2(COL 3) IN PD
			0,1
		GOTO
			TRNSPSPD	# REVERSE ROWS AND COLS IN PD AND
					# RETURN WITH M1XM2 IN PD LIST
TRANSPOS	SETPD	VLOAD*		# TRANSPOS TRANSPOSES A 3X3 MATRIX
			0		#	AND LEAVES RESULT IN PD LIST
			0,1		# MATRIX ADDRESS IN XR1
		PDVL*	PDVL*
			6,1
			12D,1
		PUSH			# MATRIX IN PD
TRNSPSPD	DLOAD	PDDL		# ENTER WITH MATRIX IN PD LIST
			2
			6
		STODL	2
		STADR
		STODL	6
			4
		PDDL
			12D
		STODL	4
		STADR
		STODL	12D
			10D
		PDDL
# Page 400
			14D
		STODL	10D
		STADR
		STORE	14D
		RVQ			# RETURN WITH TRANSPOSED MATRIX IN PD LIST
MINANG		DEC	.00069375
MAXANG		DEC	.472222

# GIMBAL LOCK CONSTANTS

# D = MGA CORRESPONDING TO GIMBAL LOCK = 60 DEGREES
# NGL = BUFFER ANGLE (TO AVOID DIVISIONS BY ZERO) = 2 DEGREES

SD		DEC	.433015		# = SIN(D)
K3S1		DEC	.86603		# = SIN(D)
K4		DEC	-.25		# = -COS(D)
K4SQ		DEC	.125		# = COS(D)COS(D)
SNGLCD		DEC	.008725		# = SIN(NGL)COS(D)
CNGL		DEC	.499695		# = COS(NGL)
READCDUK	INHINT			# LOAD T(MPAC) WITH THE CURRENT CDU ANGLES
		CA	CDUZ
		TS	MPAC	+2
		EXTEND
		DCA	CDUX
		RELINT
		TCF	TLOAD	+6
		BANK	16
		SETLOC	KALCMON2
		BANK
		
		COUNT*	$$/KALC
		
CDUTODCM	AXT,1	SSP		# SUBROUTINE TO COMPUTE DIRECTION COSINE
		OCT	3		# MATRIX RELATING S/C AXES TO STARLE
			S1		# MEMBER AXES FROM 3 CDU ANGLES IN T(MPAC)
		OCT	1		# SET XR1, S1, AND PD FOR LOOP
		STORE	7
		SETPD
			0
LOOPSIN		SLOAD*	RTB
			10D,1
			CDULOGIC
		STORE	10D		# LOAD PD WITH 0	SIN(PHI)
		SIN	PDDL		#	       2	COS(PHI)
			10D		#	       4	SIN(THETA)
		COS	PUSH		#	       6	COS(THETA)
		TIX,1	DLOAD		#	       8	SIN(PSI)
			LOOPSIN		#	      10	COS(PSI)
			6
		DMP	SL1
			10D
# Page 401
		STORE	0,2
		DLOAD
			4
		DMP	PDDL
			0		# (PD6 SIN(THETA)SIN(PHI))
			6
		DMP	DMP
			8D
			2
		SL1	BDSU
			12D
		SL1
		STORE	2,2
		DLOAD
			2
		DMP	PDDL		# (PD7 COS(PHI)SIN(THETA)) SCALED 4
			4
			6
		DMP	DMP
			8D
			0
		SL1
		DAD	SL1
			14D
		STORE	4,2
		DLOAD
			8D
		STORE	6,2
		DLOAD
			10D
		DMP	SL1
			2
		STORE	8D,2
		DLOAD
			10D
		DMP	DCOMP
			0
		SL1
		STORE	10D,2
		DLOAD
			4
		DMP	DCOMP
			10D
		SL1
		STORE	12D,2
		DLOAD
		DMP	SL1		# (PUSH UP 7)
			8D
		PDDL	DMP		# (PD7 COS(PHI)SIN(THETA)SIN(PSI)) SCALE 4
			6
# Page 402
			0
		DAD	SL1		# (PUSH UP 7)
		STADR			# C7=COS(PHI)SIN(THETA)SIN(PSI)
		STORE	14D,2
		DLOAD
		DMP	SL1		# (PUSH UP 6)
			8D
		PDDL	DMP		# (PD6 SIN(THETA)SIN(PHI)SIN(PSI)) SCALE 4
			6
			2
		DSU	SL1		# (PUSH UP 6)
		STADR
		STORE	16D,2		# C8=-SIN(THETA)SIN(PHI)SIN(PSI)
		RVQ			#    +COS(THETA)COS(PHI)
ENDOCM		EQUALS
		BANK	15
		SETLOC	KALCMON1
		BANK
		
# CALCULATION OF THE MATRIX DEL.......
#
#	*      *               __T           *
#	DEL = (IDMATRIX)COS(A)+UU (1-COS(A))+UX SIN(A)		SCALED 1
#
#             _
#	WHERE U IS A UNIT VECTOR (DP SCALED 2) ALONG THE AXIS OF ROTATION.
#	A IS THE ANGLE OF ROTATION (DP SCALED 2).
#					   _
#	UPON ENTRY THE STARTING ADDRESS OF U IS COF, AND A IS IN MPAC.

		COUNT	22/KALC
		
DELCOMP		SETPD	PUSH		# MPAC CONTAINS THE ANGLE A
			0
		SIN	PDDL		# PD0 = SIN(A)
		COS	PUSH		# PD2 = COS(A)
		SR2	PDDL		# PD2 = COS(A)
		BDSU	BOVB		# PD4 = 1-COS(A)
			DPHALF
			SIGNMPAC
			
# COMPUTE THE DIAGONAL COMPONENTS OF DEL

		PDDL
			COF
		DSQ	DMP
			4
		DAD	SL3
# Page 403
			2
		BOVB
			SIGNMPAC
		STODL	DEL		# UX UX(U-COS(A)) +COS(A)
			COF	+2
		DSQ	DMP
			4
		DAD	SL3
			2
		BOVB	
			SIGNMPAC
		STODL	DEL	+8D	# UY UY(1-COS(A)) +COS(A)
			COF	+4
		DSQ	DMP
			4
		DAD	SL3
			2
		BOVB
			SIGNMPAC
		STORE	DEL	+16D	# UZ UZ(1-COS(A)) +COS(A)
		
# COMPUTE THE OFF-DIAGONAL TERMS OF DEL

		DLOAD	DMP
			COF
			COF	+2
		DMP	SL1
			4
		PDDL	DMP		# D6	UX UY (1-COS A)
			COF	+4
			0
		PUSH	DAD		# D8	UZ SIN A
			6
		SL2	BOVB
			SIGNMPAC
		STODL	DEL	+6
		BDSU	SL2
		BOVB
			SIGNMPAC
		STODL	DEL	+2
			COF
		DMP	DMP
			COF	+4
			4
		SL1	PDDL		# D6	UX UZ (1-COS A)
			COF	+2
		DMP	PUSH		# D8	UY SIN(A)
			0
		DAD	SL2
			6
# Page 404
		BOVB
			SIGNMPAC
		STODL	DEL	+4	# UX UZ (1-COS(A))+UY SIN(A)
		BDSU	SL2
		BOVB
			SIGNMPAC
		STODL	DEL	+12D	# UX UZ (U-COS(A))-UY SIGN(A)
			COF	+2
		DMP	DMP
			COF	+4
			4
		SL1	PDDL		# D6	UY UZ (1-COS(A))
			COF
		DMP	PUSH		# D6	UX SIN(A)
			0
		DAD	SL2
			6
		BOVB
			SIGNMPAC
		STODL	DEL	+14D	# UY UZ(1-COS(A)) +UX SIN(A)
		BDSU	SL2
		BOVB	
			SIGNMPAC
		STORE	DEL	+10D	# UY UZ(1-COS(A)) -UX SIN(A)
		RVQ
		
# DIRECTION COSINE MATRIX TO CDU ANGLE ROUTINE
# X1 CONTAINS THE COMPLEMENT OF THE STARTING ADDRESS FOR MATRIX (SCALED 2)
# LEAVES CDU ANGLES SCALED 2PI IN V(MPAC)
# COS(MGA) WILL BE LEFT IN S1 (SCALED 1)
#
# THE DIRECTION COSINE MATRIX RELATING S/C AXES TO STABLE MEMBER AXES CAN BE WRITTEN AS ***
#
#	C =COS(THETA)COS(PSI)
#	 0
#
#	C =-COS(THETA)SIN(PSI)COS(PHI)+SIN(THETA)SIN(PHI)
#	 1
#
#	C =COS(THETA)SIN(PSI)SIN(PHI)+SIN(THETA)COS(PHI)
#	 2
#
#	C =SIN(PSI)
#	 3
#
#	C =COS(PSI)COS(PHI)
#	 4
#
#	C =-COS(PSI)SIN(PHI)
#	 5
#
#	C =-SIN(THETA)COS(PSI)
#	 6
#
#	C =SIN(THETA)SIN(PSI)COS(PHI)+COS(THETA)SIN(PHI)
#	 7
# Page 405
#	C =-SIN(THETA)SIN(PSI)SIN(PHI)+COS(THETA)COS(PHI)
#	 8
#
#	WHERE	PHI = OGA
#		THETA = IGA
#		PSI = MGA

DCMTOCDU	DLOAD*	ARCSIN
			6,1
		PUSH	COS		# PD +0		PSI
		SL1	BOVB
			SIGNMPAC
		STORE	S1
		DLOAD*	DCOMP
			12D,1
		DDV	ARCSIN
			S1
		PDDL*	BPL		# PD +2		THETA
			0,1		# MUST CHECK THE SIGN OF COS(THETA)
			CKTHETA		# TO DETERMINE THE PROPER QUADRANT
		DLOAD	DCOMP
		BPL	DAD
			SUHALFA
			DPHALF
		GOTO
			CALCPHI
SUHALFA		DSU
			DPHALF
CALCPHI		PUSH
CKTHETA		DLOAD*	DCOMP
			10D,1
		DDV	ARCSIN
			S1
		PDDL*	BPL		# PUSH DOWN PHI
			8D,1
			CKPHI
		DLOAD	DCOMP		# PUSH UP PHI
		BPL	DAD
			SUHALFAP
			DPHALF
		GOTO
			VECOFANG
SUHALFAP	DSU	GOTO
			DPHALF
			VECOFANG
CKPHI		DLOAD			# PUSH UP PHI
VECOFANG	VDEF	RVQ

# Page 406
# ROUTINE FOR TERMINATING AUTOMATIC MANEUVERS

NOGOM2		INHINT			# THIS LOCATION ACCESSED BY A BZMF NOGO -2
		TC	ZEROERROR
		
NOGO		INHINT
		TC	STOPRATE
				
					# TERMINATE MANEUVER
		CAF	TWO		# NOTE: ALL RETURNS ARE NOW MADE VIA
		TC	WAITLIST	# GOODEND
		SBANK=	PINSUPER
		EBANK=	BCDU
		2CADR	ENDMANU
		
		TCF	ENDOFJOB
		
