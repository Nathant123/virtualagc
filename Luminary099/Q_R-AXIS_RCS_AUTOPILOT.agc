### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	Q_R-AXIS_RCS_AUTOPILOT.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	1442-1459
# Mod history:	2009-05-27 RSB	Adapted from the corresponding 
#				Luminary131 file, using page 
#				images from Luminary 1A.
#		2009-06-07 RSB	Corrected "DEC 96.0" to "DEC 96", since
#				the former is not compatible with yaYUL.
#		2011-01-06 JL	Fixed pseudo-label indentation.
#
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

# Page 1442
		BANK	17
		SETLOC	DAPS2
		BANK

		EBANK=	CDUXD

		COUNT*	$$/DAPQR

CALLQERR	CA	BIT13		# CALCULATE Q,R ERRORS UNLESS THESE AXES
		EXTEND			# ARE IN MANUAL RATE COMMAND.
		RAND	CHAN31
		CCS	A
		TCF	+5		# IN AUTO COMPUTE Q,R ERRORS
		CS	DAPBOOLS	# IN MANUAL RATE COMMAND?
		MASK	OURRCBIT
		EXTEND
		BZF	Q,RORGTS	# IF SO BYPASS CALCULATION OF ERROS.
		TC	QERRCALC

Q,RORGTS	CCS	COTROLER	# CHOOSE CONTROL SYSTEM FOR THIS DAP PASS:
		TCF	GOTOGTS		#	GTS (ALTERNATES WITH RCS WHEN DOCKED)
		TCF	TRYGTS		#	GTS IF ALLOWED, OTHERWISE RCS
RCS		CAF	ZERO		#	RCS (TRYGTS MAY BRANCH TO HERE)
		TS	COTROLER

		DXCH	EDOTQ
		TC	ROT-TOUV
		DXCH	OMEGAU

# X - TRANSLATION
#
# INPUT:	BITS 7,8 OF CH31 (TRANSLATION CONTROLLER)
#		ULLAGER
#		APSFLAG, DRIFTBIT
#		ACC40R2X, ACRBTRAN
#
# OUTPUT:	NEXTU, NEXTV	CODES OF TRANSLATION FOR AFTER ROTATION
#		SENSETYP	TELL ROTATION DIRECTION AND DESIRE
#
# X-TRANS POLICIES ARE EITHER 4 JETS OR A DIAGONAL PAIR.  IN 2-JET TRANSLATION THE SYSTEM IS SPECIFIED.  A FAILURE
# WILL OVERRIDE THIS SPECIFICATION.  AN ALARM RESULTS WHEN NO POLICY IS AVAILABLE BECAUSE OF FAILURES.

SENSEGET	CA	BIT7		# INPUT BITS OVERRIDE THE INTERNAL BITS
		EXTEND			# SENSETYP WILL NOT OPPOSE ANYTRANS
		RAND	CHAN31
		EXTEND
		BZF	+X0RULGE
# Page 1443
		CA	BIT8
		EXTEND
		RAND	CHAN31
		EXTEND
		BZF	-XTRANS

		CA	ULLAGER
		MASK	DAPBOOLS
		CCS	A
		TCF	+X0RULGE

		TS	NEXTU		# STORE NULL TRANSLATION POLICIES
		TS	NEXTV
		CS	DAPBOOLS	# BURNING OR DRIFTING?
		MASK	DRIFTBIT
		EXTEND
		BZF	TSENSE
		CA	FLGWRD10	# DPS (INCLUDING DOCKED) OR APS?
		MASK	APSFLBIT
		CCS	A
		CAF	TWO		# FAVOR +X JETS DURING AN APS BURN.
TSENSE		TS	SENSETYP
		TCF	QRCONTRL

+X0RULGE	CAF	ONE
-XTRANS		AD	FOUR
		TS	ROTINDEX
		AD	NEG3
		TS	SENSETYP	# FAVOR APPROPRIATE JETS DURING TRANS.
		CA	DAPBOOLS
		MASK	ACC4OR2X
		CCS	A
		TCF	TRANS4

		CA	DAPBOOLS
		MASK	AORBTRAN
		CCS	A
		CA	ONE		# THREE FOR B
		AD	TWO		# TWO FOR A SYSTEM 2 JET X TRANS
TSNUMBRT	TS	NUMBERT

		TC	SELCTSUB

		CCS	POLYTEMP
		TCF	+3
		TC	ALARM
		OCT	02002
		CA	00314OCT
		MASK	POLYTEMP
TSNEXTS		TS	NEXTU
# Page 1444
		CS	00314OCT
		MASK	POLYTEMP
		TS	NEXTV

# Q,R-AXES RCS CONTROL MODE SELECTION
#	SWITCHES	INDICATION WHEN SET
#	BIT13/CHAN31	AUTO, GO TO ATTSTEER
#	PULSES		MINIMUM IMPULSE MODE
#	(OTHERWISE)	RATE COMMAND/ATTITUDE HOLD MODE

QRCONTRL	CA	BIT13		# CHECK MODE SELECT SWITCH.
		EXTEND
		RAND	CHAN31		# BITS INVERTED
		CCS	A
		TCF	ATTSTEER
CHKBIT10	CAF	PULSES		# PULSES = 1 FOR MIN IMP USE OF RHC
		MASK	DAPBOOLS
		EXTEND
		BZF	CHEKSTIK	# IN ATT-HOLD/RATE-COMMAND IF BIT10=0

# MINIMUM IMPULSE MODE

		INHINT
		TC	IBNKCALL
		CADR	ZATTEROR
		CA	ZERO
		TS	QERROR
		TS	RERROR		# FOR DISPLAYS
		RELINT

		EXTEND
		READ	CHAN31
		TS	TEMP31		# IS EQUAL TO DAPTEMP1
		CCS	OLDQRMIN
		TCF	CHECKIN

FIREQR		CA	TEMP31
		MASK	BIT1
		EXTEND
		BZF	+QMIN

		CA	TEMP31
		MASK	BIT2
		EXTEND
		BZF	-QMIN

		CA	TEMP31
		MASK	BIT5
# Page 1445
		EXTEND
		BZF	+RMIN

		CA	TEMP31
		MASK	BIT6
		EXTEND
		BZF	-RMIN

		TCF	XTRANS

CHECKIN		CS	TEMP31
		MASK	OCT63
		TS	OLDQRMIN
		TCF	XTRANS

+QMIN		CA	14MS
		TS	TJU
		CS	14MS
		TCF	MINQR
-QMIN		CS	14MS
		TS	TJU
		CA	14MS
		TCF	MINQR
+RMIN		CA	14MS
		TCF	+2
-RMIN		CS	14MS
		TS	TJU
MINQR		TS	TJV
		CA	MINADR
		TS	RETJADR
		CA	ONE
		TS	OLDQRMIN
MINRTN		TS	AXISCTR
		CA	DAPBOOLS
		MASK	CSMDOCKD
		EXTEND
		BZF	MIMRET
		INDEX	AXISCTR		# IF DOCKED, USE 60MS MINIMUM IMPULSE
		CCS	TJU
		CA	60MS
		TCF	+2
		CS	60MS
		INDEX	AXISCTR
		TS	TJU
MIMRET		CA	DAPBOOLS
		MASK	AORBTRAN
		CCS	A
		CA	ONE
		AD	TWO
		TS	NUMBERT
# Page 1446
		TCF	AFTERTJ

60MS		DEC	96.0
MINADR		GENADR	MINRTN
OCT63		OCT	63
14MS		=	+TJMINT6

TRANS4		CA	FOUR
		TCF	TSNUMBRT

# RATE COMMAND MODE:
#
# DESCRIPTION (SAME AS P-AXIS)

CHEKSTIK	TS	INGTS		# NOT IN GTS WHEN IN ATT HOLD
		CS	ONE		# 1/ACCS WILL DO THE NULLING DRIVES
		TS	COTROLER	# COME BACK TO RCS NEXT TIME
		CA	BIT15
		MASK	CH31TEMP
		EXTEND
		BZF	RHCACTIV	# BRANCH IF OUT OF DETENT.
		CA	OURRCBIT	# ***********
		MASK	DAPBOOLS	# *IN DETENT*	CHECK FOR MANUAL CONTROL
		EXTEND			# ***********	LAST TIME.
		BZF	STILLRCS
		CS	BIT9
		MASK	RCSFLAGS
		TS	RCSFLAGS	# BIT 9 IS 0.
		TCF	DAMPING
40CYCL		OCT	50
1/10S		OCT	1
LINRAT		DEC	46

# ===========================================================

DAMPING		CA	ZERO
		TS	SAVEHAND
		TS	SAVEHAND +1
RHCACTIV	CCS	SAVEHAND	# ******************
		TCF	+3		# Q,R MANUAL CONTROL	WC = A*(B+|D|)*D
		TCF	+2		# ******************
		TCF	+1
		DOUBLE			# WHERE
		DOUBLE			#
		AD	LINRAT		# 	WC  = COMMANDED ROTATIONAL RATE
		EXTEND			#	A   = QUADRATIC SENSITIVITY FACTOR
		MP	SAVEHAND	#	B   = LINEAR/QUADRATIC SENSITIVITY
		CA	L		#	|D| = ABS. VALUE OF DEFLECTION
		EXTEND			#	D   = HAND CONTROLLER DEFLECTION
		MP	STIKSENS
		XCH	QLAST		# COMMAND Q RATE, SCALED 45 DEG/SEC
		COM
# Page 1447
		AD	QLAST
		TS	DAPTEMP3
		CCS	SAVEHAND +1
		TCF	+3
		TCF	+2
		TCF	+1
		DOUBLE
		DOUBLE
		AD	LINRAT
		EXTEND
		MP	SAVEHAND +1
		CA	L
		EXTEND
		MP	STIKSENS
		XCH	RLAST
		COM
		AD	RLAST
		TS	DAPTEMP4
		CS	QLAST		# INTERVAL.
		AD	OMEGAQ
		TS	QRATEDIF
		CS	RLAST
		AD	OMEGAR
		TS	RRATEDIF
ENTERQR		DXCH	QRATEDIF	# TRANSFORM RATES FROM Q,R TO U,V AXES
		TC	ROT-TOUV
		DXCH	URATEDIF
		CCS	DAPTEMP3	# CHECK IF Q COMMAND CHANGE EXCEEDS
		TC	+3		# BREAKOUT LEVEL.  IF NOT, CHECK R.
		TC	+2
		TC	+1
		AD	-RATEDB
		EXTEND
		BZMF	+2
		TCF	ENTERUV -2	# BREAKOUT LEVEL EXCEEDED.  DIRECT RATE.
		CCS	DAPTEMP4	# R COMMAND BREAKOUT CHECK.
		TC	+3
		TC	+2
		TC	+1
		AD	-RATEDB
		EXTEND
		BZMF	+2
		TCF	ENTERUV -2	# BREAKOUT LEVEL EXCEEDED.  DIRECT RATE.
		CA	RCSFLAGS	# BREAKOUT LEVEL NOT EXCEEDED.  CHECK FOR
		MASK	QRBIT		# DIRECT RATE CONTROL LAST TIME.
		EXTEND
		BZF	+2
		TCF	ENTERUV		# CONTINUE DIRECT RATE CONTROL.
		TCF	STILLRCS	# PSEUDO-AUTO CONTROL.
		CA	40CYCL
# Page 1448
		TS	TCQR
ENTERUV		INHINT			# DIRECT RATE CONTROL
		TC	IBNKCALL
		FCADR	ZATTEROR
		RELINT
		CA	ZERO
		TS	DYERROR
		TS	DYERROR +1
		TS	DZERROR
		TS	DZERROR +1
		CCS	URATEDIF
		TCF	+3
		TCF	+2
		TCF	+1
		AD	TARGETDB	# IF TARGET DB IS EXCEEDED, CONTINUE
		EXTEND			# DIRECT RATE CONTROL.
		BZMF	VDB
		CCS	VRATEDIF
		TCF	+3
		TCF	+2
		TCF	+1
		AD	TARGETDB
		EXTEND
		BZMF	+2
		TCF	QRTIME
		CA	ZERO
		TS	VRATEDIF
		TCF	QRTIME
VDB		CCS	VRATEDIF
		TC	+3
		TC	+2
		TC	+1
		AD	TARGETDB	# IF TARGET DB IS EXCEEDED, CONTINUE
		EXTEND			# DIRECT RATE CONTROL.  IF NOT, FIRE AND
		BZMF	TOPSEUDO	# SWITCH TO PSEUDO-AUTO CONTROL ON NEXT
		CA	ZERO		# PASS.
		TS	URATEDIF
QRTIME		CA	TCQR		# DIRECT RATE TIME CHECK.
		EXTEND
		BZMF	+5		# BRANCH IF TIME EXCEEDS 4 SEC.
		CS	RCSFLAGS
		MASK	QRBIT
		ADS	RCSFLAGS	# BIT 11 IS 1.
		TC	+4
TOPSEUDO	CS	QRBIT
		MASK	RCSFLAGS
		TS	RCSFLAGS	# BIT 11 IS 0.
		CA	HANDADR
		TS	RETJADR
		CA	ONE

# Page 1449
BACKHAND	TS	AXISCTR

		CA	FOUR
		TS	NUMBERT

		INDEX	AXISCTR
		INDEX	SKIPU
		TCF	+1
		CA	FOUR
		INDEX	AXISCTR
		TS	SKIPU
		TCF	LOOPER

		INDEX	AXISCTR
		CCS	URATEDIF	#	INDEX	AXIS	QUANTITY
		CA	ZERO		#	0	-U	1/JETACC-AOSU
		TCF	+2		#	1	+U	1/JETACC+AOSU
		CA	ONE		#	16	-V	1/JETACC-AOSV
		INDEX	AXISCTR		#	17	+V	1/JETACC+AOSV
		AD	AXISDIFF	# JETACC = 2 JET ACCELERATION (1 FOR FAIL)

		INDEX	A
		CS	1/ANET2 +1
		EXTEND
		INDEX	AXISCTR		# UPRATEDIF IS SCALED AT PI/4 RAD/SEC
		MP	URATEDIF	# JET TIME IN A, SCALED 32 SEC
		TS	Q
		DAS	A
		AD	Q
		TS	A		# OVERFLOW SKIP
		TCF	+2
		CA	Q		# RIGHT SIGN AND BIGGER THAN 150MS
SETTIME		INDEX	AXISCTR
		TS	TJU		# SCALED AT 10.67 WHICH IS CLOSE TO 10.24
		TCF	AFTERTJ

ZEROTJ		CA	ZERO
		TCF	SETTIME

HANDADR		GENADR	BACKHAND

# GTS WILL BE TRIED IF
#	1. USEQRJTS = 0,
#	2. ALLOWGTS POS,
#	3. JETS ARE OFF (Q,R-AXES)

TRYGTS		CAF	USEQRJTS	# IS JET USE MANDATORY.		(AS LONG AS
		MASK	DAPBOOLS	# USEQRJTS BIT IS NOT BIT 15, CCS IS SAFE.)
		CCS	A
		TCF	RCS
		CCS	ALLOWGTS	# NO.  DOES AOSTASK OK CONTROL FOR GTS?
# Page 1450
		TCF	+2
		TCF	RCS
		EXTEND
		READ	CHAN5
		CCS	A
		TCF	CHKINGTS
GOTOGTS		EXTEND
		DCA	GTSCADR
		DTCB

CHKINGTS	CCS	INGTS		# WAS THE TRIM GIMBAL CONTROLLING
		TCF	+2		#	YES.  SET UP A DAMPED NULLING DRIVE.
		TCF	RCS		#	NO.  NULLING WAS SET UP BEFORE.  DO RCS.
		INHINT
		TC	IBNKCALL
		CADR	TIMEGMBL
		RELINT
		CAF	ZERO
		TS	INGTS
		TCF	RCS

		EBANK=	CDUXD
GTSCADR		2CADR	GTS

# Page 1451
# SUBROUTINE TO COMPUTE Q,R-AXES ATTITUDE ERRORS FOR USE IN THE RCS AND GTS CONTROL LAWS AND THE DISPLAYS.

QERRCALC	CAE	CDUY		# Q-ERROR CALCULATION
		EXTEND
		MSU	CDUYD		# CDU ANGLE -- ANGLE DESIRED (Y-AXIS)
		TS	DAPTEMP1	# SAVE FOR RERRCALC
		EXTEND
		MP	M21		# (CDUY-CDUYD)*M21 SCALED AT PI RADIANS
		TS	E
		CAE	CDUZ		# SECOND TERM CALCULATION:
		EXTEND
		MSU	CDUZD		# CDU ANGLE -ANGLE DESIRED (Z-AXIS)
		TS	DAPTEMP2	# SAVE FOR RERRCALC
		EXTEND
		MP	M22		# (CDUZ-CDUZD)*M22 SCALED AT PI RADIANS
		AD	DELQEROR	# KALCMANU INERFACE ERROR
		AD	E
		XCH	QERROR		# SAVE Q-ERROR FOR EIGHT-BALL DISPLAY.

RERRCALC	CAE	DAPTEMP1	# R-ERROR CALCULATION:
		EXTEND			# CDU ANGLE -ANGLE DESIRED (Y-AXIS)
		MP	M31		# (CDUY-CDUYD)*M31 SCALED AT PI RADIANS
		TS	E
		CAE	DAPTEMP2	# SECOND TERM CALCULATION:
		EXTEND			# CDU ANGLE -ANGLE DESIRED (Z-AXIS)
		MP	M32		# (CDUZ-CDUZD)*M32 SCALED AT PI RADIANS
		AD	DELREROR	# KALCMANU INERFACE ERROR
		AD	E
		XCH	RERROR		# SAVE R-ERROR FOR EIGHT-BALL DISPLAY.
		TC	Q

# Page 1452
# "ATTSTEER" IS THE ENTRY POINT FOR Q,R-AXES (U,V-AXES) ATTITUDE CONTROL USING THE REACTION CONTROL SYSTEM

ATTSTEER	EQUALS	STILLRCS	# "STILLRCS" IS THE RCS EXIT FROM TRYGTS.

STILLRCS	CA	RERROR
		LXCH	A
		CA	QERROR
		TC	ROT-TOUV
		DXCH	UERROR

# PREPARES CALL TO TJETLAW (OR SPSRCS(DOCKED))
# PREFORMS SKIP LOGIC ON U OR Y AXIS IF NEEDED.

TJLAW		CA	TJLAWADR
		TS	RETJADR
		CA	ONE
		TS	AXISCTR
		INDEX	AXISCTR
		INDEX	SKIPU
		TCF	+1
		CA	FOUR
		INDEX	AXISCTR
		TS	SKIPU
		TCF	LOOPER
		INDEX	AXISCTR
		CA	UERROR
		TS	E
		INDEX	AXISCTR
		CA	OMEGAU
		TS	EDOT
		CA	DAPBOOLS
		MASK	CSMDOCKD
		CCS	A
		TCF	+3
		TC	TJETLAW
		TCF	AFTERTJ
 +3		CS	DAPBOOLS	# DOCKED.  IF GIMBAL USABLE DO GTS CONTROL
		MASK	USEQRJTS	#	ON THE NEXT PASS.
		CCS	A		# USEQRJTS BIT MUST NOT BE BIT 15.
		TS	COTROLER	# GIMBAL USABLE.  STORE POSITIVE VALUE.
		INHINT
		TC	IBNKCALL
		CADR	SPSRCS		# DETERMINE RCS CONTROL
		RELINT
		CAF	FOUR		# ALWAYS CALL FOR 2-JET CONTROL ABOUT U,V.
		TS	NUMBERT		# FALL THROUGH TO JET SLECTION, ETC.

# Q,R-JET-SELECTION-LOGIC
#
# INPUT:	AXISCTR		0,1 FOR U,V
#		SNUFFBIT	ZERO TJETU,V AND TRANS. ONLY IF SET IN A DPS BURN
# Page 1453
#		TJU,TJV		JET TIME SCALED 10.24 SEC.
#		NUMBERT		INDICATES NUMBER OF JETS AND TYPE OF POLICY
#		RETJADR		WHERE TO RETURN TO
#
# OUTPUT:	NO.U(V)JETS	RATE DERIVATION FEEDBACK
#		CHANNEL 5
#		SKIPU,SKIPV	FOR LESS THAN 150MS FIRING
#
# NOTES:	IN CASE OF FAILURE IN DESIRED ROTATION POLICY, "ALL" UNFAILED
#		JETS OF THE DESIRED POLICY ARE SELECTED.  SINCE THERE ARE ONLY
#		TWO JETS, THIS MEANS THE OTHER ONE OR NONE.  THE ALARM IS SENT
#		IF NONE CAN BE FOUND.
#
#		TIMES LESS THAN 14 MSEC ARE TAKEN TO CALL FOR A SINGLE-JET
#		MINIMUM IMPULSE, WITH THE JET CHOSEN SEMI-RANDOMLY.

AFTERTJ		CA	FLAGWRD5	# IF SNUFFBIT SET DURING A DPS BURN GO TO
		MASK	SNUFFBIT	# XTRANS; THAT IS, INHIBIT CONTROL.
		EXTEND
		BZF	DOROTAT
		CS	FLGWRD10
		MASK	APSFLBIT
		EXTEND
		BZF	DOROTAT
		CA	DAPBOOLS
		MASK	DRIFTBIT
		EXTEND
		BZF	XTRANS

DOROTAT		CAF	TWO
		TS	L
		INDEX	AXISCTR
		CCS	TJU
		TCF	+5
		TCF	NOROTAT
		TCF	+2
		TCF	NOROTAT
		ZL
		AD	ONE
		TS	ABSTJ

		CA	AXISCTR
		AD	L
		TS	ROTINDEX	# 0 1 2 3 = -U -V +U +V

		CA	ABSTJ
		AD	-150MS
		EXTEND
		BZMF	DOSKIP
# Page 1454
		TC	SELCTSUB

		INDEX	AXISCTR
		CA	INDEXES
		TS	L

		CA	POLYTEMP
		INHINT
		INDEX	L
		TC	WRITEP

		RELINT
		TCF	FEEDBACK

NOROTAT		INDEX	AXISCTR
		CA	INDEXES
		INHINT
		INDEX	A
		TC	WRITEP 	-1

		RELINT
LOOPER		CCS	AXISCTR
		TC	RETJADR
		TCF	CLOSEOUT
DOSKIP		CS	ABSTJ
		AD	+TJMINT6	# 14MS
		EXTEND
		BZMF	NOTMIN

		ADS	ABSTJ
		INDEX	AXISCTR
		CCS	TJU
		CA	+TJMINT6
		TCF	+2
		CS	+TJMINT6
		INDEX	AXISCTR
		TS	TJU

		CCS	SENSETYP	# ENSURE MIN-IMPULSE NOT AGAINST TRANS
		TCF	NOTMIN 	-1
		EXTEND
		READ	LOSCALAR
		MASK	ONE
		TS	NUMBERT

NOTMIN		TC	SELCTSUB

		INDEX	AXISCTR
		CA	INDEXES
		INHINT
# Page 1455
		TS	T6FURTHA +1
		CA	POLYTEMP
		INDEX	T6FURTHA +1
		TC	WRITEP

		CA	ABSTJ
		TS	T6FURTHA
		TC	JTLST		# IN QR BANK BY NOW

		RELINT

		CA	ZERO
		INDEX	AXISCTR
		TS	SKIPU

FEEDBACK	CS	THREE
		AD	NUMBERT
		EXTEND
		BZMF	+3

		CA	TWO
		TCF	+2
		CA	ONE
		INDEX	AXISCTR
		TS	NO.UJETS
		TCF	LOOPER

XTRANS		CA	ZERO
		TS	TJU
		TS	TJV
		CA	FOUR
		INHINT
		XCH	SKIPU
		EXTEND
		BZF	+2
		TC	WRITEU 	-1
		CA	FOUR
		XCH	SKIPV
		RELINT

		EXTEND
		BZF	CLOSEOUT
		INHINT
		TC	WRITEV 	-1
		RELINT

		TCF	CLOSEOUT
INDEXES		DEC	4
		DEC	13
+TJMINT6	DEC	22
# Page 1456
-150MS		DEC	-240
BIT8,9		OCT	00600
SCLNORM		OCT	266
TJLAWADR	GENADR	TJLAW 	+3	# RETURN ADDRESS FOR RCS ATTITUDE CONTROL

# THE JET LIST:
# THIS IS A WAITLIST FOR T6RUPTS.
#
# CALLED BY:
#		CA	TJ		# TIME WHEN NEXT JETS WILL BE WRITTEN
#		TS	T6FURTHA
#		CA	INDEX		# AXIS TO BE WRITTEN AT TJ (FROM NOW)
#		TS	T6FURTHA +1
#		TC	JTLST
#
# EXAMPLE -- U-AXIS AUTOPILOT WILL WRITE ITS ROTATION CODE OF
# JETS INTO CHANNEL 5.  IF IT DESIRES TO TURN OFF THIS POLICY WITHIN
# 150MS AND THEN FIRE NEXTU, A CALL TO JTLST IS MADE WITH T6FURTHA
# CONTAINING THE TIME TO TURN OFF THE POLICY, T6FURTHA +1 THE INDEX
# OF THE U-AXIS(4), AND NEXTU WILL CONTAIN THE "U-TRANS" POLICY OR ZERO.
#
# THE LIST IS EXACTLY 3 LONG.  (THIS LEADS UP TO SKIP LOGIC AND 150MS LIMIT)
# THE INPUT IS THE LAST MEMBER OF THE LIST.
#
# RETURNS BY:
#	+	TC	Q
#
# DEFINITIONS:  (OUTPUT)
#	TIME6		TIME OF NEXT RUPT
#	T6NEXT		DELTA TIME TO NEXT RUPT
#	T6FURTHA	DELTA TIME FROM 2ND TO LAST RUPT
#	NXT6ADR		AXIS INDEX	0 -- P-AXIS
#	T6NEXT +1	AXIS INDEX	4 -- U-AXIS
#	T6FURTHA +1	AXIS INDEX	13 -- V-AXIS

JTLST		CS	T6FURTHA
		AD	TIME6
		EXTEND
		BZMF	MIDORLST	# TIME6 -- TI IS IN A

		LXCH	NXT6ADR
		DXCH	T6NEXT
		DXCH	T6FURTHA
		TS	TIME6
		LXCH	NXT6ADR

TURNON		CA	BIT15
		EXTEND
		WOR	CHAN13
		TC	Q
		
# Page 1457
MIDORLST	AD	T6NEXT
		EXTEND
		BZMF	LASTCHG		# TIME6 + T6NEXT - T IS IN A

		LXCH	T6NEXT 	+1
		DXCH	T6FURTHA
		EXTEND
		SU	TIME6
		DXCH	T6NEXT

		TC	Q

LASTCHG		CS	A
		AD	NEG0
		TS	T6FURTHA

		TC	Q

# ROT-TOUV IS ENTERED WITH THE Q-COMPONENT OF THE QUANTITY TO BE TRANSFORMED IN A AND THE R-COMPONENT IN L.
# ROT-TOUV TRANSFORMS THE QUANTITY INTO THE NON-ORTHOGONAL U-V AXIS SYSTEM.  IN THE U-V SYSTEM NO CROSS-COUPLING IS
# PRODUCED FROM RCS JET FIRINGS.  AT THE COMPLETION OF ROT-TOUV, THE U-COMPONENT OF THE TRANSFORMED QUANTITY IS IN
# A AND THE V-COMPONENT IS IN L.

ROT-TOUV	LXCH	ROTEMP2		# (R) IS PUT INTO ROTEMP2
		EXTEND
		MP	COEFFQ
		XCH	ROTEMP2		# (R) GOES TO A AND COEFFQ.(Q) TO ROTEMP2
		EXTEND
		MP	COEFFR
		TS	L		# COEFFR.(R) IS PUT INTO L
		AD	ROTEMP2
		TS	ROTEMP1		# COEFFQ.(Q)+COEFFR.(R) IS PUT IN ROTEMP1
		TCF	+4
		INDEX	A		# COEFFQ.(Q) + COEFFR.(R) HAS OVERFLOWED
		CS	LIMITS		# AND IS LIMITED TO POSMAX OR NEGMAX
		TS	ROTEMP1
		CS	ROTEMP2
		AD	L		# -COEFFQ.(Q) + COEFFR.(R) IS NOW IN A
		TS	7
		TCF	+3
		INDEX	A		# -COEFFQ.(Q) + COEFFR.(R) HAS OVERFLOWED
		CS	LIMITS		# AND IS LIMITED TO POSMAX OR NEGMAX
		LXCH	ROTEMP1		# COEFFQ.(Q) + COEFFR.(R) IS PUT INTO L
		TC	Q
SELCTSUB	INDEX	ROTINDEX
		CA	ALLJETS
		INDEX	NUMBERT
		MASK	TYPEPOLY
		TS	POLYTEMP
# Page 1458
		MASK	CH5MASK
		CCS	A
		TCF	+2

		TC	Q

		CA	THREE
FAILOOP		TS	NUMBERT
		INDEX	ROTINDEX
		CA	ALLJETS
		INDEX	NUMBERT
		MASK	TYPEPOLY
		TS	POLYTEMP
		MASK	CH5MASK
		EXTEND
		BZF	FAILOOP -2
		CCS	NUMBERT
		TCF	FAILOOP
		INDEX	AXISCTR
		TS	TJU
		TC	ALARM
		OCT	02004
		TCF	NOROTAT
ALLJETS		OCT	00110		#	-U	6 13
		OCT	00022		#	-V	2 9
		OCT	00204		#	+U	5 14
		OCT	00041		# 	+V	1 10
TYPEPOLY	OCT	00125		#	-X	1 5 9 13
		OCT	00252		#	+X	2 6 10 14
		OCT	00146		#	A	2 5 10 13
		OCT	00231		#	B	1 6 9 14
		OCT	00377		#	ALL	1 2 5 6 9 10 13 14

# THE FOLLOWING SETS THE INTERRUPT FLIP-FLOP AS SOON AS POSSIBLE, WHICH PERMITS A RETURN TO THE INTERRUPTED JOB.

CLOSEOUT	CA	ADRRUPT
		TC	MAKERUPT

ADRRUPT		ADRES	ENDJASK

ENDJASK		DXCH	DAPARUPT
		DXCH	ARUPT
		DXCH	DAPBQRPT
		XCH	BRUPT
		LXCH	Q
		CAF	NEGMAX		# NEGATIVE DAPZRUPT SIGNALS JASK IS OVER.
		DXCH	DAPZRUPT
		DXCH	ZRUPT
		TCF	NOQRSM
# Page 1459		
		BLOCK	3
		SETLOC	FFTAG6
		BANK

		COUNT*	$$/DAP

MAKERUPT	EXTEND
		EDRUPT	MAKERUPT
		
