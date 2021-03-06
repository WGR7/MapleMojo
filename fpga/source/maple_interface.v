module maple_interface(
    input clk,
    input rst,

    inout[0:3] pin1,
    inout[0:3] pin5,
    inout[0:3] pin4,

    inout spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck
   );

   localparam VERSION = 8'ha6;

   localparam CLOCKDIV_INIT = 8'h6;


   // Maple I/O
   
   assign pin4 = 4'bzzzz;

   wire [1:0] port_select;

   wire [7:0] clock_div;
   
   wire   in_p1;
   wire   in_p5;
   wire   out_p1;
   wire   out_p5;
   wire   maple_oe;

   wire   out_status_end;
   wire   out_status_start;
   reg    trigger_out_start;
   reg    trigger_out_end;

   wire   in_status_active;
   wire   in_status_start;
   wire   in_status_end;
   reg    trigger_in_start;
   reg    trigger_in_end;
   
   wire [7:0] write_fifo_data_in;
   wire [7:0] write_fifo_data_out;
   wire       write_fifo_produce;
   wire       write_fifo_consume;
   wire       write_fifo_ready;
   wire       write_data_avail;
   wire       write_fifo_overflow;
   wire       write_fifo_underflow;
   reg        trigger_write_fifo_reset;
   
   wire [7:0] write_fifo_inavail;
   wire [7:0] write_fifo_outavail;
   
   wire [7:0] read_fifo_data_in;
   wire [7:0] read_fifo_data_out;
   wire       read_fifo_produce;
   wire       read_fifo_consume;
   wire       read_data_avail;
   wire       read_fifo_overflow;
   wire       read_fifo_underflow;
   reg        trigger_read_fifo_reset;
   
   wire [7:0] read_fifo_inavail;
   wire [7:0] read_fifo_outavail;
   
   maple_ports phys_ports
     (
      .pin1(pin1),
      .pin5(pin5),
      .port_select(port_select),
      .out_p1(out_p1),
      .out_p5(out_p5),
      .oe(maple_oe),
      .in_p1(in_p1),
      .in_p5(in_p5)
      );

   maple_out out_ctrl
     (
      .rst(rst), .clk(clk),
      .pin1(out_p1), .pin5(out_p5), .oe(maple_oe),
      .start_active(out_status_start), .end_active(out_status_end),
      .trigger_start(trigger_out_start), .trigger_end(trigger_out_end),
      .tick(tick),
      .fifo_data(write_fifo_data_out), .data_avail(write_data_avail),
      .data_consume(write_fifo_consume)
     );

   maple_in in_ctrl
     (
      .rst(rst), .clk(clk),
      .pin1(in_p1), .pin5(in_p5), .oe(maple_oe),
      .active(in_status_active),
      .start_detected(in_status_start), .end_detected(in_status_end),
      .trigger_start(trigger_in_start), .trigger_end(trigger_in_end),
      .fifo_data(read_fifo_data_in), .data_produce(read_fifo_produce)
      );
   
   
   fifo #(16) write_fifo
     (
      .rst(rst), .clk(clk),
      .indata(write_fifo_data_in), .instrobe(write_fifo_produce),
      .inavail(write_fifo_ready), .inavail_cnt(write_fifo_inavail),
      .outdata(write_fifo_data_out), .outstrobe(write_fifo_consume),
      .outavail(write_data_avail), .outavail_cnt(write_fifo_outavail),
      .overflow(write_fifo_overflow), .underflow(write_fifo_underflow),
      .manual_reset(trigger_write_fifo_reset)
     );
   
   fifo #(16) read_fifo
     (
      .rst(rst), .clk(clk),
      .indata(read_fifo_data_in), .instrobe(read_fifo_produce),
      .inavail(), .inavail_cnt(read_fifo_inavail),
      .outdata(read_fifo_data_out), .outstrobe(read_fifo_consume),
      .outavail(read_data_avail), .outavail_cnt(read_fifo_outavail),
      .overflow(read_fifo_overflow), .underflow(read_fifo_underflow),
      .manual_reset(trigger_read_fifo_reset || maple_oe)
     );
   
   clock_divider clkdiv
     (
      .clk(clk), .rst(rst),
      .divider(clock_div), .tick(tick)
     );


   // Registers
   
   localparam REG_VERSION = 0;
   localparam REG_SCRATCHPAD = 1;
   localparam REG_CLOCKDIV = 2;
   localparam REG_PORTSEL = 3;
   localparam REG_OUTCTRL = 4;
   localparam REG_INCTRL = 5;
   localparam REG_OUTFIFO_CNT = 6;
   localparam REG_OUTFIFO_FREE = 7;
   localparam REG_INFIFO_CNT = 8;
   localparam REG_INFIFO_FREE = 9;
   localparam REG_FIFO = 10;
   
   wire [6:0] reg_num;
   wire reg_read;
   wire reg_write;
   reg  [7:0] reg_data_read;
   wire [7:0] reg_data_write;

   wire spi_miso_out;
   assign spi_miso = (spi_ss? 1'bz : spi_miso_out);

   regaccess reg_file
     (
      .clk(clk),
      .rst(rst),
      .ss(spi_ss),
      .mosi(spi_mosi),
      .miso(spi_miso_out),
      .sck(spi_sck),
      .regnum(reg_num),
      .regdata_read(reg_data_read),
      .regdata_write(reg_data_write),
      .read(reg_read),
      .write(reg_write)
     );

   assign write_fifo_data_in = reg_data_write;
   assign write_fifo_produce = reg_write && (reg_num == REG_FIFO);
   assign read_fifo_consume = reg_read && (reg_num == REG_FIFO);
   
   reg [7:0]  scratchpad_d, scratchpad_q;
   reg [7:0]  clock_div_d, clock_div_q;
   reg [1:0]  port_select_d, port_select_q;

   assign clock_div = clock_div_q;
   assign port_select = port_select_q;
   
   always @(*) begin

      scratchpad_d = scratchpad_q;
      clock_div_d = clock_div_q;
      port_select_d = port_select_q;
      trigger_out_start = 1'b0;
      trigger_out_end = 1'b0;
      trigger_in_start = 1'b0;
      trigger_in_end = 1'b0;
      trigger_write_fifo_reset = 1'b0;
      trigger_read_fifo_reset = 1'b0;
      
      case (reg_num)
	REG_VERSION: reg_data_read = VERSION;
	REG_SCRATCHPAD: begin
	   reg_data_read = scratchpad_q;
	   if (reg_write) scratchpad_d = reg_data_write;
	end
	REG_CLOCKDIV: begin
	   reg_data_read = clock_div_q;
	   if (reg_write) clock_div_d = reg_data_write;
	end
	REG_PORTSEL: begin
	   reg_data_read = { 6'b0, port_select_q };
	   if (reg_write) port_select_d = reg_data_write[1:0];
	end
	REG_OUTCTRL: begin
	   // 7  6  5  4  3 2  1 0
	   // FR FO FU FT 0 OE MODE
	   // FR (RO)  1 = FIFO Ready for write to REG_FIFO
	   // FO (RO)  1 = FIFO Overflow occurred, reset FIFO to clear
	   // FU (RO)  1 = FIFO Undrflow occurred, reset FIFO to clear
	   // FT (WO)  1 = Reset FIFO
	   // OE (RO)  1 = Bus is transmitting
	   // MODE    00 = Send FIFO data, then hold (if transmitting)
	   //         01 = Send START, then go to mode 00
	   //         10 = Send FIFO data, then END
	   //         11 = Send START, then go to mode 10
	   //              Write nonzero to MODE to manually change
	   reg_data_read = {write_fifo_ready,
			    write_fifo_overflow,
			    write_fifo_underflow,
			    2'b0,
			    maple_oe,
			    out_status_end,
			    out_status_start};
	   if (reg_write) begin
	      trigger_out_start = reg_data_write[0];
	      trigger_out_end = reg_data_write[1];
	      trigger_write_fifo_reset = reg_data_write[4];
	   end
	end
	REG_INCTRL: begin
	   // 7  6  5  4  3  2  1  0
	   // FR FO FU FT ST ED HT GO
	   // FR (RO)  1 = FIFO Ready for read from REG_FIFO
	   // FO (RO)  1 = FIFO Overflow occurred, reset FIFO to clear
	   // FU (RO)  1 = FIFO Undrflow occurred, reset FIFO to clear
	   // FT (WO)  1 = Reset FIFO
	   // ST (RO)  1 = Start pattern detected
	   // ED (RO)  1 = End pattern detected
	   // HT (WO)  1 = Halt receive operation
	   // GO       1 = Receive operation running
	   //              Write 1 to start receive operation
	   reg_data_read = {read_data_avail,
			    read_fifo_overflow,
			    read_fifo_underflow,
			    1'b0,
			    in_status_start,
			    in_status_end,
			    1'b0,
			    in_status_active};
	   if (reg_write) begin
	      trigger_read_fifo_reset = reg_data_write[4];
	      trigger_in_end = reg_data_write[1];
	      trigger_in_start = reg_data_write[0];
	   end
	end
 	REG_OUTFIFO_CNT: reg_data_read = write_fifo_outavail;
	REG_OUTFIFO_FREE: reg_data_read = write_fifo_inavail;
	REG_INFIFO_CNT: reg_data_read = read_fifo_outavail;
	REG_INFIFO_FREE: reg_data_read = read_fifo_inavail;
 	REG_FIFO:
	  reg_data_read = (read_data_avail? read_fifo_data_out : 8'b11111111);
	
	default: reg_data_read = 8'b11111111;
      endcase
   end   

   always @(posedge clk) begin
      if (rst) begin
	 scratchpad_q <= 0;
	 clock_div_q <= CLOCKDIV_INIT;
	 port_select_q <= 0;
      end else begin
	 scratchpad_q <= scratchpad_d;
	 clock_div_q <= clock_div_d;
	 port_select_q <= port_select_d;
      end
   end

   
endmodule // maple_interface
