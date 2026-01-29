module apb_master (
    input  logic        clk,
    input  logic        rst_n,
    // APB signals
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic        PSEL,
    output logic        PENABLE,
    output logic [31:0] PWDATA,
    input  logic [31:0] PRDATA,
    input  logic        PREADY
);

    // FSM states
    typedef enum logic [1:0] {IDLE, SETUP, ENABLE} state_t;
    state_t state, next_state;

    // Registers for outputs
    logic [31:0] addr_reg;
    logic [31:0] data_reg;
    logic        write_reg;

    // Assign outputs
    assign PADDR   = addr_reg;
    assign PWRITE  = write_reg;
    assign PSEL    = (state != IDLE);
    assign PENABLE = (state == ENABLE);
    assign PWDATA  = data_reg;

    // State update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case(state)
            IDLE:    next_state = (write_reg !== 1'bx) ? SETUP : IDLE;
            SETUP:   next_state = ENABLE;
            ENABLE:  next_state = PREADY ? IDLE : ENABLE;
        endcase
    end

    // Task for write
    task automatic write(input logic [31:0] addr, input logic [31:0] data);
        addr_reg  = addr;
        data_reg  = data;
        write_reg = 1'b1;
        @(posedge PREADY); // wait until peripheral ready
        write_reg = 1'b0;
    endtask

    // Task for read
    task automatic read(input logic [31:0] addr, output logic [31:0] data_out);
        addr_reg  = addr;
        write_reg = 1'b0;
        @(posedge PREADY);
        data_out = PRDATA;
    endtask

endmodule
