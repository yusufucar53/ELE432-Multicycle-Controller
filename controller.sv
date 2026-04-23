`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2026 04:32:11 PM
// Design Name: 
// Module Name: controller
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


module controller(
    input logic clk,
    input logic reset,
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7b5, 
    input logic zero, 
    output logic [1:0] immsrc, 
    output logic [1:0] alusrca, alusrcb, 
    output logic [1:0] resultsrc,  
    output logic adrsrc, 
    output logic [2:0] alucontrol, 
    output logic irwrite, pcwrite,  
    output logic regwrite, memwrite
    );
    
    logic [1:0] aluop;
    logic branch;
    logic PCupdate;
    
    
    assign pcwrite = (branch & zero) | PCupdate;
    
    //main_FSM instantiation
    main_FSM mainfsm_inst(.clk(clk),
                          .reset(reset),
                          .op(op),
                          .branch(branch),
                          .PCupdate(PCupdate),
                          .regwrite(regwrite),
                          .memwrite(memwrite),
                          .irwrite(irwrite),
                          .resultsrc(resultsrc),
                          .alusrca(alusrca),
                          .alusrcb(alusrcb),
                          .adrsrc(adrsrc),
                          .aluop(aluop));
    
    //aludec instantiation                      
    ALUDecoder aludec_inst(.opb5(op[5]),
                           .funct3(funct3),
                           .funct7b5(funct7b5),
                           .ALUOp(aluop),
                           .ALUControl(alucontrol));
                           
    //instrdec instantiation
    instrdec instrdec_inst(.op(op),
                           .ImmSrc(immsrc));
                            
endmodule
