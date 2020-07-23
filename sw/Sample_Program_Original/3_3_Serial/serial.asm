;;; シンボルの定義
UART_BASE_ADDR_H	EQU	0x6000			;UART Base Address High
UART_STATUS_OFFSET	EQU	0x0				;UART Status Register Offset
UART_DATA_OFFSET	EQU	0x4				;UART Data Register Offset
UART_RX_INTR_MASK	EQU	0x1				;UART Receive Interrupt Mask
UART_TX_INTR_MASK	EQU	0x2				;UART Transmit Interrupt Mask


	XORR	r0,r0,r0

	ORI		r0,r1,high(CLEAR_BUFFER)	;CLEAR_BUFFERの上位16ビットをr1にセット
	SHLLI	r1,r1,16
	ORI		r1,r1,low(CLEAR_BUFFER)		;CLEAR_BUFFERの下位16ビットをr1にセット

	ORI		r0,r2,high(SEND_CHAR)		;SEND_CHARの上位16ビットをr2にセット
	SHLLI	r2,r2,16
	ORI		r2,r2,low(SEND_CHAR)		;SEND_CHARの下位16ビットをr2にセット

;;; UARTバッファクリア
	CALL	r1							;CLEAR_BUFFER呼び出し
	ANDR	r0,r0,r0					;NOP

;;; 文字表示

	ORI		r0,r16,'H'					;r16に'H'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'e'					;r16に'e'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'l'					;r16に'l'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'l'					;r16に'l'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'o'					;r16に'o'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,','					;r16に','をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'w'					;r16に'w'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'o'					;r16に'o'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'r'					;r16に'r'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'l'					;r16に'l'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'d'					;r16に'd'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

	ORI		r0,r16,'.'					;r16に'.'をセット
	CALL	r2							;SEND_CHAR呼び出し
	ANDR	r0,r0,r0					;NOP

;;; 無限ループ
LOOP:
	BE		r0,r0,LOOP					;無限ループ
	ANDR	r0,r0,r0					;NOP

CLEAR_BUFFER:
	ORI		r0,r16,UART_BASE_ADDR_H		;UART Base Address上位16ビットをr16にセット
	SHLLI	r16,r16,16

_CHECK_UART_STATUS:
	LDW		r16,r17,UART_STATUS_OFFSET	;STATUSを取得

	ANDI	r17,r17,UART_RX_INTR_MASK
	BE		r0,r17,_CLEAR_BUFFER_RETURN	;Receive Interrupt bitが立っていなければ_CLEAR_BUFFER_RETURNを実行
	ANDR	r0,r0,r0					;NOP

_RECEIVE_DATA:
	LDW		r16,r17,UART_DATA_OFFSET	;受信データを読んでバッファをクリアする

	LDW		r16,r17,UART_STATUS_OFFSET	;STATUSを取得
	XORI	r17,r17,UART_RX_INTR_MASK
	STW		r16,r17,UART_STATUS_OFFSET	;Receive Interrupt bitをクリア

	BNE		r0,r0,_CHECK_UART_STATUS	;_CHECK_UART_STATUSに戻る
	ANDR	r0,r0,r0					;NOP
_CLEAR_BUFFER_RETURN:
	JMP		r31							;呼び出し元に戻る
	ANDR	r0,r0,r0					;NOP


SEND_CHAR:
	ORI		r0,r17,UART_BASE_ADDR_H		;UART Base Address上位16ビットをr17にセット
	SHLLI	r17,r17,16
	STW		r17,r16,UART_DATA_OFFSET	;r16を送信する

_WAIT_SEND_DONE:
	LDW		r17,r18,UART_STATUS_OFFSET	;STATUSを取得
	ANDI	r18,r18,UART_TX_INTR_MASK
	BE		r0,r18,_WAIT_SEND_DONE
	ANDR	r0,r0,r0

	LDW		r17,r18,UART_STATUS_OFFSET
	XORI	r18,r18,UART_TX_INTR_MASK
	STW		r17,r18,UART_STATUS_OFFSET	;Transmit Interrupt bitをクリア

	JMP		r31							;呼び出し元に戻る
	ANDR	r0,r0,r0					;NOP

