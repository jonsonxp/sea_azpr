GPIO_BASE_ADDR_H	EQU	0x8000		;GPIO Base Address High
GPIO_OUT_OFFSET		EQU	0x4			;GPIO Output Port Register Offset

	XORR	r0,r0,r0
	ORI		r0,r1,GPIO_BASE_ADDR_H
	SHLLI	r1,r1,16
	ORI		r0,r2,2
	
LOOP0:
	ADDUI	r2,r2,1
	STW		r1,r2,GPIO_OUT_OFFSET
	
	;For board run
	ORI		r0,r3,0x0098
	SHLLI	r3,r3,16
	ORI		r3,r3,0x9680
	
	;For simulation
	;ADDUI r0,r3,10
LOOP1:
	ADDSI	r3,r3,-1
	BNE	r0,r3,LOOP1
	ANDR	r0,r0,r0
	BE		r0,r0,LOOP0
	ANDR	r0,r0,r0
