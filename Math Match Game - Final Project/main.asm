# Include system calls definitions
.include "SysCalls.asm"

.data
    # Game board data structures
    selectedPairs: .word 0:8    # Array to store 8 pairs of indices for matching cards
    positions: .word 0:16       # Array to store final positions of all 16 cards on the grid
    revealed: .word 0:16        # Array to track which cards are face up (1) or face down (0)
    matched: .word 0:16         # Array to track which pairs have been successfully matched
    remainingCards: .word 16    # Counter for number of cards still to be matched
    
    # Variables to track current move state
    firstCard: .word -1         # Index of first card selected in a turn (-1 = no card selected)
    secondCard: .word -1        # Index of second card selected in a turn (-1 = no card selected)
    moveCount: .word 0          # Number of cards turned over in current move (0 or 1)
    
    # User interface text messages
    welcomeMsg: .asciiz "Welcome to math-match game!\nEnter 0 to start: "
    invalidMsg: .asciiz "Invalid input please enter 0 to start\n"
    
    # Game timing variables
    start_time: .word 0         # Timestamp when game starts
    end_time: .word 0          # Timestamp when game ends
    
    # Make important variables accessible globally
    .globl selectedPairs, positions, revealed, matched, firstCard, secondCard, moveCount, remainingCards, start_time, end_time

.text
.globl main
main:
    j welcome_screen            # Jump to welcome screen at program start

welcome_screen:
    # Display welcome message to user
    li $v0, SysPrintString     # Load syscall code for printing string
    la $a0, welcomeMsg         # Load address of welcome message
    syscall                    # Print welcome message
    
    # Get user input
    li $v0, SysReadInt         # Load syscall code for reading integer
    syscall                    # Read integer from user
    move $t0, $v0             # Store input in temporary register
    
    beq $t0, $zero, set_up    # If input is 0, proceed to game setup
    
    # Handle invalid input
    li $v0, SysPrintString        # Load syscall code for printing string
    la $a0, invalidMsg         # Load invalid input message
    syscall                    # Print invalid input message
    
    j welcome_screen           # Return to welcome screen for new input
		
set_up:
    # Record game start time
    li $v0, 30                 # Load syscall code for getting system time
    syscall                    # Get system time
    la $t0, start_time        # Load address of start_time variable
    sw $a0, ($t0)             # Store start time
    
    # Initialize game board
    jal selectRandomPairs      # Generate random pairs of cards
    jal initializePositions    # Randomly position cards on board
    
    # Initialize card states
    jal setAllHidden          # Set all cards as face down
    jal setAllNotMatched      # Set all cards as unmatched
    
    # Initialize move tracking variables
    la $t0, firstCard         # Load address of firstCard
    li $t1, -1                # Load -1 (no card selected)
    sw $t1, ($t0)             # Initialize firstCard as -1
    la $t0, moveCount         # Load address of moveCount
    sw $zero, ($t0)           # Initialize moveCount as 0
	
game_start:
    # Initialize game timer
    li $v0, 30                 # Load syscall code for getting system time
    syscall                    # Get system time
    la $t0, start_time        # Load address of start_time
    sw $a0, ($t0)             # Store start time
    
    # Set up new game
    jal selectRandomPairs      # Generate new random pairs
    jal initializePositions    # Set up new board positions
    jal setAllHidden          # Reset all cards to face down
    
    j game_loop               # Begin main game loop

selectRandomPairs:
    # Function to create random pairs of matching cards
    
    # Save return address
    addi $sp, $sp, -4         # Allocate stack space
    sw $ra, 0($sp)            # Store return address
    
    # Initialize array with sequential numbers
    la $t0, selectedPairs     # Load address of pairs array
    li $t1, 0                 # Initialize counter
init_pairs:
    sw $t1, ($t0)             # Store current number in array
    addi $t0, $t0, 4          # Move to next array position
    addi $t1, $t1, 1          # Increment counter
    blt $t1, 16, init_pairs   # Continue until 16 numbers stored
    
    # Shuffle array using Fisher-Yates algorithm
    la $t0, selectedPairs     # Reset array address
    li $t1, 15                # Start from last element

shuffle_loop:
    # Generate random index
    li $v0, 42                # Load syscall code for random int
    li $a0, 0                 # Random generator ID
    move $a1, $t1             # Set upper bound
    addi $a1, $a1, 1         # Adjust bound for inclusive range
    syscall                   # Generate random number
    
    # Calculate array addresses for swap
    sll $t2, $a0, 2          # Multiple random index by 4 for word alignment
    sll $t3, $t1, 2          # Multiple current index by 4
    add $t2, $t0, $t2        # Get address of random element
    add $t3, $t0, $t3        # Get address of current element
    
    # Perform swap
    lw $t4, ($t2)            # Load random element
    lw $t5, ($t3)            # Load current element
    sw $t5, ($t2)            # Store current at random position
    sw $t4, ($t3)            # Store random at current position
    
    addi $t1, $t1, -1        # Move to previous element
    bnez $t1, shuffle_loop   # Continue until all elements shuffled
    
    # Restore return address and return
    lw $ra, 0($sp)           # Load return address
    addi $sp, $sp, 4         # Deallocate stack space
    jr $ra                   # Return to caller

initializePositions:
    # Function to set up card positions on game board
    
    # Save return address
    addi $sp, $sp, -4         # Allocate stack space
    sw $ra, 0($sp)            # Store return address
    
    # Initialize positions array with pairs
    la $t0, selectedPairs     # Source array address
    la $t1, positions         # Target array address
    li $t2, 0                 # Initialize counter
    
init_pos_loop:
    # Store equation and answer pairs
    lw $t3, ($t0)             # Load pair index
    sw $t3, ($t1)             # Store equation index
    
    addi $t4, $t3, 16         # Calculate matching answer index
    addi $t1, $t1, 4          # Move to next position
    sw $t4, ($t1)             # Store answer index
    
    # Update loop counters and addresses
    addi $t0, $t0, 4          # Next pair
    addi $t1, $t1, 4          # Next position
    addi $t2, $t2, 1          # Increment counter
    li $t5, 8                 # Number of pairs to process
    blt $t2, $t5, init_pos_loop # Continue if more pairs to process
    
    # Shuffle all positions
    la $t0, positions         # Reset positions array address
    li $t1, 15                # Start with last position

shuffle_pos_loop:
    # Generate random position
    li $v0, 42                # Load syscall for random int
    li $a0, 0                 # Random generator ID
    move $a1, $t1             # Set upper bound
    addi $a1, $a1, 1         # Adjust for inclusive range
    syscall                   # Generate random number
    
    # Perform position swap
    sll $t2, $a0, 2          # Calculate random address offset
    sll $t3, $t1, 2          # Calculate current address offset
    add $t2, $t0, $t2        # Get random position address
    add $t3, $t0, $t3        # Get current position address
    lw $t4, ($t2)            # Load random position value
    lw $t5, ($t3)            # Load current position value
    sw $t5, ($t2)            # Store current at random
    sw $t4, ($t3)            # Store random at current
    
    addi $t1, $t1, -1        # Move to previous position
    bgez $t1, shuffle_pos_loop # Continue if more positions to shuffle
    
    # Restore return address and return
    lw $ra, 0($sp)           # Load return address
    addi $sp, $sp, 4         # Deallocate stack space
    jr $ra                   # Return to caller

setAllHidden:
    # Function to initialize all cards as hidden
    la $t0, revealed         # Load revealed array address
    li $t1, 0                # Initialize counter
    li $t2, 16               # Total number of cards

init_revealed_loop:
    sw $zero, ($t0)          # Set card as hidden (0)
    addi $t0, $t0, 4         # Move to next card
    addi $t1, $t1, 1         # Increment counter
    blt $t1, $t2, init_revealed_loop # Continue if more cards
    jr $ra                   # Return to caller

setAllNotMatched:
    # Function to initialize all cards as unmatched
    la $t0, matched          # Load matched array address
    li $t1, 0                # Initialize counter
    li $t2, 16               # Total number of cards

init_matched_loop:
    sw $zero, ($t0)          # Set card as not matched (0)
    addi $t0, $t0, 4         # Move to next card
    addi $t1, $t1, 1         # Increment counter
    blt $t1, $t2, init_matched_loop # Continue if more cards
    jr $ra                   # Return to caller