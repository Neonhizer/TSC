/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top;
  timeunit 1ns/1ns;  

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;  // se importa toate pachetele, ce contine in el ::*

  // clock variables
  logic clk;
  logic test_clk;  // 0,1,x,z

  // interconnecting signals
  logic          load_en;
  logic          reset_n;
  opcode_t       opcode;  //t vine de la template (data definita de utilizator)
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;

  // instantiate testbench and connect ports
  instr_register_test test (   //primul numele modulului (instr_register_test) si al 2-le numele instantei 
    .clk(test_clk), //de la linia 25 pana la 33 sunt porturi "."
    .load_en(load_en), //am o sarma intre dut si test load_en, (buton pronire)
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // clock oscillators
  initial begin // initial se incepe cu 0
    clk <= 0;
    forever #5  clk = ~clk;    // 5 unitati de timp , ne uitam la linia 5 - 5nanosecunde asteapta, perioada e 10 nanosecunde
  end
 



  initial begin
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;    // aici tot este perioada 10 ns, palier pozitiv / T * 100 (8/10*100)
    end
  end

endmodule: top
