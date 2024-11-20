.data
    prompt: .asciiz "Enter a position (1-16) to flip a card (0 to exit): "    # Prompt message for user input
    winMsg: .asciiz "You won! Congrats!"                                      # Message displayed upon winning
    goodbyeMsg: .asciiz "Goodbye come again soon!"                           # Message displayed when exiting

.text
.globl game_loop
game_loop:
    # Check if all cards have been matched
    lw $t0, remainingCards     # Load number of remaining unmatched cards
    beq $t0, $zero, win_screen # If no cards remain, go to win screen
    
    # Show current game board
    jal displayGrid            # Call function to display the current state of cards
    
    # Display prompt for user input
    li $v0, 4                  # Load syscall code for printing string
    la $a0, prompt             # Load address of prompt message
    syscall                    # Print the prompt
    
    # Get user input
    li $v0, 5                  # Load syscall code for reading integer
    syscall                    # Read integer from user
    move $s0, $v0             # Store user input in $s0
    
    # Check if user wants to exit
    beqz $s0, exit_game       # If input is 0, exit the game
    
    # Convert input to array index (1-based to 0-based)
    addi $s0, $s0, -1         # Subtract 1 from input for 0-based indexing
    
    # Validate input range
    bltz $s0, game_loop       # If input < 0, ignore and get new input
    li $t0, 16                # Load maximum valid position
    bge $s0, $t0, game_loop   # If input >= 16, ignore and get new input
    
    # Check if selected card is already matched
    la $t0, matched           # Load base address of matched array
    sll $t1, $s0, 2          # Multiply index by 4 (shift left 2) for word alignment
    add $t0, $t0, $t1        # Calculate address of selected card
    lw $t2, ($t0)            # Load matched status of selected card
    bnez $t2, game_loop      # If card is matched (non-zero), ignore and get new input
    
    # Play sound effect for card flip
    jal play_flip_sound      # Call function to play flip sound
    
    # Mark selected card as revealed
    la $t0, revealed         # Load base address of revealed array
    sll $t1, $s0, 2          # Multiply index by 4 for word alignment
    add $t0, $t0, $t1        # Calculate address of selected card
    li $t2, 1                # Load value 1 (revealed)
    sw $t2, ($t0)            # Mark card as revealed
    
    # Update move counter
    la $t0, moveCount        # Load address of moveCount
    lw $t1, ($t0)            # Load current move count
    addi $t1, $t1, 1         # Increment move count
    sw $t1, ($t0)            # Store updated move count
    
    # Check if this is first or second move
    li $t2, 1                # Load value 1 for comparison
    beq $t1, $t2, first_move # If move count is 1, handle as first move
    
    # Handle second move
    la $t0, secondCard       # Load address of secondCard variable
    sw $s0, ($t0)            # Store position of second card
    
    jal checkMatch           # Check if the two cards match
    
    # Reset move tracking after second move
    la $t0, moveCount        # Load address of moveCount
    sw $zero, ($t0)          # Reset move count to 0
    la $t0, firstCard        # Load address of firstCard
    li $t1, -1               # Load value -1 (no card selected)
    sw $t1, ($t0)            # Reset firstCard to -1
    
    j game_loop              # Continue game loop
  
first_move:
    # Handle first move of a turn
    la $t0, firstCard        # Load address of firstCard variable
    sw $s0, ($t0)            # Store position of first card
    j game_loop              # Continue game loop
  
win_screen:
    # Display win message
    li $v0, 4                # Load syscall code for printing string
    la $a0, winMsg           # Load address of win message
    syscall                  # Print win message
    
    jal display_elapsed_time # Display total game time
 
exit_game:
    # Display goodbye message
    li $v0, 4                # Load syscall code for printing string
    la $a0, goodbyeMsg       # Load address of goodbye message
    syscall                  # Print goodbye message
    
    # Exit program
    li $v0, 10               # Load syscall code for exit
    syscall                  # Exit program