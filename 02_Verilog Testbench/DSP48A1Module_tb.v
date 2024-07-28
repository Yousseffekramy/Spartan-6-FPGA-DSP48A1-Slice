module DSP48A1Module_tb();
    /* Add All the parameters */
    parameter A0REG = 0; parameter B0REG = 0;
    parameter A1REG = 1; parameter B1REG = 1;
    parameter CREG  = 1; parameter DREG  = 1;
    parameter MREG  = 1; parameter PREG  = 1;

    parameter CARRYINREG = 1; parameter CARRYOUTREG = 1;
    parameter OPMODEREG = 1;

    parameter CARRYINSEL = "OPMODE5"; parameter B_INPUT = "DIRECT";
    parameter RSTTYPE = "SYNC";

    /* Add all the inputs */

    /* Data Ports */
    reg [17:0] A, B, D;
    reg [47:0] C;
    reg CARRYIN;
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;

    /* Control Input Ports */
    reg clk;
    reg [7:0] OPMODE;

    /* Clock Enable Input Ports */
    reg CEA, CEB, CEC;
    reg CED, CEM, CEP;
    reg CEOPMODE, CECARRYIN;

    /* Reset Input Ports */
    reg RSTA, RSTB, RSTC;
    reg RSTD, RSTM, RSTP;
    reg RSTOPMODE, RSTCARRYIN;

    /* Cascade Ports */ 
    reg [17:0] BCIN;
    wire [17:0] BCOUT;
    reg [47:0] PCIN; 
    wire [47:0] PCOUT;

    /* Self Checker Port*/
    reg [47:0] P_expected;

    /* Instantiate the DUT */
    DSP48A1Module #(.A0REG(A0REG),.A1REG(A1REG),
                    .B0REG(B0REG),.B1REG(B1REG),
                    .CREG(CREG),.DREG(DREG),
                    .MREG(MREG),.PREG(PREG),
                    .CARRYINREG(CARRYINREG),.CARRYOUTREG(CARRYOUTREG),
                    .OPMODEREG(OPMODEREG),
                    .CARRYINSEL(CARRYINSEL),.B_INPUT(B_INPUT),
                    .RSTTYPE(RSTTYPE))
                    DUT (.*);

    /* Clock Generation */
    initial begin
         clk = 0;
         forever begin
         #5; clk = ~clk;
         end
    end

    /* DIRECTED and RANDOMIZED TESTBENCH */
    initial begin
        $display ("START THE SIMULATION");
        $display ("-------------------------");
        /* Initialize Inputs */
        A = 0; B = 0; D = 0; C = 0;
        CARRYIN = 0; OPMODE = 0;
        CEA = 0; CEB = 0; CEC = 0;
        CED = 0; CEM = 0; CEP = 0;
        CEOPMODE = 0; CECARRYIN = 0;
        RSTA = 0; RSTB = 0; RSTC = 0;
        RSTD = 0; RSTM = 0; RSTP = 0;
        RSTOPMODE = 0; RSTCARRYIN = 0;
        BCIN = 0; PCIN = 0;
        repeat(3) @(negedge clk);

        /* Check the reset functionality */
        // Initialize all the inputs by 1
        A = 1; B = 1; D = 1; C = 1;
        CARRYIN = 1; OPMODE = 1;

        // Initialize clock enables by 1
        CEA = 1; CEB = 1; CEC = 1;
        CED = 1; CEM = 1; CEP = 1;
        CEOPMODE = 1; CECARRYIN = 1;

        // Initialize reset by 1
        RSTA = 1; RSTB = 1; RSTC = 1;
        RSTD = 1; RSTM = 1; RSTP = 1;
        RSTOPMODE = 1; RSTCARRYIN = 1;
        repeat(3) @(negedge clk);

        // Check the reset functionality
        $display ("Reset_functionality TEST");
        self_checker(P,0);
        $display ("-------------------------");

        // Initialize reset by 0
        RSTA = 0; RSTB = 0; RSTC = 0;
        RSTD = 0; RSTM = 0; RSTP = 0;
        RSTOPMODE = 0; RSTCARRYIN = 0;


        /* PRE-ADDER output (Addition) */
        A = 18'd1;
        B = 18'd5;
        D = 18'd3;
        C = 48'd100;
        OPMODE = 8'b0001_0001; 
        repeat(4) @(negedge clk);
        $display("PRE_ADDER_Addition TEST");
        self_checker(P,(B + D) * A);
        repeat(2) @(negedge clk);
        $display ("-------------------------");

        /* PRE-ADDER output (Subtraction) */
        A = 18'd1;
        B = 18'd10;
        D = 18'd15;
        OPMODE = 8'b0101_0001; 
        repeat(4) @(negedge clk);
        $display("PRE_ADDER_Subtraction TEST");
        self_checker(P,(D - B));
        repeat(2) @(negedge clk);
        $display ("-------------------------");

        /* MULTIPLIER output */
        A = 18'd3;
        B = 18'd4;
        C = 48'd0;
        D = 18'd0;
        OPMODE = 8'b0000_0001; 
        repeat(4) @(negedge clk);
        $display("MULTIPLIER TEST");
        self_checker(P,(A * B));
        repeat(2) @(negedge clk);
        $display ("-------------------------");        

        /* POST-ADDER output (Addition) */
        A = 18'd5;
        B = 18'd6;
        C = 48'd50;
        OPMODE = 8'b0000_1101; 
        repeat(4) @(negedge clk);
        $display("POST_ADDER_Addition TEST");
        self_checker(P,((A * B) + C));
        repeat(2) @(negedge clk);
        $display ("-------------------------");

        /* POST-ADDER output (Subtraction) */
        A = 18'd8;
        B = 18'd2;
        D = 18'd0;
        C = 48'd50;
        OPMODE = 8'b1010_1101;
        repeat(4) @(negedge clk);
        $display("POST_ADDER_Subtraction TEST");
        self_checker(P,(C - ((A * B) + OPMODE[5])));
        repeat(2) @(negedge clk);
        $display ("-------------------------");

        $display ("END OF SIMULATION");
        $stop;
    end

    /* Self Checking Task */
    task self_checker(input [47:0] out,expected);
        begin
            if(expected != out) begin
                $display("Error: Expected %d, got %d", expected, out);
                $stop;
            end
            else
                $display("Self Checker: Passed"); 
        end
    endtask

    /* Monitor the inputs and outputs */
    /* initial begin
         $monitor("OPMODE = %b,A = %d,B = %d, C = %d, D = %d, P = %d",
                OPMODE, A, B, C, D, P);
    end */
endmodule