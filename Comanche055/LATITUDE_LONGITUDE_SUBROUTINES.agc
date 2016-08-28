### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	LATITUDE_LONGITUDE_SUBROUTINES.agc
# Purpose:	Part of the source code for Colossus 2A, AKA Comanche 055.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	1236-1242
# Mod history:	2009-05-14 RSB	Adapted from the Colossus249/ file of the
#				same name, using Comanche055 page images.
#		2010-08-20 JL	Fixed indentation of RVQ opcode on line 180.
#
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

# Page 1236
# SUBROUTINE TO CONVERT RAD VECTOR AT GIVEN TIME TO LAT,LONG AND ALT
#
# CALLING SEQUENCE
#	L-1	CALL
#	L		LAT-LONG
#
# SUBROUTINES USED
#	R-TO-RP, ARCTAN, SETGAMMA, SETRE
#
# ERASABLE INIT. REQ.
#	AXO, -AYO, AZO, TEPHEM (SET AT LAUNCH TIME)
#	ALPHAV = POSITION VECTOR METERS B-29
#	MPAC -- TIME (CSECS B-28)
#	ERADFLAG =1, TO COMPUTE EARTH RADIUS, =0 FOR FIXED EARTH RADIUS
#	LUNAFLAG=0 FOR EARTH, 1 FOR MOON
#
# OUTPUT
#	LATITUDE IN LAT 	(REVS. B-0)
#	LONGITUDE IN LONG	(REVS. B-0)
#	ALTITUDE IN ALT METERS	B-29

		BANK	30
		SETLOC	LATLONG
		BANK

		COUNT	13/LT-LG

		EBANK=	ALPHAV
LAT-LONG	STQ	SETPD
			INCORPEX
			0D
		STOVL	6D		# SAVE TIME IN 6-7D FOR R-TO-RP
			ALPHAV
		PUSH	ABVAL		# 0-5D= R FOR R-TO-RP
		STODL	ALPHAM		# ABS. VALUE OF R FOR ALT FORMULA BELOW
			ZEROVEC		# SET MPAC=0 FOR EARTH, NON-ZERO FOR MOON
		BOFF	COS		# USE COS(0) TO GET NON-ZERO IN MPAC
			LUNAFLAG	# 0=EARTH, 1=MOON
			CALLRTRP
CALLRTRP	CALL
			R-TO-RP		# RP VECTOR CONVERTED FROM R B-29
		UNIT			# UNIT RP B-1
		STCALL	ALPHAV		# U2= 1/2 SINL FOR SETRE SUBR BELOW
			SETGAMMA	#	SET GAMMA=B2/A2 FOR EARTH, =1 FOR MOON
		CALL			#	SCALED B-1.
			SETRE		# CALC RE METERS B-29
		DLOAD	DSQ
			ALPHAV
		PDDL	DSQ
			ALPHAV +2
# Page 1237
		DAD	SQRT
		DMP	SL1R
			GAMRP
		STODL	COSTH		# COS(LAT) B-1
			ALPHAV +4
		STCALL	SINTH		# SIN(LAT) B-1
			ARCTAN
		STODL	LAT		# LAT B0
			ALPHAV
		STODL	COSTH		# COS(LONG) B-1
			ALPHAV +2
		STCALL	SINTH		# SIN(LONG) B-1
			ARCTAN
		STODL	LONG		# LONG. REVS B-0 IN RANGE -1/2 TO 1/2
			ALPHAM
		DSU			# ALT= R-RE METERS B-29
			ERADM
		STCALL	ALT		# EXIT WITH ALT METERS B-29
			INCORPEX
# Page 1238
# SUBROUTINE TO CONVERT LAT,LONG.ALT AT GIVEN TIME TO RADIUS VECTOR
#
# CALLING SEQUENCE
#	L-1	CALL
#	L		LALOTORV
#
# SUBROUTINES USED
#	SETGAMMA, SETRE, RP-TO-R
#
# ERASABLE INIT. REQ.
#	AXO, AYO, AZO, TEPHEM SET AT LAUNCH TIME
#	LAT -- LATITUDE 	(REVS B0)
#	LONG -- LONGITUDE	(REVS B0)
#	ALT -- ALTITUDE		(METERS) B-29
#	MPAC -- TIME		(CSECS B-28)
#	ERADFLAG =1 TO COMPUTE EARTH RADIUS, =0 FOR FIXED EARTH RADIUS
#	LUNAFLAG=0 FOR EARTH, 1 FOR MOON
#
# OUTPUT
#	R-VECTOR IN ALPHAV 	(METERS B-29)

LALOTORV	STQ	SETPD		# LAT,LONG,ALT TO R VECTOR
			INCORPEX
			0D
		STCALL	6D		#     6-7D = TIME FOR RP-TO-R
			SETGAMMA	#    GAMMA = B2/A2 FOR EARTH, 1 FOR MOON B-1
		DLOAD	SIN		#           COS(LONG)COS(LAT) IN MPAC
			LAT		# UNIT  RP = SIN(LONG)COS(LAT)    2-3D
		DMPR	PDDL		# PD 2      GAMMA*SIN(LAT)       0-1D
			GAMRP
			LAT		#     0-1D = GAMMA*SIN(LAT) B-2
		COS	PDDL		# PD4 2-3D= COS(LAT) B-1 TEMPORARILY
			LONG
		SIN	DMPR		# PD 2
		PDDL	COS		# PD 4 2-3D= SIN(LONG)COS(LAT) B-2
			LAT
		PDDL	COS		# PD 6 4-5D= COS(LAT) B-1 TEMPORARILY
			LONG
		DMPR	VDEF		# PD4 MPAC = COS(LONG)COS(LAT) B-2
		UNIT	PUSH		#     0-5D = UNIT RP FOR RP-TO-R SUBR.
		STCALL	ALPHAV		# ALPHAV +4= SINL FOR SETRE SUBR.
			SETRE		# RE METERS B-29
		DLOAD	BOFF		# SET MPAC = 0 FOR EARTH, NON-ZERO FOR MOON
			ZEROVEC
			LUNAFLAG
			CALLRPRT
		COS			# USE COS(0) TO GET NON-ZERO IN MPAC
CALLRPRT	CALL
			RP-TO-R		# EXIT WITH UNIT R VECTOR IN MPAC
		STODL	ALPHAV
			ERADM
# Page 1239
		DAD	VXSC		# (RE + ALT)(UNIT R) METERS B-30
			ALT
			ALPHAV
		VSL1			# R METERS B-29
		STCALL	ALPHAV		# EXIT WITH R IN METERS B-29
			INCORPEX

# SUBROUTINE TO COMPUTE EARTH RADIUS
#
# INPUT
#	1/2 SIN LAT IN ALPHAV +4
#
# OUTPUT
#	EARTH RADIUS IN ERADM AND MPAC (METERS B-29)

GETERAD		DLOAD	DSQ
			ALPHAV 	+4	# SIN**2(L)
		SL1	BDSU
			DP1/2		# COS**2(L)
		DMPR	BDSU
			EE
			DP1/2
		BDDV	SQRT
			B2XSC
		SR4R
		STORE	ERADM
		RVQ

# THE FOLLOWING CONSTANTS WERE COMPUTED WITH A=6378166, B=6356784 METERS
# B2XSC = B**2 SCALED B-51
# B2/A2 = B**2/A**2 SCALED B-1
# EE = (1-B**2/A**2) SCALED B-0

B2XSC		2DEC	.0179450689	# B**2 SCALED B-51

DP1/2		=	XUNIT
B2/A2		2DEC	.9933064884 B-1	# GAMMA= B**2/A**2 B-1

EE		2DEC	6.6935116 E-3	# (1-B**2/A**2) B-0

ERAD		2DEC	6373338 B-29	# PAD RADIUS

# Page 1240
# ARCTAN SUBROUTINE
#
# CALLING SEQUENCE
#	SIN THETA IN SINTH B-1
#	COS THETA IN COSTH B-1
#	CALL ARCTAN
#
# OUTPUT
#	ARCTAN THETA IN MPAC AND THETA B-0 IN RANGE -1/2 TO +1/2

ARCTAN		BOV
			CLROVFLW
CLROVFLW	DLOAD	DSQ
			SINTH
		PDDL	DSQ
			COSTH
		DAD
		BZE	SQRT
			ARCTANXX	# ATAN=0/0.  SET THETA=0
		BDDV	BOV
			SINTH
			ATAN=90
		SR1	ASIN
		STORE	THETA
		PDDL	BMN
			COSTH
			NEGCOS
		DLOAD	RVQ
NEGCOS		DLOAD	DCOMP
		BPL	DAD
			NEGOUT
			DP1/2
ARCTANXX	STORE	THETA
		RVQ

NEGOUT		DSU	GOTO
			DP1/2
			ARCTANXX
ATAN=90		DLOAD	SIGN
			LODP1/4
			SINTH
		STORE	THETA
		RVQ

2DZERO		=	DPZERO

# Page 1241
# ***** SETGAMMA SUBROUTINE *****
# SUBROUTINE TO SET GAMMA FOR THE LAT-LONG AND LALOTORV SUBROUTINES
#
# GAMMA = B**2/A**2 FOR EARTH (B-1)
# GAMMA = 1 FOR MOON (B-1)
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		SETGAMMA
#
# INPUT
#	LUNAFLAG=0 FOR EARTH, =1 FOR MOON
#
# OUTPUT
#	GAMMA IN GAMRP (B-1)

SETGAMMA	DLOAD	BOFF		# BRANCH FOR EARTH
			B2/A2		# EARTH GAMMA
			LUNAFLAG
			SETGMEX
		SLOAD
			1B1		# MOON GAMMA
SETGMEX		STORE	GAMRP
		RVQ
GAMRP		=	8D

# Page 1242
# ***** SETRE SUBROUTINE *****
# SUBROUTINE TO SET RE (EARTH OR MOON RADIUS)
#
#	RE = RM FOR MOON
#	RE = RREF FOR FIXED EARTH RADIUS OR COMPUTED RF FOR FISCHER ELLIPSOID
#
# CALLING SEQUENCE
#	L	CALL
#	L+1		SETRE
#
# SUBROUTINES USED
#	CETERAD
#
# INPUT
#	ERADFLAG = 0 FOR FIXED RE, 1 FOR COMPUTED RE
#	ALPHAV +4 = 1/2 SINL IF GETERAD IS CALLED
#	LUNAFLAG = 0 FOR EARTH, =1 FOR MOON
#
# OUTPUT
#	ERADM = 504RM FOR MOON (METERS B-29)
#	ERADM = ERAD OR COMPUTED RE FOR EARTH (METERS B-29)

SETRE		STQ	DLOAD
			SETREX
			504RM
		BON	DLOAD		# BRANCH FOR MOON
			LUNAFLAG
			TSTRLSRM
			ERAD
		BOFF	CALL		# ERADFLAG=0 FOR FIXED RE, 1 FOR COMPUTED
			ERADFLAG
			SETRXX
			GETERAD
SETRXX		STCALL	ERADM		# EXIT WITH RE OR RM METERS B-29
			SETREX
TSTRLSRM	BON	VLOAD		# ERADFLAG=0, SET R0=RLS
			ERADFLAG	#         =1      R0=RM
			SETRXX
			RLS
		ABVAL	SR2R		# SCALE FROM B-27 TO B-29
		GOTO
			SETRXX
SETREX		=	S2
504RM		2DEC	1738090 B-29	# METERS B-29 (MOON RADIUS)




