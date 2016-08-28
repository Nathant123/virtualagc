### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	TVCROLLDAP.agc
# Purpose:	Part of the source code for Colossus 2A, AKA Comanche 055.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	984-998
# Mod history:	2009-05-13 RSB	Adapted from the Colossus249/ file of the
#				same name, using Comanche055 page images.
#		2011-05-08 JL	Removed workarounds.

# This source code has been transcribed or otherwise adapted from digitized
# images of a hardcopy from the MIT Museum.  The digitization was performed
# by Paul Fjeld, and arranged for by Deborah Douglas of the Museum.  Many
# thanks to both.  The images (with suitable reduction in storage size and
# consequent reduction in image quality as well) are available online at
# www.ibiblio.org/apollo.  If for some reason you find that the images are
# illegible, contact me at info@sandroid.org about getting access to the 
# (much) higher-quality images which Paul actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 055 of AGC program Comanche by NASA
#	2021113-051.  10:28 APR. 1, 1969  
#
#	This AGC program shall also be referred to as
#			Colossus 2A

# Page 984
# PROGRAM NAME....TVC ROLL AUTOPILOT
# LOG SECTION....TVCROLLDAP			SUBROUTINE....DAPCSM
# MOD BY SCHLUNDT				21 OCTOBER 1968
#
# FUNCTIONAL DESCRIPTION....
#
#      *AN ADAPTATION OF THE LEM P-AXIS CONTROLLER
#      *MAINTAIN OGA WITHIN 5 DEG DEADBND OF OGAD, WHERE OGAD = OGA AS SEEN
#	BY IGNOVER (P40)
#      *MAINTAIN OGA RATE LESS THAN 0.1 DEG/SEC LIMIT CYCLE RATE
#      *SWITCHING LOGIC IN PHASE PLANE.... SEE GSOP CHAPTER 3
#      *USES T6 CLOCK TO TIME JET FIRINGS.
#      *MAXIMUM JET FIRING TIME = 2.56 SECONDS, LIMITED TO 2.5 IF GREATER
#      *MINIMUM JET FIRING TIME = 15 MS
#      *JET PAIRS FIRE ALTERNATELY
#      *AT LEAST 1/2 SECOND DELAY BEFORE A NEW JET PAIR IS FIRED
#      *JET FIRINGS MAY NOT BE EXTENDED, ONLY SHORTENED, WHEN RE-EVALUATION
#	OF A JET FIRING TIME IS MADE ON A LATER PASS
#
# CALLING SEQUENCE....
#
#      *ROLLDAP CALL VIA WAITLIST, IN PARTICULAR BY TVCEXEC (EVERY 1/2 SEC)
#	WITH A 3CS DELAY TO ALLOW FREE TIME FOR OTHER RUPTS (DWNRPT, ETC.)
#
# NORMAL EXIT MODES.... ENDOFJOB
#
# ALARM OR ABORT EXIT MODES.... NONE
#
# SUBROUTINES CALLED.....NONE
#
# OTHER INTERFACES....
#
#      *TVCEXEC SETS UP ROLLDAP TASK EVERY 1/2 SECOND AND UPDATES 1/CONACC
#	EVERY 10 SECONDS (VIA MASSPROP AND S40.15)
#      *RESTARTS SUSPEND ROLL DAP COMPUTATIONS UNTIL THE NEXT 1/2 SEC
#	SAMPLE PERIOD.  (THE PART OF TVCEXECUTIVE THAT CALLS ROLL DAP IS
#	NOT RESTARTED.)  THE OGAD FROM IGNITION IS MAINTAINED.
#
# ERASABLE INITIALIZATION REQUIRED
#
#      *1/CONACC				(S40.15)
#      *OGAD					(CDUX, AT IGNITION)
#      *OGANOW					(CDUX AT TVCINIT4 AND TVCEXECUTIVE)
#      *OGAPAST					(OGANOW AT TVCEXECUTIVE)
#      *ROLLFIRE = TEMREG = ROLLWORD = 0	(MRCLEAN LOOP IN TVCDAPON)
#
# OUTPUT....
#
#      *ROLL JET PAIR FIRINGS
#
# Page 985
# DEBRIS.... MISCELLANEOUS, SHAREABLE WITH RCS/ENTRY, IN EBANK6 ONLY

# Page 986
# SOME NOTES ON THE ROLL AUTOPILOT, AND IN PARTICULAR, ON ITS SWITCHING
# LOGIC.  SEE SECTION THREE OF THE GSOP (SUNDISK/COLOSSUS) FOR DETAILS.

# SWITCHING LOGIC IN THE PHASE PLANE....
#
#                              OGARATE
#                                 *
#                                 *
#  * * * * * * * * * * *          *
#                                 *     (REGION 1, SEE TEXT BELOW)
#                            *    *
#                                 *
# * * * * * * *     (COAST)       *     ...PARABOLA (SWITCHING = CONTROL)
#               *                 *    .
#                 *               *   *
#                   *             *                (FIRE NEG ROLL JETS)
#                     *           *      *
#     (-DB,+LMCRATE)....*         *
#                       *         *        *
#                       *         *			         OGAERROR
# ************************************************************************
#                                 *         *                (-AK, OGAERR)
#                        *        *         *      (REGION 6-PRIME)
#                                 *         *      (SEE TEXT BELOW)
#                          *      *           *
#                                 *             *     ...STRAIGHT LINE
#    (FIRE POS ROLL JETS)     *   *               *  .
#                                 *   (COAST)       *
#                                 *                   * * * * * * * * * *
#                                 *                         -MINLIM
#                                 *    *
#                                 *
#                                 *          * * * * * * * * * * * * * * *
#                                 *                        -MAXLIM
#                                 *
#                                 *
#
# SWITCHING PARABOLAS ARE CONTROL PARABOLAS, THUS REQUIRING KNOWLEDGE OF
#	CONTROL ACCELERATION CONACC, OR ITS RECIPROCAL, 1/CONACC, THE TVC
#	ROLL DAP GAIN  (SEE TVCEXECUTIVE VARIABLE GAIN PACKAGE).  JET
#	FIRING TIME IS SIMPLY THAT REQUIRED TO ACHIEVE THE DESIRED OGARATE,
#	SUBJECT TO TEH LIMITATIONS DISCUSSED UNDER FUNCTIONAL DESCRIPTION,
#	ABOVE.
#
# THE THREE CONTROL REGIONS  (+, -, AND ZERO TORQUE) ARE COMPRISED OF
#	TWELVE SUBSET REGIONS  ( 1...6, AND THE CORRESPONDING 1-PRIME...
#	5-PRIME )  SEE SECTION 3 OF THE GSOP  (SUNDISK OR COLOSSUS)
# Page 987
#
# GIVEN THE OPERATING POINT NOT IN THE COAST REGION, THE DESIRED OGARATE
#	IS AT THE POINT OF PENETRATION OF THE COAST REGION BY THE CONTROL
#	PARABOLA WHICH PASSES THROUGH THE OPERATING POINT.  FOR REGION 3
#	DESIRED OGARATE IS SIMPLY +-MAXLIM.  FOR REGIONS 1 OR 6 THE SOLUTION
#	TO A QUADRATIC IS REQUIRED (THE PENETRATION IS ALONG THE STRAIGHT
#	LINE OR MINLIM BOUNDRY SWITCH LINES).  AN APPROXIMATION IS MADE
#	INSTEAD.  CONSIDER AN OPERATING POINT IN REGION 6'.  PASS A TANGENT TO
#	THE CONTROL PARABOLA THROUGH THE OPERATING POINT, AND FIND ITS
#	INTERSECTION WITH THE STRAIGHT LINE SECTION OF THE SWITCH CURVE...
#	THE INTERSECTION DEFINES THE DESIRED OGARATE.  IF THE OPERATING POINT IS
#	CLOSE TO THE SWITCH LINE, THE APPROXIMATION IS QUITE GOOD (INDEED
#	THE APPROXIMATE AND QUADRATIC SOLUTIONS CONVERGE IN THE LIMIT AS
#	THE SWITCH LINE IS APPROACHED).  IF THE OPERATING POINT IS NOT CLOSE
#	TO THE SWITCH LINE, THE APPROXIMATE SOLUTION GIVES VALID TREND
#	INFORMATION (DIRECTION OF DESIRED OGARATE) AT LEAST.  THE 
#	RE-EVALUATION OF DESIRED OGARATE IN SUBSEQUENT ROLL DAP PASSES (1/2
#	SECOND INTERVALS) WILL BENEFIT FROM THE CONVERGENT NATURE OF THE
#	APPROXIMATION.
#
# FOR LARGE OGAERROR THE TANGENT INTERSECTS +-MINLIM SWITCH BOUNDRY BEFORE
#	INTERSECTING THE STRAIGHT LINE SWITCH.  HOWEVER THE MINLIM IS
#	IGNORED IN COMPUTING THE FIRING TIME, SO THAT THE EXTENSION (INTO
#	THE COAST REGION) OF THE STRAIGHT LINE SWITCH IS WHAT IS FIRED TO.
#	IF THE ROLL DAP FINDS ITSELF IN THE COAST REGION BEFORE REACHING
#	THE DESIRED INTERSECTION (I.E., IN THE REGION BETWEEN THE MINLIM
#	AND THE STRAIGHT LINE SWITCH) IT WILL EXHIBIT NORMAL COAST-REGION
#	BEHAVIOR AND TURN OFF THE JETS.  THE PURPOSE OF THIS FIRING POLICY
#	IS TO MAINTAIN STATIC ROLL STABILITY IN THE EVENT OF A JET
#	FAILED-ON.
#
# WHEN THE OPERATING POINT IS IN REGION 1 THE SAME APPROXIMATION IS
#	MADE, BUT AT AN ARTIFICIALLY-CREATED OR DUMMY OPERATING POINT,
#	DEFINED BY:  OGAERROR = INTERSECTION OF CONTROL PARABOLA AND
#	OGAERROR AXIS, OGARATE = +-LMCRATE WHERE SIGN IS OPPOSITE THAT OF
#	REAL OPERATING POINT RATE.  WHEN THE OPERATING POINT HAS PASSED
#	FROM REGION 1 TO REGION 6', THE DUMMY POINT IS NO LONGER REQUIRED,
#	AND THE SOLUTION REVERTS TO THAT OF A REGULAR REGION 6' POINT.
#
# EQUATION FOR SWITCHING PARABOLA (SEE FIGURE ABOVE)....
#				    2
#	SOGAERROR = (DB - (SOGARATE) (1/CONACC)/2) SGN(SOGARATE)
#
# EQUATION FOR SWITCHING STRAIGHT LINE SEGMENT....
#
#	SOGARATE = -(-SLOPE)(SOGAERROR) - SGN(SOGARATE) INTERCEP
#
#		WHERE  INTERCEP = DB(-SLOPE) - LMCRATE
# Page 988
#
# EQUATION FOR INTERSECTION, CONTROL PARABOLA, AND STRAIGHT SWITCH LINE....
#
#	DOGADOT = NUM/DEN, WHERE
#				       2
#		NUM = (-SLOPE)(OGARATE) (1/CONACC)
#		      +SGN(DELOGA)(-SLOPE)(OGAERROR - SGN(DELOGA)(DB))
#		      +LMCRATE
#
#		DEN = (-SLOPE)(LMCRATE)(1/CONACC) = SGN(DELOGA)
#						  2
#		DELOGA = OGAERROR - (DB - (OGADOT) (1/CONACC)/2)SGN(OGARATE)
#
# FOR REGIONS 6 AND 6-PRIME, USE ACTUAL OPERATING POINT  (OGA, OGARATE)
#	FOR OGAERROR AND OGARATE IN THE INTERSECTION EQUATIONS ABOVE.
#	FOR REGIONS 1 AND 1-PRIME USE DUMMY OPERATING POINT FOR OGAERROR
#	AND OGARATE, WHERE THE DUMMY POINT IS GIVEN BY....
#
#		OGAERROR = DELOGA + DB SGN(OGARATE)
#
#		OGARATE = -LMCRATE SGN(OGARATE)
#
# NOTE, OGAERROR = OGA - OGAD  USES DUMMY REGISTER  OGA  IN ROLL DAP CODING
#	ALSO, AT POINT WHERE DOGADOT IS COMPUTED, REGISTER DELOGA IS USED
#	AS A DUMMY REGISTER FOR THE OGAERROR IN THE NUM EQUATION ABOVE.
# Page 989

# ROLLDAP CODING....

		SETLOC	DAPROLL
		BANK
		EBANK=	OGANOW
		COUNT*	$$/ROLL
ROLLDAP		CAE	OGANOW		# OGA RATE ESTIMATOR...SIMPLE FIRST-ORDER
		EXTEND			#	DIFFERENCE (SAMPLE TIME = 1/2 SEC)
		MSU	OGAPAST
		EXTEND
		MP	BIT5
		LXCH	A
		TS	OGARATE		# SC.AT B-4 REV/SEC
		
# COMPUTATIONS WHICH FOLLOW USE OGA FOR OGAERR (SAME REGISTER)
# EXAMINE DURATION OF LAST ROLL FIRING IF JETS ARE NOW ON.

DURATION	CA	ROLLFIRE	# SAME SGN AS PRESENT TORQ,MAGN=POSMAX
		EXTEND
		BZF	+2		# ROLL JETS ARE NOW OFF.
		TCF	ROLLOGIC	# ENTER LOGIC, JETS NOW ON.
		
		CAE	TEMREG		# EXAMINE LAST FIRING INTERVAL
		EXTEND			# IF POSITIVE, DON'T FIRE
		BZF	ROLLOGIC	# ENTER LOGIC, JETS NOW OFF.
		
		CAF	ZERO		# JETS HAVE NOT BEEN OFF FOR 1/2 SEC. WAIT
		TS	TEMREG		# RESET TEMREG
WAIT1/2		TCF	TASKOVER	# EXIT ROLL DAP

# COMPUTE DB-(1/2 CONACC) (OGARATE)SQ  (1/2 IN THE SCALING)

ROLLOGIC	CS	OGARATE		# SCALED AT 2(-4) REV/SEC
		EXTEND
		MP	1/CONACC	# SCALED AT 2(+9) SEC SQ /REV
		EXTEND
		MP	OGARATE
		AD	DB		# SCALED AT 2(+0) REV
		TS	TEMREG		# QUANTITY SCALED AT 2(+0) REV.
		
# GET SIGN OF OGARATE

		CA	OGARATE
		EXTEND
		BZMF	+3		# LET SGN(0) BE NEGATIVE
		CA	BIT1
		TCF	+2
		CS	BIT1
		TS	SGNRT		# + OR -  2(-14)
	
# Page 990			
# CALCULATE DISTANCE FROM SWITCH PARABOLA,DELOGA
		EXTEND
		MP	TEMREG		# SGN(OGARATE) TEMREG NOW IN L	
		CS	L	
		AD	OGA		# SCALED AT 2(+0) REV
DELOGAC		TS	DELOGA		# SC.AT B+0 REV, PLUS TO RIGHT OF C-PARAB	

# EXAMINE SGN(DELOGA) AND CREATE CA OR CS INSTR. DEPENDING UPON SIGN.

		EXTEND
		BZMF	+3
		CAF	PRIO30		# = CA (30000)
		TCF	+2
		CAF	BIT15		# = CS (40000)
		TS	I
		
		INDEX	I		# TSET ON  I SGN(OGARATE)
		0	SGNRT		# CA OR CS
		COM
		EXTEND
REG1TST		BZMF	ROLLON		# IF REGION 1 (DELOGA OGARATE SAME SIGN)

# NO JET FIRE YET.  TEST FOR MAX OGARATE.

		INDEX	I
		0	OGARATE		# CA OR CS...BOTH MUST BE NEG. HERE
		TS	IOGARATE	# I.E., I OGARATE
		AD	MAXLIM		# SCALED AT 2(-4) REV/SEC
		EXTEND
REG3TST		BZMF	RATELIM		# IF REGION 3 (RATES TOO HIGH, FIRE JETS)

# COMPUTATION OF I((-SLOPE)OGA + OGARATE) - INTERCEPT:  NOTE THAT STR. LINE
# SWITCH SLOPE IS (SLOPE) DEG/SEC/DEG, A NEG. QUANTITY

		CA	OGARATE
		EXTEND
		MP	BIT14
		TS	TEMREG
		CA	OGA
		EXTEND
		MP	-SLOPE
		DDOUBL
		DDOUBL
		DDOUBL			# (OGA ERROR MUST BE LESS THAN +-225 DEG)
		AD	TEMREG
		
		INDEX	I
		0	A		# I((-SLOPE)OGA+OGARATE) AT 2(-3)REV/SEC
		COM
# Page 991		
		AD	INTERCEP	# SCALED AT 2(-3) REV.
		COM
		EXTEND
REG2TST		BZMF	NOROLL		# IP REGION 2 (COAST SIDE OF STRT LINE)

# CHECK TO SEE IF OGARATE IS ABOVE MINLIM

		CA	IOGARATE	# ALWAYS NEGATIVE
		AD	MINLIM		# SCALED AT 2(-4) REV/SEC.
		EXTEND
REG4TST		BZMF	NOROLL		# IF REGION 4 (COAST SIDE OF MINLIM)

# ALL AREAS CHECKED EXCEPT LAST AREA...NO FIRE IN THIS SMALL SEGMENT

		INDEX	I
		0	OGA
		COM
		AD	DB
		COM
		EXTEND
REG5TST		BZMF	NOROLL		# IF REGION 5 (COAST SIDE OF DB)

# JETS MUST FIRE NOW.  OGARATE IS NEG. (OR VICE VERSA).  USE DIRECT STR. LINE.
# DELOGA AND DELOGART ARE USED AS DUMMY VARIABLES IN THE SOLUTION OF A
# STRAIGHT LINE APPROXIMATION TO A QUADRATIC SOLUTION OF THE INTERSECTION
# OF THE CONTROL PARABOLA AND THE STRAIGHT-LINE SWITCH LINE.  THE STRAIGHT
# LINE IS THE TANGENT TO THE CONTROL PARABOLA AT THE OPERATING POINT.  (FOR
# OPERATING POINTS IN REGIONS 6 AND 6')

REGION6		CAE	OGA		# USE ACTUAL OPERATING POINT FOR TANGENT
		TS	DELOGA		# ACTUAL STATE
		CA	OGARATE
		TS	DELOGART	# ACTUAL STATE, I.E., DEL OGARATE
		TCF	ONROLL
		
# JETS ALSO FIRE FROM HERE EXCEPT OGARATE IS POS (VICE VERSA), USE INDIRECT
# STRAIGHT LINE ESTABLISHED BY TANGENT TO A CONTROL PARABOLA AT  ((DELOGA
# + DB SGN(DELOGA) ), -LMCRATE SGN(DELOGA) )	(THIS IS THE DUMMY
# OPERATING POINT FOR OPERATING POINTS IN REGIONS 1 AND 1')

ROLLON		INDEX	I
		0	DB
		ADS	DELOGA		# DELOGA WAS DIST. FROM SWITCH PARABOLA
		
		CS	LMCRATE		# LIMIT CYCLE RATE AT 2(-4) REV/SEC
		INDEX	I
		0	A
		TS	DELOGART	# EVALUATE STATE FOR INDIRECT LINE.

# Page 992
# SOLVE STRAIGHT LINES SIMULTANEOUSLY TO OBTAIN DESIRED OGARATE.

ONROLL		EXTEND			# DELOGART IN ACC. ON ARRIVAL
		MP	1/CONACC
		DOUBLE
		EXTEND
		MP	-SLOPE
		TS	TEMREG		# 2(-SLOPE)RATE /CONACC
		EXTEND
		MP	DELOGART
		TS	DELOGART	# 2(-SLOPE)(RATESQ)/CONACC
		CS	BIT11
		INDEX	I
		0	A
RATEDEN		ADS	TEMREG		# DENOMINATOR COMPLETED

		INDEX	I
		0	DELOGA
		COM
		AD	DB
		COM
		EXTEND
		MP	-SLOPE
		ADS	DELOGART
		CA	LMCRATE
		EXTEND
		MP	BIT11
RATENUM		AD	DELOGART	# NUMERATOR COMPLETED

		XCH	L		# PLACE NUMERATOR IN L FOR OVERFL.  CHECK
		CA	ZERO
		EXTEND
		DV	TEMREG		# OVERFLOW, IF ANYTHING, NOW APPEARS IN A
		EXTEND
		BZF	DVOK		# NO OVERFLOW....(0,L)/TEMREG = 0,L
		
MINLIMAP	CCS	A
		CAF	POSMAX		# 	POSITIVE OVERFLOW
		TCF	ROLLSET
		CS	POSMAX		#	NEGATIVE OVERFLOW
		TCF	ROLLSET
		
DVOK		LXCH	A		# PUT NUMERATOR BACK INTO A, 0 INTO L
		EXTEND
		DV	TEMREG		# RESULT OF DIVISION IS DESIRED OGARATE
		TCF	ROLLSET		#	(SCALED AT B-4 REV/SEC)
		
RATELIM		CS	MAXLIM
		INDEX	I
# Page 993
		0	A		# IF I = CA, DESIRED RATE IS  -MAXLIM
		
# COMPUTE JET FIRE TIME, BASED ON DESIRED RATE MINUS PRESENT RATE

ROLLSET		TS	TEMREG		# STORE DESIRED OGARATE (SCALED B-4)
		EXTEND
		SU	OGARATE		# RATE DIFF. SCALED AT 2(-4) REV/SEC
		TS	TEMREG		#	OVERFLOW PROTECT
		TCF	+3		#	    "       "
		INDEX	A		#           "       "
		CS	LIMITS		#	    "       "
		EXTEND
		MP	T6SCALE		# T6SCALE = 8/10.24
		EXTEND
		MP	1/CONACC	# SCALED AT B+9 SECSQ/REV (MAX < .60)
		DDOUBL
		DDOUBL
		TS	TEMREG		#	OVERFLOW PROTECT
		TCF	+3		#	    "	    "
		INDEX	A		#   	    "	    "
		CS	LIMITS		# 	    " 	    "
		TS	TEMREG		# JET FIRE TIME AT 625 MICROSEC/BIT
		EXTEND			# POS MEANS POSITIVE ROLL TORQUE.
		BZF	NOROLL
		
# JET FIRE TIME IS NZ, TEST FOR JETS NOW ON.

		CAE	TEMREG		# DESIRED CHANGE IN OGARATE
		EXTEND			
		MP	ROLLFIRE	# (SGN OF TORQUE: ZERO IF JETS NOW OFF)
		CCS	A
		TCF	MOREROLL	# CONTINUE FIRING WITH PRESENT POLARITY
		TCF	NEWROLL		# START NEW FIRING NOW, PLUS
		TCF	NOROLL		# TERMINATE OLD FIRING, NEW SIGN REQUESTED
		TCF	NEWROLL		# START NEW FIRING NOW, MINUS
		
# CONTINUE PRESENT FIRING

MOREROLL	CAF	ZERO
		TS	I		# USE TEMP. AS MOREROLL SWITCH
		TCF	MAXTFIRE
		
# START NEW FIRING BUT CHECK IF GREATER THAN MIN FIRE TIME.

NEWROLL		CCS	TEMREG		# CALL THIS T6FIRE
		AD	ONE
		TCF	+2
		AD	ONE
		COM			# -MAG(T6FIRE)
		AD	TMINFIRE	# TMINFIRE-MAG(T6FIRE)
# Page 994		
		COM
		EXTEND
MINTST		BZMF	NOROLL		# IF NOT GREATER THAN TMINFIRE (NEW FIRE)

# PROCEED WITH NEW FIRING BUT NOT LONGER THAN TMAXFIRE

MAXTFIRE	CA	TEMREG
		EXTEND
		MP	1/TMXFIR	# I.E., 1/TMAXFIRE
		EXTEND
MAXTST		BZF	NOMXFIRE	# IF LESS THAN TMAXFIRE

		CCS	A
		CAF	TMAXFIRE	# USE MAXIMUM
		TCF	+2
		CS	TMAXFIRE	# USE MAXIMUM
		TS	TEMREG

# SET UP SIGN OF REQUIRED TORQUE

NOMXFIRE	CCS	TEMREG		# FOR TORQUE SIGN
		CA	POSMAX		# POSITIVE TORQUE REQUIRED
		TCF	+2
		CA	NEGMAX		# NEGATIVE TORQUE REQUIRED
		TS	ROLLFIRE	# SET ROLLFIRE FOR + OR - TORQUE
		
		COM			# COMPLEMENT... POS. FOR NEG. TORQUE
		EXTEND
		BZMF	+3		# POSITIVE TORQUE REQUIRED
		CS	TEMREG
		TS	TEMREG
		
FIRELOOK	CA	I		# IS IT MOREROLL
		EXTEND
		BZF	FIREPLUG	# YES
		TCF	JETROLL		# MAG(T6FIRE) NOW IN TEMREG
		
FIREPLUG	CAE	TIME6		# CHECK FOR EXTENDED FIRING
		EXTEND
		SU	TEMREG
		EXTEND
EXTENTST	BZMF	TASKOVER	# IF EXTENSION WANTED, DON'T, EXIT ROLL DAP
		TCF	JETROLL
		
NOROLL		CS	ZERO		# COAST....(NEG ZERO FOR TIME6)
		TS	ROLLFIRE	# NOTE, JETS CAN FIRE NEXT PASS
		TS	TEMREG
		
JETROLL		EXTEND
		DCA	NOROL1T6
# Page 995		
		DXCH	T6LOC
		CA	TEMREG		# ENTER JET FIRING TIME
		TS	TIME6
		
		CA	I		# I=0 IF MOREROLL, KEEP SAME JETS ON
		EXTEND
SAMEJETS	BZF	TASKOVER	# IF JETS ON KEEP SAME JETS.  EXIT ROLL DAP

		CCS	ROLLFIRE
		TCF	+TORQUE
		TCF	T6ENABL
		TCF	-TORQUE
		TCF	T6ENABL
		
# PROCEED WITH + TORQUE

+TORQUE		CA	ROLLWORD	# WHAT WAS THE LAST +TORQUE COMBINATION
		MASK	BIT1		# WAS IT NO.9-11
		EXTEND
		BZF	NO.9-11		# NOT 9-11, SO USE IT THIS TIME

NO.13-15	CS	BIT1
		MASK	ROLLWORD
		TS	ROLLWORD	# CHANGE BIT 1 TO ZERO
		CAF	+ROLL2
		EXTEND
		WRITE	CHAN6
		TCF	T6ENABL
	
NO.9-11		CAF	BIT1		# 1ST + JETS TO FIRE (MRCLEAN OS ROLLWORD)
		ADS	ROLLWORD	# CHANGE BIT 1 TO ONE
		CAF	+ROLL1
		EXTEND
		WRITE	CHAN6
		TCF	T6ENABL
		
-TORQUE		CA	ROLLWORD	# WHAT WAS LAST -TORQUE COMBINATION
		MASK	BIT2		# WAS IT NO.12-10
		EXTEND
		BZF	NO.12-10	# NOT 12-10, SO USE IT THIS TIME
		
NO.16-14	CS	BIT2
		MASK	ROLLWORD
		TS	ROLLWORD	# CHANGE BIT 2 TO ZERO
		CAF	-ROLL2
		EXTEND
		WRITE	CHAN6
		TCF	T6ENABL
		
NO.12-10	CAF	BIT2		# 1ST -JETS TO FIRE (MRCLEAN OS ROLLWORD)
# Page 996
		ADS	ROLLWORD	# CHANGE BIT 2 TO ONE
		CAF	-ROLL1
		EXTEND
		WRITE	CHAN6
		
T6ENABL		CAF	BIT15
		EXTEND
		WOR	CHAN13
RDAPEND		TCF	TASKOVER	# EXIT ROLL DAP

# Page 997
# THIS T6 TASK SHUTS OFF ALL ROLL JETS

NOROLL1		LXCH	BANKRUPT	# SHUT OFF ALL (ROLL) JETS, (A T6 TASK
		CAF	ZERO		#	CALLED BY "JETROLL")
		TS	ROLLFIRE	# ZERO INDICATES JETS NOW OFF
		EXTEND
KILLJETS	WRITE	CHAN6
		TCF	NOQRSM

# Page 998
# CONSTANTS FOR ROLL AUTOPILOT....

		EBANK=	BZERO
NOROL1T6	2CADR	NOROLL1

DB		DEC	.01388889	# DEAD BAND (5 DEG), SC.AT B+0 REV

-SLOPE		DEC	0.2		# -SWITCHLINE SLOPE(0.2 PER SEC) SC.AT B+0
					#	PER SEC
LMCRATE		DEC	.00027778 B+4	# LIMIT CYCLE RATE (0.1 DEG/SEC) SC.AT
					#	B-4 REV/SEC
INTERCEP	DEC	.0025 B+3	# DB(-SLOPE) - LMCRATE, SC.AT B-3 REV/SC

MINLIM		DEC	.00277778 B+4	# RATELIM,MIN (1DEG/SEC), SC.AT B-4 REV/SC

1/MINLIM	DEC	360 B-18	# RECIPROCAL THEREOF, SHIFTED 14 RIGHT

MAXLIM		DEC	.01388889 B+4	# RATELIM,MAX (5DEG/SEC), SC.AT B-4 REV/SC

TMINFIRE	DEC	1.5 B+4		# 15 MS. (14MIN), SC.AT 16 BITS/CS

TMAXFIRE	DEC	250 B+4		# 2.5 SEC, SC.AT 16 BITS/CS

1/TMXFIR	=	BIT3		# RECIPROCAL THEREOF, SHIFTED 14 RIGHT,
					#	ROUNDS TO OCT00004, SO ALLOWS 2.56
					#	SEC FIRINGS BEFORE APPLYING LIMIT
T6SCALE		=	PRIO31		# (B+3) (16 BITS/CS)  (100CS/SEC)

+ROLL1		= 	FIVE		# ONBITS FOR JETS 9 AND 11
+ROLL2		=	OCT120		# ONBITS FOR JETS 13 AND 15
-ROLL1		=	TEN		# ONBITS FOR JETS 12 AND 10
-ROLL2		OCT	240		# ONBITS FOR JETS 16 AND 14

