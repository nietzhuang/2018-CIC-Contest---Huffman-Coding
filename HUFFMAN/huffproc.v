module huffproc(
        input                   clk,
        input                   reset,
        input                   gray_valid,
        input   [7:0]           gray_data,
        input                   CNT_valid,
        input                   comp_en,
        input                   comb_en,
        input                   order_en,
        input                   split_en,
        input                   out_en,

        output  reg [7:0]       CNT1,
        output  reg [7:0]       CNT2,
        output  reg [7:0]       CNT3, 
        output  reg [7:0]       CNT4,
        output  reg [7:0]       CNT5,
        output  reg [7:0]       CNT6,
        output  reg             code_valid,
        output  reg             comp_done,
        output  reg             comb_done,
        output  reg             split_done,
        output  reg             order_done, 
        output  reg [7:0]       HC1,
        output  reg [7:0]       HC2, 
        output  reg [7:0]       HC3,
        output  reg [7:0]       HC4,
        output  reg [7:0]       HC5,
        output  reg [7:0]       HC6,
        output  reg [7:0]       M1,
        output  reg [7:0]       M2,
        output  reg [7:0]       M3, 
        output  reg [7:0]       M4,
        output  reg [7:0]       M5,
        output  reg [7:0]       M6
        );

        reg [7:0]       CNTA1, CNTA2, CNTA3, CNTA4, CNTA5, CNTA6;
        reg [11:0]      comp0, comp1, comp2, comp3, comp4, comp5;
        reg [2:0]       cnt_comp;
        reg [2:0]       cnt_comb;
        reg [2:0]       cnt_split;
        reg [2:0]       cnt_order;
        reg             flag_split;
        reg [39:0]      C0, C1, C2, C3, C4, C5;
        reg [55:0]      S0, S1, S2, S3, S4, S5;
        wire [7:0]      PC0, PC1, PC2, PC3, PC4, PC5;
        reg [39:0]      SC0 [5:0];
        reg [39:0]      SC1 [4:0];
        reg [39:0]      SC2 [3:0];
        reg [39:0]      SC3 [2:0];

        integer i;


        // CNT count
        always@(posedge clk, posedge reset)begin
                if(reset)begin
                        CNTA1 <= 8'd0;
                        CNTA2 <= 8'd0;
                        CNTA3 <= 8'd0;
                        CNTA4 <= 8'd0;
                        CNTA5 <= 8'd0;
                        CNTA6 <= 8'd0;
                end
                else if(gray_valid)begin  // the first time of accumulation would be at IDLE state.
                        case(gray_data)
                                8'h01: CNTA1 <= CNTA1 + 1;
                                8'h02: CNTA2 <= CNTA2 + 1;
                                8'h03: CNTA3 <= CNTA3 + 1;
                                8'h04: CNTA4 <= CNTA4 + 1;
                                8'h05: CNTA5 <= CNTA5 + 1;
                                8'h06: CNTA6 <= CNTA6 + 1;
                                //default:
                        endcase
                end
        end

        //  CNT output
        always@*begin
                if((!gray_valid) && (CNT_valid))begin
                        CNT1 = CNTA1;
                        CNT2 = CNTA2;
                        CNT3 = CNTA3;
                        CNT4 = CNTA4;
                        CNT5 = CNTA5;
                        CNT6 = CNTA6;
                end
                else begin
                        CNT1 = 8'd0;
                        CNT2 = 8'd0;
                        CNT3 = 8'd0;
                        CNT4 = 8'd0;
                        CNT5 = 8'd0;
                        CNT6 = 8'd0;
                end
        end

        // Comparison counter
        always@(posedge clk, posedge reset)begin
                if(reset)
                        cnt_comp <= 3'd0;
                else if(comp_en)
                        cnt_comp <= cnt_comp + 1;
                else
                        cnt_comp <= 3'd0;
        end
        always@(posedge clk, posedge reset)begin
                if(reset)
                        comp_done <= 1'b0;
                else if(cnt_comp == 3'd5)  // while the sort is done.
                        comp_done <= 1'b1;
                else if(cnt_comp == 3'd6)  // asserted only one cycle.
                        comp_done <= 1'b0;
        end

        // Comparison
        always@(posedge clk, posedge reset)begin
                if(reset)begin
                        comp0 <= 12'b0;
                        comp1 <= 12'b0;
                        comp2 <= 12'b0;
                        comp3 <= 12'b0;
                        comp4 <= 12'b0;
                        comp5 <= 12'b0;
                end
                else if(CNT_valid)begin  // condition for 1st comparation, composed of synbol data.
                        comp0 <= {4'd1, CNTA1};
                        comp1 <= {4'd2, CNTA2};
                        comp2 <= {4'd3, CNTA3};
                        comp3 <= {4'd4, CNTA4};
                        comp4 <= {4'd5, CNTA5};
                        comp5 <= {4'd6, CNTA6};
                end
                else if(comp_en)begin
                        if(cnt_comp[0] == 1'b0)begin
                                comp0 <= (comp0[7:0]>=comp1[7:0])? comp0:comp1;
                                comp1 <= (comp0[7:0]>=comp1[7:0])? comp1:comp0;
                                comp2 <= (comp2[7:0]>=comp3[7:0])? comp2:comp3;
                                comp3 <= (comp2[7:0]>=comp3[7:0])? comp3:comp2;
                                comp4 <= (comp4[7:0]>=comp5[7:0])? comp4:comp5;
                                comp5 <= (comp4[7:0]>=comp5[7:0])? comp5:comp4;
                        end
                        else if(cnt_comp[0] == 1'b1)begin
                                comp1 <= (comp1[7:0]>=comp2[7:0])? comp1:comp2;
                                comp2 <= (comp1[7:0]>=comp2[7:0])? comp2:comp1;
                                comp3 <= (comp3[7:0]>=comp4[7:0])? comp3:comp4;
                                comp4 <= (comp3[7:0]>=comp4[7:0])? comp4:comp3;
                        end
                end
        end


        // Combination counter
        always@(posedge clk, posedge reset)begin
                if(reset)
                        cnt_comb <= 3'b0;
                else if(comb_en)
                        cnt_comb <= cnt_comb + 1;
                else if(cnt_comb == 3'd4)
                        cnt_comb <= 3'd0;
        end
        always@(posedge clk, posedge reset)begin
                if(reset)
                        comb_done <= 1'b0;
                else if(cnt_comb == 3'd4)
                        comb_done <= 1'b1;
        end

        // Ordering counter
        always@(posedge clk, posedge reset)begin
                if(reset)
                        cnt_order <= 'd0;
                else if(order_en)
                        cnt_order <= cnt_order + 1;
        end
        always@*begin
                order_done = (cnt_order == 'd6);
        end
        assign PC0 = (C0[39:32]+C0[31:24]+C0[23:16]+C0[15:8]+C0[7:0]);
        assign PC1 = (C1[39:32]+C1[31:24]+C1[23:16]+C1[15:8]+C1[7:0]);
        assign PC2 = (C2[39:32]+C2[31:24]+C2[23:16]+C2[15:8]+C2[7:0]);
        assign PC3 = (C3[39:32]+C3[31:24]+C3[23:16]+C3[15:8]+C3[7:0]);
        assign PC4 = (C4[39:32]+C4[31:24]+C4[23:16]+C4[15:8]+C4[7:0]);
        assign PC5 = (C5[39:32]+C5[31:24]+C5[23:16]+C5[15:8]+C5[7:0]);

        // Combination and Ordering
        always@(posedge clk, posedge reset)begin
                if(reset)begin
                        C0 <= 40'b0;
                        C1 <= 40'b0;
                        C2 <= 40'b0;
                        C3 <= 40'b0;
                        C4 <= 40'b0;
                        C5 <= 40'b0;
                end
                else if(comp_done)begin
                        C0 <= comp0[7:0];
                        C1 <= comp1[7:0];
                        C2 <= comp2[7:0];
                        C3 <= comp3[7:0];
                        C4 <= comp4[7:0];
                        C5 <= comp5[7:0];
                end
                else if(comb_en)begin  // There's a probable case that it combines with two regs enclosed than one data.
                        case(cnt_comb) 
                                2'b00:begin
                                        C4 <= (C4 << 8) + C5;
                                        C5 <= 40'b0;
                                end
                                2'b01:begin
                                        C3 <= (C4[15:8] == 8'd0)? (C3<<8)+C4:(C3<<16)+C4;
                                        C4 <= 40'b0;
                                end
                                2'b10:begin
                                        C2 <= (C3[15:8] == 8'd0)? (C2<<8)+C3:
                                              (C3[23:16]== 8'd0)? (C2<<16)+C3:(C2<<24)+C3;
                                        C3 <= 40'b0;
                                end
                                2'b11:begin
                                        C1 <= (C2[15:8] ==  8'd0)? (C1<<8)+C2:
                                              (C2[23:16]==  8'd0)? (C1<<16)+C2:
                                              (C2[31:24]==  8'd0)? (C1<<24)+C2:(C1<<32)+C2;
                                        C2 <= 40'b0;
                                end
                        endcase
                end
                else if(order_en)begin
                        if(cnt_order[0] == 1'b0)begin
                                C0 <= (PC0>=PC1)? C0:C1;
                                C1 <= (PC0>=PC1)? C1:C0;
                                C2 <= (PC2>=PC3)? C2:C3;
                                C3 <= (PC2>=PC3)? C3:C2;
                                C4 <= (PC4>=PC5)? C4:C5;
                                C5 <= (PC4>=PC5)? C5:C4;
                        end
                        else begin
                                C1 <= (PC1>=PC2)? C1:C2;
                                C2 <= (PC1>=PC2)? C2:C1;
                                C3 <= (PC3>=PC4)? C3:C4;
                                C4 <= (PC3>=PC4)? C4:C3;
                        end
                end
        end


        // Split counter
        always@(posedge clk, posedge reset)begin
                if(reset)
                        cnt_split <= 3'd0;
                else if(split_en && flag_split)
                        cnt_split <= cnt_split + 1;
                else if((cnt_split == 3'd4) && flag_split)
                        cnt_split <= 3'd0;

        end
        always@(posedge clk, posedge reset)begin
                if(reset)
                        flag_split <= 1'b0;
                else if(split_en)
                        flag_split <= ~flag_split;
        end
        always@(posedge clk, posedge reset)begin
                if(reset)
                        split_done <= 1'b0;
                else if(cnt_split == 3'b100)
                        split_done <= 1'b1;
                else
                        split_done <= 1'b0;
        end

        // Combination results Saving
        always@(posedge clk, posedge reset)begin
                if(reset)begin
                        for(i=0; i <= 5; i = i + 1)
                                SC0[i] <= 40'b0;
                        for(i=0; i <= 4; i = i + 1)
                                SC1[i] <= 40'b0;
                        for(i=0; i <= 3; i = i + 1)
                                SC2[i] <= 40'b0;
                        for(i=0; i <= 2; i = i + 1)
                                SC3[i] <= 40'b0;
                end
                else if((cnt_comb == 3'b0)&&comb_en)begin  // Save C0 values.
                        SC0[0] <= C0;
                        SC0[1] <= C1;
                        SC0[2] <= C2;
                        SC0[3] <= C3;
                        SC0[4] <= C4;
                        SC0[5] <= C5;
                end
                else if(order_done)begin  // Save C1 to C3 values.
                        case(cnt_comb)
                                3'b001:begin
                                        SC1[0] <= C0;
                                        SC1[1] <= C1;
                                        SC1[2] <= C2;
                                        SC1[3] <= C3;
                                        SC1[4] <= C4;
                                end
                                3'b010:begin
                                        SC2[0] <= C0;
                                        SC2[1] <= C1;
                                        SC2[2] <= C2;
                                        SC2[3] <= C3;
                                end
                                3'b011:begin
                                        SC3[0] <= C0;
                                        SC3[1] <= C1;
                                        SC3[2] <= C2;
                                end
                        endcase
                end
        end

        // Split
        always@(posedge clk, posedge reset)begin
                if(reset)begin
                        S0 <= 56'b0;  // [55:48] save number of mask bits. [47:40] is mask bit.
                        S1 <= 56'b0;
                        S2 <= 56'b0;
                        S3 <= 56'b0;
                        S4 <= 56'b0;
                        S5 <= 56'b0;
                end
                else if(comb_done && order_done)begin
                        S0 <= C0;
                        S1 <= C1;
                end
                else if(split_en)begin
                        case(cnt_split)
                                3'b000:begin
                                        if(!flag_split)begin  // Give Huffman code.
                                                S0[47:40] <= 8'b0000_0000;
                                                S1[47:40] <= 8'b0000_0001;
                                                S0[55:48] <= (S0[55:48]<<1) + 8'b1;  // Add mask bit.
                                                S1[55:48] <= (S1[55:48]<<1) + 8'b1;
                                        end
                                        else begin  // Split, arrange Huffman code and mask bit.
                                                S0[39:0] <= SC3[0];
                                                S1[39:0] <= SC3[1];
                                                S2[39:0] <= SC3[2];
                                                S0[55:40] <= (S0[39:0]==SC3[0])? S0[55:40]:S1[55:40];
                                                S1[55:40] <= (S0[39:0]==SC3[0])? S1[55:40]:S0[55:40];
                                                S2[55:40] <= (S0[39:0]==SC3[0])? S1[55:40]:S0[55:40];
                                        end
                                end
                                3'b001:begin
                                        if(!flag_split)begin
                                                S1[47:40] <= (S1[47:40]<<1) + 8'b0;
                                                S2[47:40] <= (S1[47:40]<<1) + 8'b1;
                                                S1[55:48] <= (S1[55:48]<<1) + 8'b1;
                                                S2[55:48] <= (S2[55:48]<<1) + 8'b1;
                                        end
                                        else begin  // C3 -> C2.
                                                S1[39:0] <= SC2[1];
                                                S2[39:0] <= SC2[2];
                                                S3[39:0] <= SC2[3];
                                                S1[55:40] <= (S1[39:0]==SC2[1])? S1[55:40]:S2[55:40];
                                                S2[55:40] <= (S1[39:0]==SC2[1])? S2[55:40]:S1[55:40];
                                                S3[55:40] <= (S1[39:0]==SC2[1])? S2[55:40]:S1[55:40];
                                        end
                                end
                                3'b010:begin  // C2 -> C1.
                                        if(!flag_split)begin
                                                S2[47:40] <= (S2[47:40]<<1)+8'b0;
                                                S3[47:40] <= (S3[47:40]<<1)+8'b1;
                                                S2[55:48] <= (S2[55:48]<<1)+8'b1;
                                                S3[55:48] <= (S3[55:48]<<1)+8'b1;
                                        end
                                        else begin
                                                S2[39:0] <= SC1[2];
                                                S3[39:0] <= SC1[3];
                                                S4[39:0] <= SC1[4];
                                                S2[55:40] <= (S2[39:0]==SC1[2])? S2[55:40]:S3[55:40];
                                                S3[55:40] <= (S2[39:0]==SC1[2])? S3[55:40]:S2[55:40];
                                                S4[55:40] <= (S2[39:0]==SC1[2])? S3[55:40]:S2[55:40];
                                        end
                                end
                                3'b011:begin  // C1 -> C0.
                                        if(!flag_split)begin
                                                S3[47:40] <= (S3[47:40]<<1)+8'b0;
                                                S4[47:40] <= (S4[47:40]<<1)+8'b1;
                                                S3[55:48] <= (S3[55:48]<<1)+8'b1;
                                                S4[55:48] <= (S4[55:48]<<1)+8'b1;
                                        end
                                        else begin
                                                S2[39:0] <= SC0[2];
                                                S3[39:0] <= SC0[3];
                                                S4[39:0] <= SC0[4];
                                                S5[39:0] <= SC0[5];
                                                if(S2[39:0]== SC0[2])begin
                                                        S3[55:40] <= (S3[39:0]==SC0[3])? S3[55:40]:S2[55:40];
                                                        S4[55:40] <= (S3[39:0]==SC0[3])? S4[55:40]:S3[55:40];
                                                        S5[55:40] <= (S3[39:0]==SC0[3])? S4[55:40]:S3[55:40];
                                                end
                                                else begin  // S2 Swap
                                                        S2[55:40] <= S3[55:40];
                                                        S3[55:40] <= S4[55:40];
                                                        S4[55:40] <= S2[55:40];
                                                        S5[55:40] <= S2[55:40];
                                                end
                                        end
                                end
                                3'b100:begin  // C0 ending.
                                if(!flag_split)begin
                                                S4[47:40] <= (S4[47:40]<<1)+8'b0;
                                                S5[47:40] <= (S5[47:40]<<1)+8'b1;
                                                S4[55:48] <= (S4[55:48]<<1)+8'b1;
                                                S5[55:48] <= (S5[55:48]<<1)+8'b1;
                                        end
                                end
                        endcase
                end
        end


        // Output
        always@(posedge clk, posedge reset)begin
                if(reset)
                        code_valid <= 1'b0;
                else if(out_en)
                        code_valid <= 1'b1;
                else
                        code_valid <= 1'b0;
        end
        always@(posedge clk, posedge reset)begin
                if(reset)begin
                        HC1 <= 8'b0;
                        HC2 <= 8'b0;
                        HC3 <= 8'b0;
                        HC4 <= 8'b0;
                        HC5 <= 8'b0;
                        HC6 <= 8'b0;
                        M1 <= 8'b0;
                        M2 <= 8'b0;
                        M3 <= 8'b0;
                        M4 <= 8'b0;
                        M5 <= 8'b0;
                        M6 <= 8'b0;
                end
                else if(out_en)begin
                        case(comp0[11:8])
                                4'h1:begin
                                        case(comp0[7:0])
                                                S0[7:0]: {M1, HC1} <= S0[55:40];
                                                S1[7:0]: {M1, HC1} <= S1[55:40];
                                                S2[7:0]: {M1, HC1} <= S2[55:40];
                                                S3[7:0]: {M1, HC1} <= S3[55:40];
                                                S4[7:0]: {M1, HC1} <= S4[55:40];
                                                S5[7:0]: {M1, HC1} <= S5[55:40];
                                        endcase
                                end
                                4'h2:begin
                                        case(comp0[7:0])
                                                S0[7:0]: {M2, HC2} <= S0[55:40];
                                                S1[7:0]: {M2, HC2} <= S1[55:40];
                                                S2[7:0]: {M2, HC2} <= S2[55:40];
                                                S3[7:0]: {M2, HC2} <= S3[55:40];
                                                S4[7:0]: {M2, HC2} <= S4[55:40];
                                                S5[7:0]: {M2, HC2} <= S5[55:40];
                                        endcase
                                end
                                4'h3:begin
                                        case(comp0[7:0])
                                                S0[7:0]: {M3, HC3} <= S0[55:40];
                                                S1[7:0]: {M3, HC3} <= S1[55:40];
                                                S2[7:0]: {M3, HC3} <= S2[55:40];
                                                S3[7:0]: {M3, HC3} <= S3[55:40];
                                                S4[7:0]: {M3, HC3} <= S4[55:40];
                                                S5[7:0]: {M3, HC3} <= S5[55:40];
                                        endcase
                                end
                                4'h4:begin
                                        case(comp0[7:0])
                                                S0[7:0]: {M4, HC4} <= S0[55:40];
                                                S1[7:0]: {M4, HC4} <= S1[55:40];
                                                S2[7:0]: {M4, HC4} <= S2[55:40];
                                                S3[7:0]: {M4, HC4} <= S3[55:40];
                                                S4[7:0]: {M4, HC4} <= S4[55:40];
                                                S5[7:0]: {M4, HC4} <= S5[55:40];
                                        endcase
                                end
                                4'h5:begin
                                        case(comp0[7:0])
                                                S0[7:0]: {M5, HC5} <= S0[55:40];
                                                S1[7:0]: {M5, HC5} <= S1[55:40];
                                                S2[7:0]: {M5, HC5} <= S2[55:40];
                                                S3[7:0]: {M5, HC5} <= S3[55:40];
                                                S4[7:0]: {M5, HC5} <= S4[55:40];
                                                S5[7:0]: {M5, HC5} <= S5[55:40];
                                        endcase
                                end
                                4'h6:begin
                                        case(comp0[7:0])
                                                S0[7:0]: {M6, HC6} <= S0[55:40];
                                                S1[7:0]: {M6, HC6} <= S1[55:40];
                                                S2[7:0]: {M6, HC6} <= S2[55:40];
                                                S3[7:0]: {M6, HC6} <= S3[55:40];
                                                S4[7:0]: {M6, HC6} <= S4[55:40];
                                                S5[7:0]: {M6, HC6} <= S5[55:40];
                                        endcase
                                end
                        endcase
                        case(comp1[11:8])
                                4'h1:begin
                                        case(comp1[7:0])
                                                S0[7:0]: {M1, HC1} <= S0[55:40];
                                                S1[7:0]: {M1, HC1} <= S1[55:40];
                                                S2[7:0]: {M1, HC1} <= S2[55:40];
                                                S3[7:0]: {M1, HC1} <= S3[55:40];
                                                S4[7:0]: {M1, HC1} <= S4[55:40];
                                                S5[7:0]: {M1, HC1} <= S5[55:40];
                                        endcase
                                end
                                4'h2:begin
                                        case(comp1[7:0])
                                                S0[7:0]: {M2, HC2} <= S0[55:40];
                                                S1[7:0]: {M2, HC2} <= S1[55:40];
                                                S2[7:0]: {M2, HC2} <= S2[55:40];
                                                S3[7:0]: {M2, HC2} <= S3[55:40];
                                                S4[7:0]: {M2, HC2} <= S4[55:40];
                                                S5[7:0]: {M2, HC2} <= S5[55:40];
                                        endcase
                                end
                                4'h3:begin
                                        case(comp1[7:0])
                                                S0[7:0]: {M3, HC3} <= S0[55:40];
                                                S1[7:0]: {M3, HC3} <= S1[55:40];
                                                S2[7:0]: {M3, HC3} <= S2[55:40];
                                                S3[7:0]: {M3, HC3} <= S3[55:40];
                                                S4[7:0]: {M3, HC3} <= S4[55:40];
                                                S5[7:0]: {M3, HC3} <= S5[55:40];
                                        endcase
                                end
                                4'h4:begin
                                        case(comp1[7:0])
                                                S0[7:0]: {M4, HC4} <= S0[55:40];
                                                S1[7:0]: {M4, HC4} <= S1[55:40];
                                                S2[7:0]: {M4, HC4} <= S2[55:40];
                                                S3[7:0]: {M4, HC4} <= S3[55:40];
                                                S4[7:0]: {M4, HC4} <= S4[55:40];
                                                S5[7:0]: {M4, HC4} <= S5[55:40];
                                        endcase
                                end
                                4'h5:begin
                                        case(comp1[7:0])
                                                S0[7:0]: {M5, HC5} <= S0[55:40];
                                                S1[7:0]: {M5, HC5} <= S1[55:40];
                                                S2[7:0]: {M5, HC5} <= S2[55:40];
                                                S3[7:0]: {M5, HC5} <= S3[55:40];
                                                S4[7:0]: {M5, HC5} <= S4[55:40];
                                                S5[7:0]: {M5, HC5} <= S5[55:40];
                                        endcase
                                end
                                4'h6:begin
                                        case(comp1[7:0])
                                                S0[7:0]: {M6, HC6} <= S0[55:40];
                                                S1[7:0]: {M6, HC6} <= S1[55:40];
                                                S2[7:0]: {M6, HC6} <= S2[55:40];
                                                S3[7:0]: {M6, HC6} <= S3[55:40];
                                                S4[7:0]: {M6, HC6} <= S4[55:40];
                                                S5[7:0]: {M6, HC6} <= S5[55:40];
                                        endcase
                                end
                        endcase
                        case(comp2[11:8])
                                4'h1:begin
                                        case(comp2[7:0])
                                                S0[7:0]: {M1, HC1} <= S0[55:40];
                                                S1[7:0]: {M1, HC1} <= S1[55:40];
                                                S2[7:0]: {M1, HC1} <= S2[55:40];
                                                S3[7:0]: {M1, HC1} <= S3[55:40];
                                                S4[7:0]: {M1, HC1} <= S4[55:40];
                                                S5[7:0]: {M1, HC1} <= S5[55:40];
                                        endcase
                                end
                                4'h2:begin
                                        case(comp2[7:0])
                                                S0[7:0]: {M2, HC2} <= S0[55:40];
                                                S1[7:0]: {M2, HC2} <= S1[55:40];
                                                S2[7:0]: {M2, HC2} <= S2[55:40];
                                                S3[7:0]: {M2, HC2} <= S3[55:40];
                                                S4[7:0]: {M2, HC2} <= S4[55:40];
                                                S5[7:0]: {M2, HC2} <= S5[55:40];
                                        endcase
                                end
                                4'h3:begin
                                        case(comp2[7:0])
                                                S0[7:0]: {M3, HC3} <= S0[55:40];
                                                S1[7:0]: {M3, HC3} <= S1[55:40];
                                                S2[7:0]: {M3, HC3} <= S2[55:40];
                                                S3[7:0]: {M3, HC3} <= S3[55:40];
                                                S4[7:0]: {M3, HC3} <= S4[55:40];
                                                S5[7:0]: {M3, HC3} <= S5[55:40];
                                        endcase
                                end
                                4'h4:begin
                                        case(comp2[7:0])
                                                S0[7:0]: {M4, HC4} <= S0[55:40];
                                                S1[7:0]: {M4, HC4} <= S1[55:40];
                                                S2[7:0]: {M4, HC4} <= S2[55:40];
                                                S3[7:0]: {M4, HC4} <= S3[55:40];
                                                S4[7:0]: {M4, HC4} <= S4[55:40];
                                                S5[7:0]: {M4, HC4} <= S5[55:40];
                                        endcase
                                end
                                4'h5:begin
                                        case(comp2[7:0])
                                                S0[7:0]: {M5, HC5} <= S0[55:40];
                                                S1[7:0]: {M5, HC5} <= S1[55:40];
                                                S2[7:0]: {M5, HC5} <= S2[55:40];
                                                S3[7:0]: {M5, HC5} <= S3[55:40];
                                                S4[7:0]: {M5, HC5} <= S4[55:40];
                                                S5[7:0]: {M5, HC5} <= S5[55:40];
                                        endcase
                                end
                                4'h6:begin
                                        case(comp2[7:0])
                                                S0[7:0]: {M6, HC6} <= S0[55:40];
                                                S1[7:0]: {M6, HC6} <= S1[55:40];
                                                S2[7:0]: {M6, HC6} <= S2[55:40];
                                                S3[7:0]: {M6, HC6} <= S3[55:40];
                                                S4[7:0]: {M6, HC6} <= S4[55:40];
                                                S5[7:0]: {M6, HC6} <= S5[55:40];
                                        endcase
                                end
                        endcase
                        case(comp3[11:8])
                                4'h1:begin
                                        case(comp3[7:0])
                                                S0[7:0]: {M1, HC1} <= S0[55:40];
                                                S1[7:0]: {M1, HC1} <= S1[55:40];
                                                S2[7:0]: {M1, HC1} <= S2[55:40];
                                                S3[7:0]: {M1, HC1} <= S3[55:40];
                                                S4[7:0]: {M1, HC1} <= S4[55:40];
                                                S5[7:0]: {M1, HC1} <= S5[55:40];
                                        endcase
                                end
                                4'h2:begin
                                        case(comp3[7:0])
                                                S0[7:0]: {M2, HC2} <= S0[55:40];
                                                S1[7:0]: {M2, HC2} <= S1[55:40];
                                                S2[7:0]: {M2, HC2} <= S2[55:40];
                                                S3[7:0]: {M2, HC2} <= S3[55:40];
                                                S4[7:0]: {M2, HC2} <= S4[55:40];
                                                S5[7:0]: {M2, HC2} <= S5[55:40];
                                        endcase
                                end
                                4'h3:begin
                                        case(comp3[7:0])
                                                S0[7:0]: {M3, HC3} <= S0[55:40];
                                                S1[7:0]: {M3, HC3} <= S1[55:40];
                                                S2[7:0]: {M3, HC3} <= S2[55:40];
                                                S3[7:0]: {M3, HC3} <= S3[55:40];
                                                S4[7:0]: {M3, HC3} <= S4[55:40];
                                                S5[7:0]: {M3, HC3} <= S5[55:40];
                                        endcase
                                end
                                4'h4:begin
                                                S3[7:0]: {M4, HC4} <= S3[55:40];  // Same value 'a' makes HC4 transfering wrong;
                                                S0[7:0]: {M4, HC4} <= S0[55:40];
                                                S1[7:0]: {M4, HC4} <= S1[55:40];
                                                S2[7:0]: {M4, HC4} <= S2[55:40];
                                                //S3[7:0]: {M4, HC4} <= S3[55:40];
                                                S4[7:0]: {M4, HC4} <= S4[55:40];
                                                S5[7:0]: {M4, HC4} <= S5[55:40];
                                        endcase
                                end
                                4'h5:begin
                                        case(comp3[7:0])
                                                S0[7:0]: {M5, HC5} <= S0[55:40];
                                                S1[7:0]: {M5, HC5} <= S1[55:40];
                                                S2[7:0]: {M5, HC5} <= S2[55:40];
                                                S3[7:0]: {M5, HC5} <= S3[55:40];
                                                S4[7:0]: {M5, HC5} <= S4[55:40];
                                                S5[7:0]: {M5, HC5} <= S5[55:40];
                                        endcase
                                end
                                4'h6:begin
                                        case(comp3[7:0])
                                                S0[7:0]: {M6, HC6} <= S0[55:40];
                                                S1[7:0]: {M6, HC6} <= S1[55:40];
                                                S2[7:0]: {M6, HC6} <= S2[55:40];
                                                S3[7:0]: {M6, HC6} <= S3[55:40];
                                                S4[7:0]: {M6, HC6} <= S4[55:40];
                                                S5[7:0]: {M6, HC6} <= S5[55:40];
                                        endcase
                                end
                        endcase
                        case(comp4[11:8])
                                4'h1:begin
                                        case(comp4[7:0])
                                                S0[7:0]: {M1, HC1} <= S0[55:40];
                                                S1[7:0]: {M1, HC1} <= S1[55:40];
                                                S2[7:0]: {M1, HC1} <= S2[55:40];
                                                S3[7:0]: {M1, HC1} <= S3[55:40];
                                                S4[7:0]: {M1, HC1} <= S4[55:40];
                                                S5[7:0]: {M1, HC1} <= S5[55:40];
                                        endcase
                                end
                                4'h2:begin
                                        case(comp4[7:0])
                                                S0[7:0]: {M2, HC2} <= S0[55:40];
                                                S1[7:0]: {M2, HC2} <= S1[55:40];
                                                S2[7:0]: {M2, HC2} <= S2[55:40];
                                                S3[7:0]: {M2, HC2} <= S3[55:40];
                                                S4[7:0]: {M2, HC2} <= S4[55:40];
                                                S5[7:0]: {M2, HC2} <= S5[55:40];
                                        endcase
                                end
                                4'h3:begin
                                        case(comp4[7:0])
                                                S0[7:0]: {M3, HC3} <= S0[55:40];
                                                S1[7:0]: {M3, HC3} <= S1[55:40];
                                                S2[7:0]: {M3, HC3} <= S2[55:40];
                                                S3[7:0]: {M3, HC3} <= S3[55:40];
                                                S4[7:0]: {M3, HC3} <= S4[55:40];
                                                S5[7:0]: {M3, HC3} <= S5[55:40];
                                        endcase
                                end
                                4'h4:begin
                                        case(comp4[7:0])
                                        S0[7:0]: {M4, HC4} <= S0[55:40];
                                                S1[7:0]: {M4, HC4} <= S1[55:40];
                                                S2[7:0]: {M4, HC4} <= S2[55:40];
                                                S3[7:0]: {M4, HC4} <= S3[55:40];
                                                S4[7:0]: {M4, HC4} <= S4[55:40];
                                                S5[7:0]: {M4, HC4} <= S5[55:40];
                                        endcase
                                end
                                4'h5:begin
                                        case(comp4[7:0])
                                                S0[7:0]: {M5, HC5} <= S0[55:40];
                                                S1[7:0]: {M5, HC5} <= S1[55:40];
                                                S2[7:0]: {M5, HC5} <= S2[55:40];
                                                S3[7:0]: {M5, HC5} <= S3[55:40];
                                                S4[7:0]: {M5, HC5} <= S4[55:40];
                                                S5[7:0]: {M5, HC5} <= S5[55:40];
                                        endcase
                                end
                                4'h6:begin
                                        case(comp4[7:0])
                                                S0[7:0]: {M6, HC6} <= S0[55:40];
                                                S1[7:0]: {M6, HC6} <= S1[55:40];
                                                S2[7:0]: {M6, HC6} <= S2[55:40];
                                                S3[7:0]: {M6, HC6} <= S3[55:40];
                                                S4[7:0]: {M6, HC6} <= S4[55:40];
                                                S5[7:0]: {M6, HC6} <= S5[55:40];
                                        endcase
                                end
                        endcase
                        case(comp5[11:8])
                                4'h1:begin
                                        case(comp5[7:0])
                                                S0[7:0]: {M1, HC1} <= S0[55:40];
                                                S1[7:0]: {M1, HC1} <= S1[55:40];
                                                S2[7:0]: {M1, HC1} <= S2[55:40];
                                                S3[7:0]: {M1, HC1} <= S3[55:40];
                                                S4[7:0]: {M1, HC1} <= S4[55:40];
                                                S5[7:0]: {M1, HC1} <= S5[55:40];
                                        endcase
                                end
                                4'h2:begin
                                        case(comp5[7:0])
                                                S0[7:0]: {M2, HC2} <= S0[55:40];
                                                S1[7:0]: {M2, HC2} <= S1[55:40];
                                                S2[7:0]: {M2, HC2} <= S2[55:40];
                                                S3[7:0]: {M2, HC2} <= S3[55:40];
                                                S4[7:0]: {M2, HC2} <= S4[55:40];
                                                S5[7:0]: {M2, HC2} <= S5[55:40];
                                        endcase
                                end
                                4'h3:begin
                                        case(comp5[7:0])
                                                S0[7:0]: {M3, HC3} <= S0[55:40];
                                                S1[7:0]: {M3, HC3} <= S1[55:40];
                                                S2[7:0]: {M3, HC3} <= S2[55:40];
                                                S3[7:0]: {M3, HC3} <= S3[55:40];
                                                S4[7:0]: {M3, HC3} <= S4[55:40];
                                                S5[7:0]: {M3, HC3} <= S5[55:40];
                                        endcase
                                end
                                4'h4:begin
                                        case(comp5[7:0])
                                                S0[7:0]: {M4, HC4} <= S0[55:40];
                                                S1[7:0]: {M4, HC4} <= S1[55:40];
                                                S2[7:0]: {M4, HC4} <= S2[55:40];
                                                S3[7:0]: {M4, HC4} <= S3[55:40];
                                                S4[7:0]: {M4, HC4} <= S4[55:40];
                                                S5[7:0]: {M4, HC4} <= S5[55:40];
                                        endcase
                                end
                                4'h5:begin
                                        case(comp5[7:0])
                                                S0[7:0]: {M5, HC5} <= S0[55:40];
                                                S1[7:0]: {M5, HC5} <= S1[55:40];
                                                S2[7:0]: {M5, HC5} <= S2[55:40];
                                                S3[7:0]: {M5, HC5} <= S3[55:40];
                                                S4[7:0]: {M5, HC5} <= S4[55:40];
                                                S5[7:0]: {M5, HC5} <= S5[55:40];
                                        endcase
                                end
                                4'h6:begin
                                        case(comp5[7:0])
                                                S0[7:0]: {M6, HC6} <= S0[55:40];
                                                S1[7:0]: {M6, HC6} <= S1[55:40];
                                                S2[7:0]: {M6, HC6} <= S2[55:40];
                                                S3[7:0]: {M6, HC6} <= S3[55:40];
                                                S4[7:0]: {M6, HC6} <= S4[55:40];
                                                S5[7:0]: {M6, HC6} <= S5[55:40];
                                        endcase
                                end
                        endcase
                end
        end

endmodule


