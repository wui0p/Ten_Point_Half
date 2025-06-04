# 2025 FPGA Midterm Exercise (Ten Point Half)

* FPGA: xc7a35tcsg324-1 (DSPs 90)
* Vivado 2024.2

A functioning Verilog code for an easy game of ten-point half using an FPGA board.

## INTRODUCTION
Ten-point-half is a kind of poker card game. There are two characters in this game. One is the dealer and the other is the player. The players aim to get larger values of cards in total than the dealer to win the game. In contrast, the dealer gets higher values than the players to win. The only restriction is that both players and the dealer can’t have their cards greater than 10.5 in total.

## RULES
1. Press the “Reset” signal, and the seven-segment display works functionally correctly. 
2. When the “btn_m” signal is pressed to start the game, your design successfully completes the Beginning state and transitions to the Hit Cards state. Additionally, the design can display the first card obtained by the player or dealer from LUT.v. 
3. During the first round, the player's card points (and total points in hand) will be correctly displayed on the seven-segment display. Additionally, pressing the "btn_r" signal permits the dealer to draw additional cards. 
4. During the first round, the dealer's card points (and total points in hand) will be correctly displayed on the seven-segment display. Moreover, pressing the 'btn_r' button will transition the game to the 'Compare' state. 
5. During the Compare state of the first round, the total points of both the dealer and the player should be correctly displayed on the seven-segment display, and the LEDs should be turned on accurately to indicate the winner. To end the Compare state, you must press the “btn_r” signal.  
6. The player/dealer could successfully Hit Cards at least one time, and the sevensegment display shows the correct points of the cards in their hands. 
7. The player/dealer could successfully Hit Cards 4 times (total 5 cards in hand). 
8. When the player/dealer is busted, your design could transition to the next state successfully. (The player turns to the dealer for Hit Cards, while the dealer turns to Compare state.) 
9. If there is anyone is busted, the Compare state works properly in this case. 
10. Your design could go through the entire 4 rounds and turn into the Done state.

Demo video: https://www.youtube.com/watch?v=MHQ68WXCOEY&list=PPSV&ab_channel=Gauss
<br>
Due to copyright claims, the midterm PDF can't be uploaded!
