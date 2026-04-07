module smart_traffic_4way(
    input clk,                 // clock input
    input reset,               // reset input

    input car_n,               // car detected on north side
    input car_e,               // car detected on east side
    input car_s,               // car detected on south side
    input car_w,               // car detected on west side

    output reg [2:0] north,    // light output for north road
    output reg [2:0] east,     // light output for east road
    output reg [2:0] south,    // light output for south road
    output reg [2:0] west      // light output for west road
);

    // using 3-bit to represent light
    // 100 = green, 010 = yellow, 001 = red
    parameter GREEN  = 3'b100;
    parameter YELLOW = 3'b010;
    parameter RED    = 3'b001;

    // FSM states
    // IDLE is used to decide which side should get green
    parameter IDLE = 4'd0;

    parameter NG = 4'd1;   // north green
    parameter NY = 4'd2;   // north yellow

    parameter EG = 4'd3;   // east green
    parameter EY = 4'd4;   // east yellow

    parameter SG = 4'd5;   // south green
    parameter SY = 4'd6;   // south yellow

    parameter WG = 4'd7;   // west green
    parameter WY = 4'd8;   // west yellow

    reg [3:0] state;       // stores current state
    reg [4:0] counter;     // timer counter for delay

    // timings (just sample values)
    // green should be longer than yellow
    parameter GREEN_TIME  = 8;
    parameter YELLOW_TIME = 3;

    //  function decides which road gets green next
    // if more than 1 car is present, priority is used
    // priority: north > east > south > west
    function [3:0] choose_next_green;
        input cn, ce, cs, cw;
        begin
            if(cn)      choose_next_green = NG;   // if north has car then select north
            else if(ce) choose_next_green = EG;   // else if east has car then select east
            else if(cs) choose_next_green = SG;   // else if south has car then select south
            else if(cw) choose_next_green = WG;   // else if west has car then select west
            else        choose_next_green = NG;   // if no cars then default north
        end
    endfunction

    // sequential part (state changes on clock edge)
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;        // after reset go to idle
            counter <= 0;         // reset counter
        end
        else begin
            counter <= counter + 1;   // increase counter every clock

            case(state)

                IDLE: begin
                    // in idle, decide which green state to go to
                    state <= choose_next_green(car_n, car_e, car_s, car_w);
                    counter <= 0;
                end

                NG: begin
                    // north stays green for GREEN_TIME
                    if(counter == GREEN_TIME) begin
                        state <= NY;      // go to north yellow
                        counter <= 0;
                    end
                end

                NY: begin
                    // north yellow stays for YELLOW_TIME
                    if(counter == YELLOW_TIME) begin
                        state <= IDLE;    // after yellow go back to idle and decide again
                        counter <= 0;
                    end
                end

                EG: begin
                    if(counter == GREEN_TIME) begin
                        state <= EY;
                        counter <= 0;
                    end
                end

                EY: begin
                    if(counter == YELLOW_TIME) begin
                        state <= IDLE;
                        counter <= 0;
                    end
                end

                SG: begin
                    if(counter == GREEN_TIME) begin
                        state <= SY;
                        counter <= 0;
                    end
                end

                SY: begin
                    if(counter == YELLOW_TIME) begin
                        state <= IDLE;
                        counter <= 0;
                    end
                end

                WG: begin
                    if(counter == GREEN_TIME) begin
                        state <= WY;
                        counter <= 0;
                    end
                end

                WY: begin
                    if(counter == YELLOW_TIME) begin
                        state <= IDLE;
                        counter <= 0;
                    end
                end

                default: begin
                    state <= IDLE;     // safety
                    counter <= 0;
                end

            endcase
        end
    end

    // combinational part (lights depend on current state)
    always @(*) begin

        // default all are red
        north = RED;
        east  = RED;
        south = RED;
        west  = RED;

        // based on state, set one road green or yellow
        if(state == NG)
            north = GREEN;
        else if(state == NY)
            north = YELLOW;

        else if(state == EG)
            east = GREEN;
        else if(state == EY)
            east = YELLOW;

        else if(state == SG)
            south = GREEN;
        else if(state == SY)
            south = YELLOW;

        else if(state == WG)
            west = GREEN;
        else if(state == WY)
            west = YELLOW;

    end

endmodule
