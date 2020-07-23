;;; ロケーションアドレスの設定
	LOCATE	0x20000000

;;; シンボルの定義
TIMER_BASE_ADDR_H	EQU	0x4000			;Timer Base Address High
TIMER_CTRL_OFFSET	EQU	0x0				;Timer Control Register Offset
TIMER_INTR_OFFSET	EQU	0x4				;Timer Interrupt Register Offset
TIMER_EXPIRE_OFFSET	EQU	0x8				;Timer Expiration Register Offset
GPIO_BASE_ADDR_H	EQU	0x8000			;GPIO Base Address High
GPIO_IN_OFFSET		EQU	0x0				;GPIO Input Port Register Offset
GPIO_OUT_OFFSET		EQU	0x4				;GPIO Data Register Offset

7SEG_DATA_0			EQU	0xC0
7SEG_DATA_1			EQU	0xF9
7SEG_DATA_2			EQU	0xA4
7SEG_DATA_3			EQU	0xB0
7SEG_DATA_4			EQU	0x99
7SEG_DATA_5			EQU	0x92
7SEG_DATA_6			EQU	0x82
7SEG_DATA_7			EQU	0xF8
7SEG_DATA_8			EQU	0x80
7SEG_DATA_9			EQU	0x90

PUSH_SW_DATA_1		EQU	0x1
PUSH_SW_DATA_2		EQU	0x2
PUSH_SW_DATA_3		EQU	0x4
PUSH_SW_DATA_4		EQU	0x8


	XORR	r0,r0,r0

;;; サブルーチンコールのコール先をレジスタにセット
	ORI		r0,r1,high(CONV_NUM_TO_7SEG_DATA)	;ラベルCONV_NUM_TO_7SEG_DATAの上位16ビットをr1にセット
	SHLLI	r1,r1,16
	ORI		r1,r1,low(CONV_NUM_TO_7SEG_DATA)	;ラベルCONV_NUM_TO_7SEG_DATAの下位16ビットをr1にセット

	ORI		r0,r2,high(SET_GPIO_OUT)			;ラベルSET_GPIO_OUTの上位16ビットをr2にセット
	SHLLI	r2,r2,16
	ORI		r2,r2,low(SET_GPIO_OUT)				;ラベルSET_GPIO_OUTの下位16ビットをr2にセット

	ORI		r0,r3,high(DETECT_PUSH_SW_NUM)		;ラベルDETECT_PUSH_SW_NUMの上位16ビットをr3にセット
	SHLLI	r3,r3,16
	ORI		r3,r3,low(DETECT_PUSH_SW_NUM)		;ラベルDETECT_PUSH_SW_NUMの下位16ビットをr3にセット

	ORI		r0,r4,high(GET_GPIO_OUT)			;ラベルGET_GPIO_OUTの上位16ビットをr4にセット
	SHLLI	r4,r4,16
	ORI		r4,r4,low(GET_GPIO_OUT)				;ラベルGET_GPIO_OUTの下位16ビットをr4にセット

;;; 例外ベクタの設定
	ORI		r0,r7,high(EXCEPT_HANDLER)
	SHLLI	r7,r7,16
	ORI		r7,r7,low(EXCEPT_HANDLER)
	WRCR	r7,c4

;;; 割り込みの初期設定
	;; Mask
	ORI		r0,r7,0xFE						;Interrupt Maskにセットする値をr7に入れる
	WRCR	r7,c6
	;; Status
	ORI		r0,r7,0x2						;Statusにセットする値をr1に入れる(IE:1,EM0)
	WRCR	r7,c0

_RESET_TIMER:
	;; 分と秒を0に設定
	ORI		r0,r5,0							;r5(分)をクリア
	ORI		r0,r6,0							;r6(秒)をクリア
	;; 分を表示(7セグ点灯)
	ORR		r0,r5,r16						;r16に表示する値をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,2							;LED1
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	XORR	r13,r13,r13						;分or秒をクリア(0:分, 1:秒)

;;; プッシュボタンを検出
_TIMER_SETTING_LOOP:
	CALL	r3
	ANDR	r0,r0,r0
	ORR		r0,r16,r7
	ORI		r0,r8,PUSH_SW_DATA_1
	BE		r7,r8,_HANDLE_PUSH_SW_1
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r8,PUSH_SW_DATA_2
	BE		r7,r8,_HANDLE_PUSH_SW_2
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r8,PUSH_SW_DATA_3
	BE		r7,r8,_HANDLE_PUSH_SW_3
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r8,PUSH_SW_DATA_4
	BE		r7,r8,_HANDLE_PUSH_SW_4
	ANDR	r0,r0,r0						;NOP

;;; ボタン1
;;; 分と秒の表示の切り替え
_HANDLE_PUSH_SW_1:
	BNE		r0,r13,_SECOND_TO_MINUTE		;分or秒？(0:分, 1:秒)
	ANDR	r0,r0,r0						;NOP

_MINUTE_TO_SECOND:
	ORR		r0,r6,r16						;秒をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,1							;LED2
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	XORI	r13,r13,1						;分or秒を切り替え
	BE		r0,r0,_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0						;NOP

_SECOND_TO_MINUTE:
	ORR		r0,r5,r16						;分をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,2							;LED1
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	XORI	r13,r13,1						;分or秒を切り替え
	BE		r0,r0,_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0						;NOP

;;; ボタン2
;;; 表示されている値を1増やす
_HANDLE_PUSH_SW_2:
	BNE		r0,r13,_INC_SECOND				;分or秒？(0:分, 1:秒)
	ANDR	r0,r0,r0						;NOP

_INC_MINUTE:
	ADDUI	r5,r5,1							;分を1増やす
	ORI		r0,r7,100						;100になったら分をクリアする
	BNE		r7,r5,_DISPLAY_MINUTE_1
	ANDR	r0,r0,r0
	ORI		r0,r5,0

_DISPLAY_MINUTE_1:
	ORR		r0,r5,r16						;分をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,2							;LED1
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	BE		r0,r0,_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0						;NOP

_INC_SECOND:
	ADDUI	r6,r6,1							;秒を1増やす
	ORI		r0,r7,60						;60になったら秒をクリアする
	BNE		r7,r6,_DISPLAY_SECOND_1
	ANDR	r0,r0,r0
	ORI		r0,r6,0

_DISPLAY_SECOND_1:
	ORR		r0,r6,r16						;秒をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,1							;LED2
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	BE		r0,r0,_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0						;NOP

;;; ボタン3
;;; 表示されている値を1減らす
_HANDLE_PUSH_SW_3:
	BNE		r0,r13,_DEC_SECOND				;分or秒？(0:分, 1:秒)
	ANDR	r0,r0,r0						;NOP

_DEC_MINUTE:
	ADDUI	r5,r5,-1						;分を1減らす
	ADDUI	r0,r7,-1
	BNE		r5,r7,_DISPLAY_MINUTE_2
	ANDR	r0,r0,r0
	ORI		r0,r5,99

_DISPLAY_MINUTE_2:
	ORR		r0,r5,r16						;分をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,2							;LED1
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	BE		r0,r0,_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0						;NOP

_DEC_SECOND:
	ADDUI	r6,r6,-1						;秒を1減らす
	ADDUI	r0,r7,-1
	BNE		r6,r7,_DISPLAY_SECOND_2
	ANDR	r0,r0,r0
	ORI		r0,r6,59

_DISPLAY_SECOND_2:
	ORR		r0,r6,r16						;秒をセット
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,1							;LED2
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP
	BE		r0,r0,_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0						;NOP

;;; ボタン4
;;; タイマ開始
_HANDLE_PUSH_SW_4:
	;; 分と秒の値が0ならば_RESET_TIMERに戻る
	ADDUR	r5,r6,r12
	BE		r0,r12,_RESET_TIMER
	ANDR	r0,r0,r0
	;; 秒の値を満了値に変換
	ORI		r0,r9,0							;満了値
	ORR		r0,r6,r11						;秒をコピー
	ORI		r0,r7,0x98
	SHLLI	r7,r7,16
	ORI		r7,r7,0x9680
	ORI		r0,r8,0x23C3
	SHLLI	r8,r8,16
	ORI		r8,r8,0x4600
	BE		r0,r11,_ONE_MINUTE
	ANDR	r0,r0,r0

_SECONDS:
	ADDUR	r9,r7,r9
	ADDUI	r11,r11,-1						;秒を1減らす
	BE		r0,r11,_SET_TIMER
	ANDR	r0,r0,r0
	BE		r0,r0,_SECONDS
	ANDR	r0,r0,r0

	;; 1分の値でタイマを設定
_ONE_MINUTE:
	ADDUR	r9,r8,r9
	ADDUI	r5,r5,-1						;分を1減らす

_SET_TIMER:
;;; 分を表示
	ORR		r0,r5,r16
	CALL	r1								;呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r7,3
	SHLLI	r7,r7,16
	ORR		r7,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP

	;; タイマの設定
	;; Expiration Register
	ORI		r0,r7,TIMER_BASE_ADDR_H			;Timer Base Address上位16ビットをr7にセット
	SHLLI	r7,r7,16
	STW		r7,r9,TIMER_EXPIRE_OFFSET		;満了値を設定

	;; Control Register
	;; タイマをスタート
	ORI		r0,r8,0x1						;Periodic:0, Start:1
	STW		r7,r8,TIMER_CTRL_OFFSET			;Timer Control Registerを設定

;;; .を点滅
	ORI		r0,r7,0x10
	SHLLI	r7,r7,16
	ORI		r7,r7,0x0000
_TIMER_LOOP:
	ADDUI	r7,r7,-1

	ADDUI	r0,r8,-1
	BE		r8,r5,_SET_LED
	ANDR	r0,r0,r0

	BNE		r0,r7,_TIMER_LOOP
	ANDR	r0,r0,r0

	;7セグの値を読む
	CALL	r4
	ANDR	r0,r0,r0

	XORI	r16,r16,0x8000

	CALL	r2
	ANDR	r0,r0,r0						;NOP

	ORI		r0,r7,0x10
	SHLLI	r7,r7,16
	ORI		r7,r7,0x0000
	BE		r0,r0,_TIMER_LOOP
	ANDR	r0,r0,r0

;;; 2つのLED点滅
_SET_LED:
	ORI		r0,r7,TIMER_BASE_ADDR_H			;Timer Base Address上位16ビットをr7にセット
	SHLLI	r7,r7,16
	STW		r7,r0,TIMER_CTRL_OFFSET			;Timer Control Registerを設定

	ORI		r0,r7,1
	SHLLI	r7,r7,16

_SET_LED2:
	ORI		r0,r10,0xFFFF

	;7セグの値を読む
	CALL	r4
	ANDR	r0,r0,r0

	XORR	r16,r7,r16

	CALL	r2
	ANDR	r0,r0,r0						;NOP

;;; プッシュボタンが押された

	;ボタン1はbit16とする
	ORI		r0,r7,GPIO_BASE_ADDR_H			;GPIO Base Address上位16ビットをr7にセット
	SHLLI	r7,r7,16
_DETECT_PUSH_BUTTON_2:
	LDW		r7,r8,GPIO_IN_OFFSET			;GPIO Input Port Registerの値を取得
	BNE		r0,r8,_GOTO_TIMER_SETTING_LOOP

	ANDR	r0,r0,r0						;NOP

	ADDUI	r10,r10,-1

	BNE		r0,r10,_DETECT_PUSH_BUTTON_2
	ANDR	r0,r0,r0

	ORI		r0,r7,3
	SHLLI	r7,r7,16

	BE		r0,r0,_SET_LED2
	ANDR	r0,r0,r0

_GOTO_TIMER_SETTING_LOOP:
	LDW		r7,r8,GPIO_IN_OFFSET			;GPIO Input Port Registerの値を取得
	BNE		r0,r8,_GOTO_TIMER_SETTING_LOOP
	ANDR	r0,r0,r0
	BE		r0,r0,_RESET_TIMER
	ANDR	r0,r0,r0


;;; 7セグ点灯ルーチン
CONV_NUM_TO_7SEG_DATA:
	;; 下位の桁から数字を抽出
	ORR		r0,r16,r18						;r16をr18にコピー
	XORR	r17,r17,r17						;Return Valueのクリア
	XORR	r19,r19,r19						;0:1桁目(7SEG2), 1:2桁目(7SEG1)
	XORR	r20,r20,r20						;2桁目の値
	;; 10の位の値を求める
	ORI		r0,r21,10						;r21に10をいれる
_SUB10:
	BUGT	r18,r21,_CHECK_0				;r18<r21(r18<10)ならば_CHECK_0にとぶ
	ANDR	r0,r0,r0						;NOP
	ADDUI	r18,r18,-10
	ADDUI	r20,r20,1
	BE		r0,r0,_SUB10					;r21<r18ならばSUB10にとぶ
	ANDR	r0,r0,r0						;NOP

_CHECK_0:
	ORI		r0,r21,0
	BNE		r18,r21,_CHECK_1
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_0
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_1:
	ORI		r0,r21,1
	BNE		r18,r21,_CHECK_2
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_1
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_2:
	ORI		r0,r21,2
	BNE		r18,r21,_CHECK_3
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_2
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_3:
	ORI		r0,r21,3
	BNE		r18,r21,_CHECK_4
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_3
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_4:
	ORI		r0,r21,4
	BNE		r18,r21,_CHECK_5
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_4
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_5:
	ORI		r0,r21,5
	BNE		r18,r21,_CHECK_6
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_5
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_6:
	ORI		r0,r21,6
	BNE		r18,r21,_CHECK_7
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_6
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_7:
	ORI		r0,r21,7
	BNE		r18,r21,_CHECK_8
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_7
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_8:
	ORI		r0,r21,8
	BNE		r18,r21,_CHECK_9
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_8
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_9:
	ORI		r0,r22,7SEG_DATA_9
	BNE		r0,r19,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP
	SHLLI	r22,r22,8						;7SEG2用の8ビットシフト

_SET_RETURN_VALUE:
	ORR		r17,r22,r17
	BNE		r0,r19,_CONV_NUM_TO_7SEG_DATA_RETURN
	ANDR	r0,r0,r0						;NOP
_NEXT_DIGIT:
	ORR		r0,r20,r18
	ORI		r19,r19,1						;0:1桁目(7SEG2), 1:2桁目(7SEG1)
	BE		r0,r0,_CHECK_0
	ANDR	r0,r0,r0						;NOP
_CONV_NUM_TO_7SEG_DATA_RETURN:
	JMP		r31
	ANDR	r0,r0,r0						;NOP


SET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	STW		r17,r16,GPIO_OUT_OFFSET
_SET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0						;NOP


GET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	LDW		r17,r16,GPIO_OUT_OFFSET
_GET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0						;NOP


DETECT_PUSH_SW_NUM:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
_WAIT_PUSH_SW_ON:
	LDW		r17,r18,GPIO_IN_OFFSET
	BE		r0,r18,_WAIT_PUSH_SW_ON
	ANDR	r0,r0,r0						;NOP
_WAIT_PUSH_SW_OFF:
	LDW		r17,r19,GPIO_IN_OFFSET
	BNE		r0,r19,_WAIT_PUSH_SW_OFF
	ANDR	r0,r0,r0						;NOP
_CHECK_PUSH_SW_1:
	ANDI	r18,r19,PUSH_SW_DATA_1
	BNE		r0,r19,_SET_RETURN_VALUE_PUSH_SW
	ANDR	r0,r0,r0						;NOP
_CHECK_PUSH_SW_2:
	ANDI	r18,r19,PUSH_SW_DATA_2
	BNE		r0,r19,_SET_RETURN_VALUE_PUSH_SW
	ANDR	r0,r0,r0						;NOP
_CHECK_PUSH_SW_3:
	ANDI	r18,r19,PUSH_SW_DATA_3
	BNE		r0,r19,_SET_RETURN_VALUE_PUSH_SW
	ANDR	r0,r0,r0						;NOP
_CHECK_PUSH_SW_4:
	ANDI	r18,r19,PUSH_SW_DATA_4
	BNE		r0,r19,_SET_RETURN_VALUE_PUSH_SW
	ANDR	r0,r0,r0						;NOP
_SET_RETURN_VALUE_PUSH_SW:
	ORR		r0,r19,r16
_DETECT_PUSH_SW_NUM_RETURN:
	JMP		r31
	ANDR	r0,r0,r0						;NOP

;;; 割り込みハンドラ
EXCEPT_HANDLER:
	;; 割り込みステータスクリア
	ORI		r0,r24,TIMER_BASE_ADDR_H		;Timer Base Address上位16ビットをr24にセット
	SHLLI	r24,r24,16
	STW		r24,r0,TIMER_INTR_OFFSET		;Interruptをクリア
	STW		r24,r0,TIMER_CTRL_OFFSET		;タイマを停止

	;; 分の値を1減らす
	ADDUI	r5,r5,-1
	ADDUI	r0,r25,-1
	BE		r5,r25,_END_OF_INTR_HANDLER
	ANDR	r0,r0,r0

	;; タイマを1分に設定
	ORI		r0,r25,0x23C3
	SHLLI	r25,r25,16
	ADDUI	r25,r25,0x4600
	STW		r24,r25,TIMER_EXPIRE_OFFSET		;満了値を設定
	ORI		r0,r8,0x3						;Periodic:1, Start:1
	STW		r24,r8,TIMER_CTRL_OFFSET		;Timer Control Registerを設定

	;; 分を表示
	ORR		r0,r5,r16
	CALL	r1								;CONV_NUM_TO_7SEG_DATA呼び出し
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r24,3
	SHLLI	r24,r24,16
	ORR		r24,r17,r16
	CALL	r2
	ANDR	r0,r0,r0						;NOP

_END_OF_INTR_HANDLER:
	;; 遅延スロット確認
	RDCR	c5,r24
	ANDI	r24,r24,0x8
	BE		r0,r24,_GOTO_EXRT
	ANDR	r0,r0,r0						;NOP
	RDCR	c3,r24
	ADDUI	r24,r24,-4
	WRCR	r24,c3

_GOTO_EXRT:
	;; 割り込みが発生したアドレスに戻る
	EXRT
	ANDR	r0,r0,r0						;NOP
