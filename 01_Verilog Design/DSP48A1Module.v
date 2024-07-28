module DSP48A1Module #(
    /*  A0 and B0 are the first stages of the pipelines
        A1 and B1 are the second stages of the pipelines  */
    parameter A0REG = 0, parameter B0REG = 0, // Default: NO registers
    parameter A1REG = 1, parameter B1REG = 1, // Default: registered
    
    /*  The number defines the number of pipeline stages. */
    // Default : ALL registered
    parameter CREG = 1, parameter DREG = 1,
    parameter MREG = 1, parameter PREG = 1,
    parameter CARRYINREG = 1, parameter CARRYOUTREG = 1,
    parameter OPMODEREG = 1,

    /* The CARRYINSEL attribute is used in carry cascade input 
        "CARRYIN" => the CARRYIN input will be considered 
        "OPMODE5" => the value of opcode[5]      (DEFAULT)
            0     => if none of these string values exist. */
    parameter CARRYINSEL = "OPMODE5",

    /* It defines whether the input to the B port is routed
       "DIRECT"  => routed from the B input      (DEFAULT)
       "CASCADE" => the cascaded input (BCIN) from the previous DSP48A1 slice
            0    => if none of these string values exist.  */
    parameter B_INPUT = "DIRECT",

    /* It selects whether all resets asynchronous /synchronous 
       "ASYNC"  => Asynchronous
       "SYNC"   => Synchronous                   (DEFAULT)  */
    parameter RSTTYPE = "SYNC"
) ( 
    /* Data Ports */
    input [17:0] A, B, D,
    input [47:0] C,
    input CARRYIN,
    output [35:0] M,
    output [47:0] P,
    output CARRYOUT, CARRYOUTF,

    /* Control Input Ports */
    input clk,
    input [7:0] OPMODE,

    /* Clock Enable Input Ports */
    input CEA, CEB, CEC,
    input CED, CEM, CEP,
    input CEOPMODE, CECARRYIN,

    /* Reset Input Ports */
    input RSTA, RSTB, RSTC,
    input RSTD, RSTM, RSTP,
    input RSTOPMODE, RSTCARRYIN,

    /* Cascade Ports */ 
    input [17:0] BCIN,
    output [17:0] BCOUT,
    input [47:0] PCIN, 
    output [47:0] PCOUT
);
    /*  First pipeline stage of inputs 
        instance name in_(name of Input)
        in case we have two stages we add 0 for stage 1 */

    reg [17:0] B0_in;    // Handling the input of B0

    always @(*) begin
        case(B_INPUT)
        "DIRECT": B0_in = B;
        "CASCADE": B0_in = BCIN;
        default: B0_in = 0;
        endcase
    end


    wire [17:0] A0_out, B0_out, D_out; // Outputs of first pipeline stage 
    wire [47:0] C_out; wire [7:0] OPMODE_out;

    reg_mux_pipeline #(.REG(A0REG),.RSTTYPE(RSTTYPE)) in_A0 (.clk(clk),
                                                            .enable(CEA),
                                                            .rst(RSTA),
                                                            .in(A),
                                                            .out(A0_out));

    reg_mux_pipeline #(.REG(B0REG),.RSTTYPE(RSTTYPE)) in_B0 (.clk(clk),
                                                            .enable(CEB),
                                                            .rst(RSTB),
                                                            .in(B0_in),
                                                            .out(B0_out));

    reg_mux_pipeline #(.REG(CREG),.WIDTH(48),.RSTTYPE(RSTTYPE)) in_C (.clk(clk),
                                                                    .enable(CEC),
                                                                    .rst(RSTC),
                                                                    .in(C),
                                                                    .out(C_out));

    reg_mux_pipeline #(.REG(DREG),.RSTTYPE(RSTTYPE)) in_D  (.clk(clk),
                                                            .enable(CED),
                                                            .rst(RSTD),
                                                            .in(D),
                                                            .out(D_out));

    reg_mux_pipeline #(.REG(OPMODEREG),.WIDTH(8),.RSTTYPE(RSTTYPE)) in_OPMODE  (.clk(clk),
                                                                                .enable(CEOPMODE),
                                                                                .rst(RSTOPMODE),
                                                                                .in(OPMODE),
                                                                                .out(OPMODE_out));
    /*  PRE-ADDER/SUBTRACTOR level*/
    wire [17:0] PRE_ADD_SUB_out;
    assign PRE_ADD_SUB_out = (OPMODE_out[6] == 0)? 
                             (D_out + B0_out):
                             (D_out - B0_out);


    /*  Second pipeline stage of inputs 
        instance name in_(name of Input)
        in case we have two stages we add 1 for stage 2 */

    wire [17:0] B1_in;    // Handling the input of B1 
    assign B1_in = (OPMODE_out[4] == 0)? B0_out : PRE_ADD_SUB_out;
    wire [17:0] A1_out, B1_out;

    reg_mux_pipeline #(.REG(A1REG),.RSTTYPE(RSTTYPE)) in_A1 (.clk(clk),
                                                            .enable(CEA),
                                                            .rst(RSTA),
                                                            .in(A0_out),
                                                            .out(A1_out));

    reg_mux_pipeline #(.REG(B1REG),.RSTTYPE(RSTTYPE)) in_B1 (.clk(clk),
                                                            .enable(CEB),
                                                            .rst(RSTB),
                                                            .in(B1_in),
                                                            .out(B1_out));
    
    assign BCOUT = B1_out;

    /* MULTIPLIER level */
    wire [35:0] Multiplier_out;
    assign Multiplier_out = A1_out * B1_out;

    wire [35:0] M_out;

    reg_mux_pipeline #(.REG(MREG),.WIDTH(36),.RSTTYPE(RSTTYPE)) in_M (.clk(clk),
                                                                    .enable(CEM),
                                                                    .rst(RSTM),
                                                                    .in(Multiplier_out),
                                                                    .out(M_out));
                    
    assign M = M_out; //Buffered M Output

    /* MUX X level */
    reg [47:0] X_out;
    wire [47:0] P_out;
    always @(*) begin
        case (OPMODE_out[1:0])
            0: X_out = 0;  // disable the post-adder/subtracter and propagate the MUX Z result to P
            1: X_out = {{12{1'b0}},M_out}; // Use the multiplier product
            2: X_out = P_out;   // Use the P output signal (accumulator)
            3: X_out = {D_out[11:0],A1_out[17:0],B1_out[17:0]}; // Use the concatenated D:A:B input signals
        endcase
    end

    /* MUX Z level */
    reg [47:0] Z_out;
    always @(*) begin
        case (OPMODE_out[3:2])
            0: Z_out = 0; //disable the post-adder/subtracter and propagate the multiplier product or other X result to P)
            1: Z_out = PCIN;
            2: Z_out = P_out;
            3: Z_out = C_out;
        endcase
    end

    /* CARRYIN POST ADDER/SUBTRACTOR level */
    reg CYI_in;
    wire CYI_out;
    
    always @(*) begin
        case (CARRYINSEL)
            "CARRYIN": CYI_in = CARRYIN;
            "OPMODE5": CYI_in = OPMODE_out[5];
            default: CYI_in = 0;
        endcase
    end

    reg_mux_pipeline #(.REG(CARRYINREG),.WIDTH(1),.RSTTYPE(RSTTYPE)) in_CYI(.clk(clk),
                                                                            .enable(CECARRYIN),
                                                                            .rst(RSTCARRYIN),
                                                                            .in(CYI_in),
                                                                            .out(CYI_out));

    /*  POST-ADDER/SUBTRACTOR level*/
    wire [47:0] POST_ADD_SUB_out;
    wire CYO_in,CYO_out;
    assign {CYO_in,POST_ADD_SUB_out} =  (OPMODE_out[7] == 0)? 
                                        (Z_out + X_out + CYI_out):
                                        (Z_out - (X_out + CYI_out));
    
    /* P pipeline register */

    reg_mux_pipeline #(.REG(PREG),.WIDTH(48),.RSTTYPE(RSTTYPE)) in_P(.clk(clk),
                                                                    .enable(CEP),
                                                                    .rst(RSTP),
                                                                    .in(POST_ADD_SUB_out),
                                                                    .out(P_out));

    assign P = P_out; assign PCOUT = P_out;

    /* CARRYOUT POST ADDER/SUBTRACTOR level */
    reg_mux_pipeline #(.REG(CARRYOUTREG),.WIDTH(1),.RSTTYPE(RSTTYPE)) in_CYO(.clk(clk),
                                                                            .enable(CECARRYIN),
                                                                            .rst(RSTCARRYIN),
                                                                            .in(CYO_in),
                                                                            .out(CYO_out));

    assign CARRYOUT = CYO_out; assign CARRYOUTF = CYO_out;                                                         
endmodule

