/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test   
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv  //variabile diferite de noi
  (input  logic          clk,    
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
  
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );
 // linile 10- 18
 //scopul e sa genereze semnale, stimuli pentru dut, pentru a verifica daca am implementat corect

  timeunit 1ns/1ns;


  logic bit_semn;   //ia 1(negativ) sau 0(pozitiv)
  assign bit_semn = instruction_word.rezultat[63];



  result_t rezultatdenoi;
  instruction_t  iw_reg_test [0:31];





  parameter WR_NR = 64;
  parameter RD_NR = 64;
  parameter WR_ORDER = 0;
  parameter RR_ORDER = 0;
  parameter seed_nou;
  int seed = seed_nou;
  int file;
  int contor1 = 0;
  int contor2 = 0;
    //display pune pe consola
  initial begin




    
  $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH (YET). YOU DON'T ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION, ***"); 
    $display(  "***            EVERYTHING IS AUTOMATED                  ***");
    $display(  "***********************************************************\n");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low) 
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles  // test clock
    reset_n        = 1'b1;          // deassert reset_n (active low)





     foreach (iw_reg_test[i])
        iw_reg_test[i] = '{opc:ZERO,default:0};  // reset to all zeros 
    











    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register

    //$display("load_en =  %d, timp = %t", load_en, $time);

    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=RD_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) read_pointer = i; // de scos si aici case
      @(negedge clk) print_results;
      check_result;

      case (RR_ORDER)
    0 : read_pointer = i % 32;
    1 : read_pointer = $unsigned($random)%32;
    2 : read_pointer = 31-(i%32);
    endcase
    end






    file = $fopen("../reports/regression_transcript/regression_transcript.txt", "a");
    $fdisplay(file, "WRITE_ORDER:%0d, READ_ORDER:%0d, there are %0d passed results and %0d failed results", WR_ORDER, RR_ORDER, contor1, contor2 );
    $fclose(file);


    




    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH (YET). YOU DON'T ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION, ***"); 
    $display(  "***            EVERYTHING IS AUTOMATED                  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;

  //
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    static int temp1 = 31 ;
    

    operand_a     = $random(seed)%16;                 // between -15 and 15
    operand_b     = $unsigned($random)%16;            // between 0 and 15
    opcode        =   opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type

    case (WR_ORDER)
    0 : write_pointer = temp++;
    1 : write_pointer = $unsigned($random)%32;
    2 : write_pointer = temp1--;
    endcase




//    write_pointer = temp++;

    $display( "valori inainainte "); 
    $display( "opcode %d", opcode );
    $display( "operand_a %d", operand_a );
    $display( "operand_b %d", operand_b );
    iw_reg_test[write_pointer] = '{opcode,operand_a,operand_b,64'b0};
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result    = %0d", instruction_word.rezultat);
    $display("  bit_semn = %0d\n", instruction_word.rezultat[63]);
    
    





  endfunction: print_results



function void check_result;
   
    case (iw_reg_test[read_pointer].opc)
        ZERO : rezultatdenoi = 64'b0; // este setat la 0
        PASSA : rezultatdenoi = iw_reg_test[read_pointer].op_a;
        PASSB : rezultatdenoi = iw_reg_test[read_pointer].op_b;
        ADD : rezultatdenoi = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
        SUB : rezultatdenoi = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
        MULT : rezultatdenoi = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
        
        
        DIV : 
            if(iw_reg_test[read_pointer].op_b == 0) 
            rezultatdenoi = 0;
            else
            rezultatdenoi = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
        
        
        MOD:
            if(iw_reg_test[read_pointer].op_b == 0) 
            rezultatdenoi = 0;
            else
            rezultatdenoi = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;

        POW: rezultatdenoi = iw_reg_test[read_pointer].op_a ** iw_reg_test[read_pointer].op_b;
    endcase

    $display("rezultatul nostru: ", rezultatdenoi);
    if (instruction_word.rezultat == rezultatdenoi) begin 
      contor1++;
    $display("rezultat corect");
    end else begin
      contor2++;
      $display("rezultatul nu este corect");
    end


   


$display("\n***********************************************************");
// reports;
$display("Rezultate finale ale testelor:");
$display("Numar teste trecute: %0d", contor1);
$display("Numar teste nereusite: %0d", contor2);
$display("***********************************************************\n");


endfunction: check_result


endmodule: instr_register_test