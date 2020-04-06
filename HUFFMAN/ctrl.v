module ctrl(
        input                   clk,
        input                   reset,
        input                   gray_valid,
        input                   comp_done,
        input                   comb_done,
        input                   split_done,
        input                   order_done,

        output  reg             comp_en,
        output  reg             comb_en,
        output  reg             order_en,
        output  reg             split_en,
        output  reg             out_en,
        output  reg             CNT_valid
        );

        parameter IDLE = 3'b000,  IN = 3'b001, CNT = 3'b010, ORDER = 3'b011, COMB = 3'b100, SPLIT = 3'b101, COMP = 3'b110, OUT = 3'b111;
        reg [2:0] cstate, nstate;

        // State
        always@(posedge clk, posedge reset)begin
                if(reset)
                        cstate <= IDLE;
                else
                        cstate <= nstate;
        end
        always@*begin
                case(cstate)
                        IDLE:begin
                                if(gray_valid)  // should not affect the accumulation of CNT registers.
                                        nstate = IN;
                                else
                                        nstate = IDLE;
                        end
                        IN:begin
                                if(gray_valid)
                                        nstate = IN;
                                else
                                        nstate = CNT;
                        end
                        CNT: nstate = COMP;
                        ORDER:begin
                                if(comb_done && order_done)
                                        nstate = SPLIT;
                                else if(order_done)
                                        nstate = COMB;
                                else
                                        nstate = ORDER;
                        end
                        COMB: nstate = ORDER;
                        SPLIT:begin
                                if(split_done)
                                        nstate = OUT;
                                else
                                        nstate = SPLIT;
                        end
                        COMP:begin  // design separate ways.
                                if(comp_done)
                                        nstate = COMB;
                                else
                                        nstate = COMP;

                        end
                        OUT: nstate = IDLE;
                        default: nstate = IDLE;
                endcase
        end
        always@*begin
                case(cstate)
                        IDLE:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                        IN:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                        CNT:begin
                                CNT_valid = 1'b1;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                        ORDER:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b1;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                        COMB:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b1;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                        SPLIT:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b1;
                                out_en = 1'b0;
                        end
                        COMP:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b1;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                        OUT:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b1;
                        end
                        default:begin
                                CNT_valid = 1'b0;
                                comp_en = 1'b0;
                                comb_en = 1'b0;
                                order_en = 1'b0;
                                split_en = 1'b0;
                                out_en = 1'b0;
                        end
                endcase
        end
endmodule
