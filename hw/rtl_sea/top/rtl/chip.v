/* 
 -- ============================================================================
 -- FILE NAME	: chip.v
 -- DESCRIPTION : Chip
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 Created
 -- ============================================================================
*/

/********** Global header **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** Local header **********/
`include "cpu.h"
`include "bus.h"
`include "rom.h"
`include "timer.h"
`include "uart.h"
`include "gpio.h"

/********** Module **********/
module chip (
	/********** Clock & Reset **********/
	input  wire						 clk,		  // Clock
	input  wire						 clk_,		  // Clock (180)
	input  wire						 reset		  // Reset
	/********** UART  **********/
`ifdef IMPLEMENT_UART // UART implementation
	, input	 wire					 uart_rx	  // UART RX
	, output wire					 uart_tx	  // UART TX
`endif
	/********** GPIO port **********/
`ifdef IMPLEMENT_GPIO // GPIO implementation
`ifdef GPIO_IN_CH	 // Implement input port
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in
`endif
`ifdef GPIO_OUT_CH	 // Implement output port
	, output wire [`GPIO_OUT_CH-1:0] gpio_out
`endif
`ifdef GPIO_IO_CH	 // Implement inout port
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io
`endif
`endif
);

	/********** Bus master signal **********/
	// Master commom signals~
	wire [`WordDataBus] m_rd_data;				  // Read data
	wire				m_rdy_;					  // Ready
	// Bus master 0
	wire				m0_req_;				  // Bus request
	wire [`WordAddrBus] m0_addr;				  // Address
	wire				m0_as_;					  // Address strobe
	wire				m0_rw;					  // Read/Write
	wire [`WordDataBus] m0_wr_data;				  // Write data
	wire				m0_grnt_;				  // Bus grant
	// Bus master 1
	wire				m1_req_;				  
	wire [`WordAddrBus] m1_addr;				 
	wire				m1_as_;					  
	wire				m1_rw;					  
	wire [`WordDataBus] m1_wr_data;				  
	wire				m1_grnt_;				  
	// Bus master 2
	wire				m2_req_;				  
	wire [`WordAddrBus] m2_addr;				  
	wire				m2_as_;					  
	wire				m2_rw;					  
	wire [`WordDataBus] m2_wr_data;				  
	wire				m2_grnt_;				 
	// Bus master 3
	wire				m3_req_;				 
	wire [`WordAddrBus] m3_addr;				  
	wire				m3_as_;					 
	wire				m3_rw;					  
	wire [`WordDataBus] m3_wr_data;				  
	wire				m3_grnt_;				 
	/********** Bus slave signal **********/
	// Slave common signals
	wire [`WordAddrBus] s_addr;					  // Address
	wire				s_as_;					  // Address strobe
	wire				s_rw;					  // Read/Write
	wire [`WordDataBus] s_wr_data;				  // Write data
	// Bus slave 0
	wire [`WordDataBus] s0_rd_data;				  // Read data
	wire				s0_rdy_;				  // Ready
	wire				s0_cs_;					  // Chip select
	// Bus slave 1
	wire [`WordDataBus] s1_rd_data;				  
	wire				s1_rdy_;				  
	wire				s1_cs_;					  
	// Bus slave 2
	wire [`WordDataBus] s2_rd_data;				  
	wire				s2_rdy_;				  
	wire				s2_cs_;					  
	// Bus slave 3
	wire [`WordDataBus] s3_rd_data;				  
	wire				s3_rdy_;				  
	wire				s3_cs_;					  
	// Bus slave 4
	wire [`WordDataBus] s4_rd_data;				  
	wire				s4_rdy_;				  
	wire				s4_cs_;					  
	// Bus slave 5
	wire [`WordDataBus] s5_rd_data;				 
	wire				s5_rdy_;				  
	wire				s5_cs_;					  
	// Bus slave 6
	wire [`WordDataBus] s6_rd_data;				  
	wire				s6_rdy_;				  
	wire				s6_cs_;					  
	// Bus slave 7
	wire [`WordDataBus] s7_rd_data;				  
	wire				s7_rdy_;				  
	wire				s7_cs_;					  
	/********** Interrupt request signal **********/
	wire				   irq_timer;			  // Timer IRQ
	wire				   irq_uart_rx;			  // UART IRQ（RX）
	wire				   irq_uart_tx;			  // UART IRQ（TX）
	wire [`CPU_IRQ_CH-1:0] cpu_irq;				  // CPU IRQ

	assign cpu_irq = {{`CPU_IRQ_CH-3{`LOW}}, 
					  irq_uart_rx, irq_uart_tx, irq_timer};

	/********** CPU **********/
	cpu cpu (
		/********** Clock & Reset **********/
		.clk			 (clk),					  // Clock
		.clk_			 (clk_),				  // Clock (180)
		.reset			 (reset),				  // Asynchronous reset
		/********** Bus interface **********/
		// IF Stage
		.if_bus_rd_data	 (m_rd_data),			  // Read data
		.if_bus_rdy_	 (m_rdy_),				  // Ready
		.if_bus_grnt_	 (m0_grnt_),			  // Bus grant
		.if_bus_req_	 (m0_req_),				  // Bus request
		.if_bus_addr	 (m0_addr),				  // Address
		.if_bus_as_		 (m0_as_),				  // Address strobe
		.if_bus_rw		 (m0_rw),				  // Read/Write
		.if_bus_wr_data	 (m0_wr_data),			  // Write data
		// MEM Stage
		.mem_bus_rd_data (m_rd_data),			  // Read data
		.mem_bus_rdy_	 (m_rdy_),				  // Ready
		.mem_bus_grnt_	 (m1_grnt_),			  // Bus grant
		.mem_bus_req_	 (m1_req_),				  // Bus request
		.mem_bus_addr	 (m1_addr),				  // Address
		.mem_bus_as_	 (m1_as_),				  // Address strobe
		.mem_bus_rw		 (m1_rw),				  // Read/Write
		.mem_bus_wr_data (m1_wr_data),			  // Write data
		/********** Interrupt **********/
		.cpu_irq		 (cpu_irq)				  // Interrupt request
	);

	/********** Bus master 2 : not used **********/
	assign m2_addr	  = `WORD_ADDR_W'h0;
	assign m2_as_	  = `DISABLE_;
	assign m2_rw	  = `READ;
	assign m2_wr_data = `WORD_DATA_W'h0;
	assign m2_req_	  = `DISABLE_;

	/********** Bus master 3 : not used **********/
	assign m3_addr	  = `WORD_ADDR_W'h0;
	assign m3_as_	  = `DISABLE_;
	assign m3_rw	  = `READ;
	assign m3_wr_data = `WORD_DATA_W'h0;
	assign m3_req_	  = `DISABLE_;
   
	/********** Bus slave 0 : ROM **********/
	rom rom (
		/********** Clock & Reset **********/
		.clk			 (clk),					  // Clock
		.reset			 (reset),				  // Asynchronous reset
		/********** Bus Interface **********/
		.cs_			 (s0_cs_),				  // Chip select
		.as_			 (s_as_),				  // Address strobe
		.addr			 (s_addr[`RomAddrLoc]),	  // Address
		.rd_data		 (s0_rd_data),			  // Read data
		.rdy_			 (s0_rdy_)				  // Ready
	);

	/********** Bus slave 1 : Scratch Pad Memory **********/
	assign s1_rd_data = `WORD_DATA_W'h0;
	assign s1_rdy_	  = `DISABLE_;

	/********** Bus slave 2 : Timer **********/
`ifdef IMPLEMENT_TIMER // Timer implementation
	timer timer (
		/********** Clock & Reset **********/
		.clk			 (clk),					 
		.reset			 (reset),				  
		/********** Bus Interface **********/
		.cs_			 (s2_cs_),				 
		.as_			 (s_as_),				  
		.addr			 (s_addr[`TimerAddrLoc]), 
		.rw				 (s_rw),				 
		.wr_data		 (s_wr_data),			  
		.rd_data		 (s2_rd_data),			 
		.rdy_			 (s2_rdy_),				
		/********** Interrupt **********/
		.irq			 (irq_timer)			  // Interrupt request
	 );
`else				   // If timer not implemented
	assign s2_rd_data = `WORD_DATA_W'h0;
	assign s2_rdy_	  = `DISABLE_;
	assign irq_timer  = `DISABLE;
`endif

	/********** Bus salve 3 : UART **********/
`ifdef IMPLEMENT_UART // UART implementation
	uart uart (
		/********** Clock & Reset **********/
		.clk			 (clk),					  
		.reset			 (reset),				  
		/********** Bus Interface **********/
		.cs_			 (s3_cs_),				  
		.as_			 (s_as_),				  
		.rw				 (s_rw),				
		.addr			 (s_addr[`UartAddrLoc]),  
		.wr_data		 (s_wr_data),			  
		.rd_data		 (s3_rd_data),			  
		.rdy_			 (s3_rdy_),				
		/********** Interrupt **********/
		.irq_rx			 (irq_uart_rx),			  // End of receive interrupt
		.irq_tx			 (irq_uart_tx),			  // End of send interrypt
		/********** UART RX & TX	**********/
		.rx				 (uart_rx),				  // UART RX
		.tx				 (uart_tx)				  // UART TX
	);
`else				  // If UART not implemented
	assign s3_rd_data  = `WORD_DATA_W'h0;
	assign s3_rdy_	   = `DISABLE_;
	assign irq_uart_rx = `DISABLE;
	assign irq_uart_tx = `DISABLE;
`endif

	/********** Bus slave 4 : GPIO **********/
`ifdef IMPLEMENT_GPIO // GPIO implementation
	gpio gpio (
		/********** Clock & Reset **********/
		.clk			 (clk),					 
		.reset			 (reset),				
		/********** Bus Interface **********/
		.cs_			 (s4_cs_),				
		.as_			 (s_as_),				 
		.rw				 (s_rw),				 
		.addr			 (s_addr[`GpioAddrLoc]), 
		.wr_data		 (s_wr_data),			 
		.rd_data		 (s4_rd_data),			 
		.rdy_			 (s4_rdy_)				
		/********** GPIO port **********/
`ifdef GPIO_IN_CH	 // Input port implementation
		, .gpio_in		 (gpio_in)				 
`endif
`ifdef GPIO_OUT_CH	 // Output port implementation
		, .gpio_out		 (gpio_out)				 
`endif
`ifdef GPIO_IO_CH	 // Inout port implementation
		, .gpio_io		 (gpio_io)				 
`endif
	);
`else				  // If GPIO not implemented
	assign s4_rd_data = `WORD_DATA_W'h0;
	assign s4_rdy_	  = `DISABLE_;
`endif

	/********** Bus slave 5 : not used **********/
	assign s5_rd_data = `WORD_DATA_W'h0;
	assign s5_rdy_	  = `DISABLE_;
  
	/********** Bus slave 6 : not used **********/
	assign s6_rd_data = `WORD_DATA_W'h0;
	assign s6_rdy_	  = `DISABLE_;
  
	/********** Bus slave 7 : not used **********/
	assign s7_rd_data = `WORD_DATA_W'h0;
	assign s7_rdy_	  = `DISABLE_;

	/********** Bus **********/
	bus bus (
		/********** Clock & Reset **********/
		.clk			 (clk),					 
		.reset			 (reset),				 
		/********** Bus master singal **********/
		// Master common signal
		.m_rd_data		 (m_rd_data),			 // Read data
		.m_rdy_			 (m_rdy_),				 // Ready
		// Bus master 0
		.m0_req_		 (m0_req_),				 // Bus request
		.m0_addr		 (m0_addr),				 // Address
		.m0_as_			 (m0_as_),				 // Address strobe
		.m0_rw			 (m0_rw),				 // Read/Write
		.m0_wr_data		 (m0_wr_data),			 // Write data
		.m0_grnt_		 (m0_grnt_),			 // Bus grant
		// Bus master 1
		.m1_req_		 (m1_req_),				 
		.m1_addr		 (m1_addr),				 
		.m1_as_			 (m1_as_),				 
		.m1_rw			 (m1_rw),				 
		.m1_wr_data		 (m1_wr_data),			 
		.m1_grnt_		 (m1_grnt_),			 
		//Bus master 2
		.m2_req_		 (m2_req_),				
		.m2_addr		 (m2_addr),				
		.m2_as_			 (m2_as_),				
		.m2_rw			 (m2_rw),				
		.m2_wr_data		 (m2_wr_data),			
		.m2_grnt_		 (m2_grnt_),			
		// Bus master 3
		.m3_req_		 (m3_req_),				 
		.m3_addr		 (m3_addr),				 
		.m3_as_			 (m3_as_),				
		.m3_rw			 (m3_rw),				
		.m3_wr_data		 (m3_wr_data),			 
		.m3_grnt_		 (m3_grnt_),			 
		/********** Bus slave signal **********/
		// Slave common signal
		.s_addr			 (s_addr),				 // Address
		.s_as_			 (s_as_),				 // Address strobe
		.s_rw			 (s_rw),				 // Read/Write
		.s_wr_data		 (s_wr_data),			 // Write data
		// Bus slave 0
		.s0_rd_data		 (s0_rd_data),			 // Read data
		.s0_rdy_		 (s0_rdy_),				 // Ready
		.s0_cs_			 (s0_cs_),				 // Chip select
		// Bus slave 1
		.s1_rd_data		 (s1_rd_data),			 
		.s1_rdy_		 (s1_rdy_),				 
		.s1_cs_			 (s1_cs_),				 
		// Bus slave 2
		.s2_rd_data		 (s2_rd_data),			 
		.s2_rdy_		 (s2_rdy_),				 
		.s2_cs_			 (s2_cs_),				 
		// Bus slave 3
		.s3_rd_data		 (s3_rd_data),			 
		.s3_rdy_		 (s3_rdy_),				 
		.s3_cs_			 (s3_cs_),				 
		// Bus slave 4
		.s4_rd_data		 (s4_rd_data),			 
		.s4_rdy_		 (s4_rdy_),				 
		.s4_cs_			 (s4_cs_),				 
		// Bus slave 5
		.s5_rd_data		 (s5_rd_data),			 
		.s5_rdy_		 (s5_rdy_),				 
		.s5_cs_			 (s5_cs_),				 
		// Bus slave 6
		.s6_rd_data		 (s6_rd_data),			 
		.s6_rdy_		 (s6_rdy_),				 
		.s6_cs_			 (s6_cs_),				 
		// Bus slave 7
		.s7_rd_data		 (s7_rd_data),			 
		.s7_rdy_		 (s7_rdy_),				 
		.s7_cs_			 (s7_cs_)				 
	);

endmodule
