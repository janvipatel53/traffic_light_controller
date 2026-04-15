module tb_smart_traffic_4way_fileinput;

    reg clk;
    reg reset;

    reg car_n, car_e, car_s, car_w;

    wire [2:0] north, east, south, west;

    integer file;
    integer status;

    // DUT
    smart_traffic_4way dut(
        .clk(clk),
        .reset(reset),
        .car_n(car_n),
        .car_e(car_e),
        .car_s(car_s),
        .car_w(car_w),
        .north(north),
        .east(east),
        .south(south),
        .west(west)
    );

    // clock generation
    always #5 clk = ~clk;

    // convert 3-bit light into text
    function [31:0] light_name;
        input [2:0] val;
        begin
            if(val == 3'b100) light_name = "GRN ";
            else if(val == 3'b010) light_name = "YLW ";
            else if(val == 3'b001) light_name = "RED ";
            else light_name = "UNK ";
        end
    endfunction

    initial begin
        
        $dumpfile("smart_traffic_4way.vcd");
        $dumpvars(0, tb_smart_traffic_4way_fileinput);

        // initial values
        clk = 0;
        reset = 1;

        car_n = 0;
        car_e = 0;
        car_s = 0;
        car_w = 0;

        #10 reset = 0;

        // open the input file
        file = $fopen("inputs.txt", "r");
        if(file == 0) begin
            $display("ERROR: inputs.txt not found!");
            $finish;
        end

        // table header
        $display(" time | carN carE carS carW |   N    E    S    W");
        $display("-----------------------------------------------------");

        // read from file until fscanf fails
        status = $fscanf(file, "%d %d %d %d", car_n, car_e, car_s, car_w);

        while(status == 4) begin
            #40; // wait so FSM changes outputs

            $display("%4d |  %0d    %0d    %0d    %0d  | %s %s %s %s",
                     $time, car_n, car_e, car_s, car_w,
                     light_name(north), light_name(east), light_name(south), light_name(west));

            // read next line
            status = $fscanf(file, "%d %d %d %d", car_n, car_e, car_s, car_w);
        end

        $display("Finished reading file.");
        $fclose(file);

        #50;
        $finish;
    end

endmodule
