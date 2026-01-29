module apb_slave (
    input  logic        clk,
    input  logic        rst_n,
    // APB signals
    input  logic [31:0] PADDR,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY
);

    // Simple 32-bit register as peripheral memory
    logic [31:0] mem;

    // PREADY is always 1 (ready immediately)
    assign PREADY = 1'b1;

    // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mem <= 32'h0;
        else if (PSEL && PENABLE && PWRITE)
            mem <= PWDATA;
    end

    // Read logic
    assign PRDATA = (PSEL && PENABLE && !PWRITE) ? mem : 32'h0;

endmodule
