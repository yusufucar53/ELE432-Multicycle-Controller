`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 04:55:25 PM
// Design Name: 
// Module Name: main_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_FSM(
    input logic clk,
    input logic reset,
    input logic [6:0] op,
    output logic branch,
    output logic PCupdate,
    output logic regwrite,
    output logic memwrite,
    output logic irwrite,
    output logic [1:0] resultsrc,
    output logic [1:0] alusrca,
    output logic [1:0] alusrcb,
    output logic adrsrc,
    output logic [1:0] aluop
    );
    
    typedef enum logic [3:0] {S0_FETCH = 4'd0,
                             S1_DECODE = 4'd1,
                             S2_MEMADR = 4'd2,
                             S3_MEMREAD = 4'd3,
                             S4_MEMWB = 4'd4,
                             S5_MEMWRITE = 4'd5,
                             S6_EXECUTER = 4'd6,
                             S7_ALUWB = 4'd7,
                             S8_EXECUTEI = 4'd8,
                             S9_JAL = 4'd9,
                             S10_BEQ = 4'd10} state_t;
                             
    state_t current_state, next_state;
    
    //state register
    always_ff @(posedge clk or posedge reset)
        begin
            if(reset) current_state <= S0_FETCH;
            else      current_state <= next_state;
        end
    
    //next_state logic
    always_comb 
        begin
            case(current_state)
                S0_FETCH: next_state = S1_DECODE;
                S1_DECODE:
                    begin
                        case(op)
                            7'b0000011: next_state = S2_MEMADR; //LW 
                            7'b0100011: next_state = S2_MEMADR; //SW
                            7'b0110011: next_state = S6_EXECUTER; //R-type
                            7'b0010011: next_state = S8_EXECUTEI; //I_type ALU
                            7'b1101111: next_state = S9_JAL; //JAL
                            7'b1100011: next_state = S10_BEQ; //BEQ
                            default: next_state = S0_FETCH;
                        endcase
                    end
                S2_MEMADR:
                    begin
                        if(op == 7'b0000011) next_state = S3_MEMREAD;
                        else                 next_state = S5_MEMWRITE;
                    end
                S3_MEMREAD: next_state = S4_MEMWB;
                S4_MEMWB: next_state = S0_FETCH;
                S5_MEMWRITE: next_state = S0_FETCH;
                S6_EXECUTER: next_state = S7_ALUWB;
                S7_ALUWB: next_state = S0_FETCH;
                S8_EXECUTEI: next_state = S7_ALUWB;
                S9_JAL: next_state = S7_ALUWB;
                S10_BEQ: next_state = S0_FETCH;
                default: next_state = S0_FETCH;
            endcase
        end

    //output logic
    always_comb
        begin
            branch = 0; 
            PCupdate = 0; regwrite = 0; memwrite = 0; irwrite = 0;
            resultsrc = 2'b00; alusrca = 2'b00; alusrcb = 2'b00; adrsrc = 0; aluop = 2'b00;
            
            case(current_state)
                S0_FETCH:
                    begin
                        adrsrc = 0; irwrite = 1; alusrca = 2'b00; alusrcb = 2'b10;
                        aluop = 2'b00; resultsrc = 2'b10; PCupdate = 1;
                    end
                S1_DECODE:
                    begin
                        alusrca = 2'b01; alusrcb = 2'b01; aluop = 2'b00;
                    end
                S2_MEMADR:
                    begin
                        alusrca = 2'b10; alusrcb = 2'b01; aluop = 2'b00;
                    end
                S3_MEMREAD:
                    begin
                        resultsrc = 2'b00; adrsrc = 1;
                    end
                S4_MEMWB:
                    begin
                        resultsrc = 2'b01; regwrite = 1;
                    end
                S5_MEMWRITE:
                    begin
                        resultsrc = 2'b00; adrsrc = 1; memwrite = 1;
                    end
                S6_EXECUTER:
                    begin
                        alusrca = 2'b10; alusrcb = 2'b00; aluop = 2'b10;
                    end
                S7_ALUWB:
                    begin
                        resultsrc = 2'b00; regwrite = 1;
                    end
                S8_EXECUTEI:
                    begin
                        alusrca = 2'b10; alusrcb = 2'b01; aluop = 2'b10;
                    end
                S9_JAL:
                    begin
                        alusrca = 2'b01; alusrcb = 2'b10; aluop = 2'b00;
                        resultsrc = 2'b00; PCupdate = 1;
                    end
                S10_BEQ:
                    begin
                        alusrca = 2'b10; alusrcb = 2'b00; aluop = 2'b01;
                        resultsrc = 2'b00; branch = 1;
                    end
            endcase
        end
                 
                                                   
endmodule
