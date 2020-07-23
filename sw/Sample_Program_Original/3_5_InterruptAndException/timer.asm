;;; ロケーションアドレスの設定
	LOCATE	0x20000000

;;; シンボルの定義
TIMER_BASE_ADDR_H			EQU	0x4000	;Timer Base Address High
TIMER_CTRL_OFFSET			EQU	0x0		;Timer Control Register Offset
TIMER_INTR_OFFSET			EQU	0x4		;Timer Interrupt Register Offset
TIMER_EXPIRE_OFFSET			EQU	0x8		;Timer Expiration Register Offset
GPIO_BASE_ADDR_H			EQU	0x8000	;GPIO Base Address High
GPIO_OUT_OFFSET				EQU	0x4		;GPIO Data Register Offset


	XORR	r0,r0,r0					;r0をクリア

	ORI		r0,r1,high(SET_GPIO_OUT)	;SET_GPIO_OUTの上位16ビットをr1にセット
	SHLLI	r1,r1,16
	ORI		r1,r1,low(SET_GPIO_OUT)		;SET_GPIO_OUTの下位16ビットをr1にセット

	ORI		r0,r2,high(GET_GPIO_OUT)	;GET_GPIO_OUTの上位16ビットをr2にセット
	SHLLI	r2,r2,16
	ORI		r2,r2,low(GET_GPIO_OUT)		;GET_GPIO_OUTの下位16ビットをr2にセット

;;; LED消灯
	ORI		r0,r16,0x3
	SHLLI	r16,r16,16
	ORI		r16,r16,0xFFFF
	CALL	r1
	ANDR	r0,r0,r0

;;; 例外ベクタの設定
	ORI		r0,r3,high(EXCEPT_HANDLER)
	SHLLI	r3,r3,16
	ORI		r3,r3,low(EXCEPT_HANDLER)
	WRCR	r3,c4

;;; 割り込みの初期設定
	;; Mask
	ORI		r0,r3,0xFE					;Interrupt Maskにセットする値をr3に入れる
	WRCR	r3,c6

	;; Status
	ORI		r0,r3,0x2					;Statusにセットする値をr3に入れる(IE:1,EM:0)
	WRCR	r3,c0

;;; タイマの初期設定
	;; Expiration Register
	ORI		r0,r3,TIMER_BASE_ADDR_H		;Timer Base Address上位16ビットをr3にセット
	SHLLI	r3,r3,16
	ORI		r0,r4,0x4C					;満了値の値
	SHLLI	r4,r4,16
	ORI		r4,r4,0x4B40				;満了値の値
	STW		r3,r4,TIMER_EXPIRE_OFFSET	;満了値を設定
	;; Control Register
	ORI		r0,r4,0x3					;Periodic:1, Start:1
	STW		r3,r4,TIMER_CTRL_OFFSET		;Timer Control Registerを設定

;; 無限待ち
LOOP:
	BE		r0,r0,LOOP					;無限ループ
	ANDR	r0,r0,r0					;NOP


SET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	STW		r17,r16,GPIO_OUT_OFFSET
_SET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP

GET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	LDW		r17,r16,GPIO_OUT_OFFSET
_GET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP


;; 割り込みハンドラ
EXCEPT_HANDLER:
	;; 割り込みステータスクリア
	ORI		r0,r24,TIMER_BASE_ADDR_H	;Timer Base Address上位16ビットをr24にセット
	SHLLI	r24,r24,16
	STW		r24,r0,TIMER_INTR_OFFSET	;Interruptをクリア

	;;  LED出力データを反転
	CALL	r2
	ANDR	r0,r0,r0
	ORI		r0,r24,1
	SHLLI	r24,r24,16
	XORR	r16,r24,r16
	CALL	r1
	ANDR	r0,r0,r0

	;; 遅延スロット確認
	RDCR	c5,r24
	ANDI	r24,r24,0x8
	BE		r0,r24,GOTO_EXRT
	ANDR	r0,r0,r0					;NOP
	RDCR	c3,r24
	ADDUI	r24,r24,-4
	WRCR	r24,c3
GOTO_EXRT:
	;; 割り込みが発生したアドレスに戻る
	EXRT
	ANDR	r0,r0,r0					;NOP
