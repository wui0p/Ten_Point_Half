//MIDTERM PROJECT (2025/4/30)
//by 4112064029 & 4112064011

module tenthirty(
    input clk,
    input rst_n, //negedge reset
    input btn_m, //bottom middle
    input btn_r, //bottom right
    output reg [7:0] seg7_sel,
    output reg [7:0] seg7,   //segment right
    output reg [7:0] seg7_l, //segment left
    output reg [2:0] led // led[0] : player win, led[1] : dealer win, led[2] : done
);

//================================================================
//   PARAMETER
//================================================================

parameter START = 0;
parameter IDLE = 1;
parameter PROCESS_PLAYER = 2;   //a buffer between player turns
parameter PLAYER = 3;
parameter PROCESS_DEALER = 4;   //a buffer between dealer turns
parameter DEALER = 5;
parameter COMPARE = 6;
parameter DONE = 7;
parameter PIP_BUFFER_1 = 8;
parameter PIP_BUFFER_2 = 9;
parameter PIP_BUFFER_0 = 10;

//================================================================
//   d_clk
//================================================================
//frequency division
reg [24:0] counter; 
wire dis_clk; //seg display clk, frequency faster than d_clk
wire d_clk  ; //division clk

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
    end
end

//====== clk assign ======
assign d_clk = counter[22];
assign dis_clk = counter[15];

//================================================================
//   REG/WIRE
//================================================================
//store segment display situation
reg [7:0] seg7_temp[0:7];
reg [7:0] seg7_dis[0:7];
//display counter
reg [2:0] dis_cnt;
//LUT IO
reg  pip;
wire [3:0] number;
//button controls
reg pulse_btn_m, pulse_btn_r;
wire pro_btn_m, pro_btn_r;
//states for FSM
reg [3:0] current_state, next_state;
//counting rounds of games
reg [2:0] round = 0;
//storing numbers
reg [3:0] player_num[0:4];
reg [3:0] dealer_num[0:4];
reg [5:0] player_tot = 0, dealer_tot = 0;
//how many cards in hand (per round)
reg [2:0] card = 0;
//flag for clearing seg7 when player to dealer
reg clear;
reg round_flag;

//================================================================
//   PULSE
//================================================================

always @(posedge d_clk or negedge rst_n) begin
    if(!rst_n) begin
        pulse_btn_m <= 0;
        pulse_btn_r <= 0;
    end else begin
        pulse_btn_m <= btn_m;
        pulse_btn_r <= btn_r;
    end
end

assign pro_btn_m = (~pulse_btn_m & btn_m);
assign pro_btn_r = (~pulse_btn_r & btn_r);

//================================================================
//   FSM
//================================================================

always @(posedge d_clk or negedge rst_n) begin
    if(!rst_n) current_state <= START;
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case(current_state)
        START: next_state <= IDLE;
        IDLE: next_state <= (pro_btn_m)? PIP_BUFFER_1:IDLE;
        //===================
        PIP_BUFFER_0: next_state <= PIP_BUFFER_1;
        //===================
        PIP_BUFFER_1: next_state <= PROCESS_PLAYER;
        //===================
        PROCESS_PLAYER: next_state <= PLAYER;
        //===================
        PLAYER: begin
            if(pro_btn_m) next_state <= PIP_BUFFER_1;
            //when busted
            else if(pro_btn_r || player_tot>21 || card==4) next_state <= PIP_BUFFER_2;
            else next_state <= PLAYER;
        end
        //===================
        PIP_BUFFER_2: next_state <= PROCESS_DEALER;
        //===================
        PROCESS_DEALER: next_state <= DEALER;
        //===================
        DEALER: begin
            if(pro_btn_m) next_state <= PIP_BUFFER_2;
            //when busted
            else if(pro_btn_r || dealer_tot>21 || card==4) next_state <= COMPARE;
            else next_state <= DEALER;
        end
        //===================
        COMPARE: begin
            if(pro_btn_r) begin
                next_state <= IDLE;
                if(round==4) next_state <= DONE;
            end
            else next_state <= COMPARE;
        end
        //===================
        default: next_state <= current_state;
    endcase
end

//================================================================
//   STATE ACTION
//================================================================

always @(posedge d_clk) begin
    case(current_state)
        START: begin
           round <= 0;
           card <= 0;
           player_tot <= 0;
           dealer_tot <= 0;
        end
        IDLE: begin
            seg7_dis[7] <= 0;
            seg7_dis[6] <= 0;
            seg7_dis[5] <= 12;
            seg7_dis[4] <= 12;
            seg7_dis[3] <= 12;
            seg7_dis[2] <= 12;
            seg7_dis[1] <= 12;
            seg7_dis[0] <= 12;
            if(pro_btn_m) begin
                pip <= 1;
                round_flag <= 1;
                card <= 0;
                player_tot <= 0;
                dealer_tot <= 0;
            end
        end
        //===================
        PIP_BUFFER_0: begin
            
        end
        //===================
        PIP_BUFFER_1: begin
            pip <= 0;
            if(round_flag) begin
                round <= round + 1;
                round_flag <= 0;
            end
            if(number>10) begin
                dealer_num[card] <= 11;
                dealer_tot <= dealer_tot + 1;
            end else begin
                dealer_num[card] <= number;
                dealer_tot <= dealer_tot + number*2;
            end
        end
        //===================
        PROCESS_PLAYER: begin
            if(number>10) begin
                player_num[card] <= 11;
                player_tot <= player_tot + 1;
            end else begin
                player_num[card] <= number;
                player_tot <= player_tot + number*2;
            end
        end
        //===================
        PLAYER: begin
            if(player_tot%2==1) begin
                seg7_dis[7] <= player_tot/20;
                seg7_dis[6] <= (player_tot%20)/2;
                seg7_dis[5] <= 11;
            end else begin
                seg7_dis[7] <= player_tot/20;
                seg7_dis[6] <= (player_tot%20)/2;
                seg7_dis[5] <= 12;
            end
            seg7_dis[card] <= player_num[card];
            if(pro_btn_m || pro_btn_r) begin
                if(pro_btn_m) begin
                    card <= card + 1;
                    pip <= 1;
                end else if(pro_btn_r) begin
                    card <= 0;
                    clear <= 1;
                end
            end
            if(card==4 || player_tot>21) begin
                card <= 0;
                clear <= 1;
            end
        end
        //===================
        PIP_BUFFER_2: pip <= 0;
        //===================
        PROCESS_DEALER: begin
            if(card>0) begin
                if(number>10) begin
                    dealer_num[card] <= 11;
                    dealer_tot <= dealer_tot + 1;
                end else begin
                    dealer_num[card] <= number;
                    dealer_tot <= dealer_tot + number*2;
                end
            end
        end
        //===================
        DEALER: begin
            if(clear) begin
                seg7_dis[4] <= 12;
                seg7_dis[3] <= 12;
                seg7_dis[2] <= 12;
                seg7_dis[1] <= 12;
                clear <= 0;
            end
            if(dealer_tot%2==1) begin
                seg7_dis[7] <= dealer_tot/20;
                seg7_dis[6] <= (dealer_tot%20)/2;
                seg7_dis[5] <= 11;
            end else begin
                seg7_dis[7] <= dealer_tot/20;
                seg7_dis[6] <= (dealer_tot%20)/2;
                seg7_dis[5] <= 12;
            end
            seg7_dis[card] <= dealer_num[card];
            if(pro_btn_m) begin
                pip <= 1;
                card <= card + 1;
            end
        end
        //===================
        COMPARE: begin
            if(dealer_tot%2==1) begin
                seg7_dis[7] <= dealer_tot/20;
                seg7_dis[6] <= (dealer_tot%20)/2;
                seg7_dis[5] <= 11;
            end else begin
                seg7_dis[7] <= dealer_tot/20;
                seg7_dis[6] <= (dealer_tot%20)/2;
                seg7_dis[5] <= 12;
            end
            seg7_dis[4] <= 12;
            seg7_dis[3] <= 12;
            if(player_tot%2==1) begin
                seg7_dis[2] <= player_tot/20;
                seg7_dis[1] <= (player_tot%20)/2;
                seg7_dis[0] <= 11;
            end else begin
                seg7_dis[2] <= player_tot/20;
                seg7_dis[1] <= (player_tot%20)/2;
                seg7_dis[0] <= 12;
            end
        end 
        
        
        
        
    endcase
end

//================================================================
//   SEG7
//================================================================

always @(*) begin
    case(seg7_dis[dis_cnt])
            0: seg7_temp[dis_cnt] <= 8'b0011_1111;
            1: seg7_temp[dis_cnt] <= 8'b0000_0110;
            2: seg7_temp[dis_cnt] <= 8'b0101_1011;
            3: seg7_temp[dis_cnt] <= 8'b0100_1111;
            4: seg7_temp[dis_cnt] <= 8'b0110_0110;
            5: seg7_temp[dis_cnt] <= 8'b0110_1101;
            6: seg7_temp[dis_cnt] <= 8'b0111_1101;
            7: seg7_temp[dis_cnt] <= 8'b0000_0111;
            8: seg7_temp[dis_cnt] <= 8'b0111_1111;
            9: seg7_temp[dis_cnt] <= 8'b0110_1111;
            10: seg7_temp[dis_cnt] <= 8'b0011_1111; //0
            11: seg7_temp[dis_cnt] <= 8'b1000_0000; //.
            12: seg7_temp[dis_cnt] <= 8'b0000_0001; //-
            default: seg7_temp[dis_cnt] <= 8'b0000_0000;
    endcase
end

//================================================================
//   LED
//================================================================

always @(d_clk) begin
    if(current_state==DONE) begin
        led[0] <= 0;
        led[1] <= 0;
        led[2] <= 1;
    end else if(current_state==COMPARE) begin
        if(player_tot > 21) led[1] <= 1;
        else if(dealer_tot > 21) led[0] <= 1;
        else if(player_tot > dealer_tot) led[0] <= 1;
        else if(player_tot < dealer_tot) led[1] <= 1;
        else if(player_tot == dealer_tot) led[1] <= 1;
    end else begin
        led[0] <= 0;
        led[1] <= 0;
        led[2] <= 0;
    end
end















//#################### Don't revise the code below ############################## 

//================================================================
//   SEGMENT
//================================================================

//display counter 
always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        dis_cnt <= 0;
    end
    else begin
        dis_cnt <= (dis_cnt >= 7) ? 0 : (dis_cnt + 1);
    end
end

always @(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7 <= 8'b0000_0001;
    end 
    else begin
        if(!dis_cnt[2]) begin
            seg7 <= seg7_temp[dis_cnt];
        end
    end
end

always @(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7_l <= 8'b0000_0001;
    end 
    else begin
        if(dis_cnt[2]) begin
            seg7_l <= seg7_temp[dis_cnt];
        end
    end
end

always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg7_sel <= 8'b11111111;
    end
    else begin
        case(dis_cnt)
            0 : seg7_sel <= 8'b00000001;
            1 : seg7_sel <= 8'b00000010;
            2 : seg7_sel <= 8'b00000100;
            3 : seg7_sel <= 8'b00001000;
            4 : seg7_sel <= 8'b00010000;
            5 : seg7_sel <= 8'b00100000;
            6 : seg7_sel <= 8'b01000000;
            7 : seg7_sel <= 8'b10000000;
            default : seg7_sel <= 8'b11111111;
        endcase
    end
end

//================================================================
//   LUT
//================================================================
 
lut inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number));


endmodule 