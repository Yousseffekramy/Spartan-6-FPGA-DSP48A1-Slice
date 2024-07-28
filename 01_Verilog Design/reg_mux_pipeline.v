module reg_mux_pipeline #(
    /* This attribute determines if there is register or not
        1 => Registered                 (DEFAULT)
        0 => NO Register                                 */
    parameter REG = 1,

    /* This attribute determines the width of the inputs */
    parameter WIDTH = 18,

    /* It selects whether all resets asynchronous /synchronous 
       "ASYNC"  => Asynchronous
       "SYNC"   => Synchronous                   (DEFAULT)  */    
    parameter RSTTYPE = "SYNC"
) (
    input clk, enable, rst,
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

    generate
        /* Create register and mux */
        if (REG == 1) begin
            reg [WIDTH-1:0] in_r;
            if(RSTTYPE == "ASYNC")
                always @(posedge clk or posedge rst) begin
                    if(rst)
                        in_r <= 0;
                    else if(enable)
                        in_r <= in;
                end
            else if(RSTTYPE == "SYNC")
                always @(posedge clk) begin
                    if(rst)
                        in_r <= 0;
                    else if(enable)
                        in_r <= in;
                end
            assign out = in_r;
        end

        else 
            assign out = in;

    endgenerate

    
endmodule