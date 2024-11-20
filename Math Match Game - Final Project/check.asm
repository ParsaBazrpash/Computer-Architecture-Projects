.data
    # User feedback messages
    matchFound: .asciiz "Match found!\n"          # Message displayed when cards match
    noMatch: .asciiz "No match. Try again!\n"     # Message displayed when cards don't match
    
    delay_time: .word 1000    # Time in milliseconds to display cards before hiding

.text
.globl checkMatch

# Function to check if two revealed cards match
checkMatch:
    # Set up stack frame
    addi $sp, $sp, -4         # Allocate space on stack
    sw $ra, 0($sp)            # Save return address
    
    # Get positions of selected cards
    la $t0, firstCard         # Load address of first card
    lw $t1, ($t0)             # Load position of first card
    move $t2, $s0             # Get position of second card from $s0
    
    # Get actual values from positions array
    la $t0, positions         # Load base address of positions array
    sll $t3, $t1, 2          # Multiple first position by 4 (word alignment)
    add $t0, $t0, $t3        # Calculate address of first card
    lw $t3, ($t0)            # Load first card's value
    
    la $t0, positions         # Load base address again
    sll $t4, $t2, 2          # Multiple second position by 4
    add $t0, $t0, $t4        # Calculate address of second card
    lw $t4, ($t0)            # Load second card's value
    
    # Determine card types (equation or answer)
    li $t0, 16               # Load separator value (16 and above are answers)
    blt $t3, $t0, check_first_not_answer  # If first card < 16, it's an equation
    blt $t4, $t0, check_equation_answer   # If first ≥ 16 but second < 16, equation-answer pair
    j check_answer_answer                 # Both ≥ 16, checking answer-answer pair

check_first_not_answer:
    # First card is equation, check second card type
    blt $t4, $t0, equation_equation      # If second also < 16, both are equations
    j check_equation_answer              # Otherwise, equation-answer pair

equation_equation:
    # Handle case where both cards are equations
    # Get first equation's answer value
    la $t0, answers          # Load answers array address
    sll $t5, $t3, 2         # Calculate offset for first equation
    add $t0, $t0, $t5       # Get address of first answer
    lw $t5, ($t0)           # Load first answer value
    
    # Get second equation's answer value
    la $t0, answers          # Load answers array address again
    sll $t6, $t4, 2         # Calculate offset for second equation
    add $t0, $t0, $t6       # Get address of second answer
    lw $t6, ($t0)           # Load second answer value
    
    # Compare the answers
    beq $t5, $t6, match_found  # If answers match, go to match handling
    j no_match                 # Otherwise, go to no match handling

check_equation_answer:
    # Handle case where one card is equation, other is answer
    # Determine which is which
    li $t0, 16               # Load separator value
    blt $t3, $t0, equation_first  # If first < 16, it's the equation
    
    # Swap if answer is first
    move $t7, $t3            # Temporarily store first value
    move $t3, $t4            # Move equation to first position
    move $t4, $t7            # Move answer to second position

equation_first:
    # Process equation-answer pair
    addi $t4, $t4, -16      # Convert answer index to base-0
    
    # Get equation's corresponding answer
    la $t0, answers          # Load answers array address
    sll $t5, $t3, 2         # Calculate equation's answer offset
    add $t0, $t0, $t5       # Get address of equation's answer
    lw $t5, ($t0)           # Load equation's answer value
    
    # Get selected answer value
    la $t0, answers          # Load answers array address
    sll $t6, $t4, 2         # Calculate selected answer offset
    add $t0, $t0, $t6       # Get address of selected answer
    lw $t6, ($t0)           # Load selected answer value
    
    # Compare values
    beq $t5, $t6, match_found  # If they match, go to match handling
    j no_match                 # Otherwise, go to no match handling

check_answer_answer:
    # Handle case where both cards are answers
    # Convert both indices to base-0
    addi $t3, $t3, -16      # Adjust first answer index
    addi $t4, $t4, -16      # Adjust second answer index
    
    # Get first answer value
    la $t0, answers          # Load answers array address
    sll $t5, $t3, 2         # Calculate first answer offset
    add $t0, $t0, $t5       # Get address of first answer
    lw $t5, ($t0)           # Load first answer value
    
    # Get second answer value
    la $t0, answers          # Load answers array address
    sll $t6, $t4, 2         # Calculate second answer offset
    add $t0, $t0, $t6       # Get address of second answer
    lw $t6, ($t0)           # Load second answer value
    
    # Compare values
    beq $t5, $t6, match_found  # If answers match, go to match handling
    j no_match                 # Otherwise, go to no match handling

check_first_answer:
    # Adjust index for first answer
    addi $t3, $t3, -16      # Convert to base-0 index
    j compare_values         # Continue to value comparison

check_second_answer:
    # Adjust index for second answer
    addi $t4, $t4, -16      # Convert to base-0 index
    
compare_values:
    # Get and compare actual values
    # Load first value
    la $t0, answers          # Load answers array address
    sll $t5, $t3, 2         # Calculate first value offset
    add $t0, $t0, $t5       # Get address of first value
    lw $t5, ($t0)           # Load first value
    
    # Load second value
    la $t0, answers          # Load answers array address
    sll $t6, $t4, 2         # Calculate second value offset
    add $t0, $t0, $t6       # Get address of second value
    lw $t6, ($t0)           # Load second value
    
    # Compare the values
    beq $t5, $t6, match_found  # If values match, go to match handling

no_match:
    # Handle case where cards don't match
    # Show first card
    la $t0, revealed         # Load revealed array address
    la $t1, firstCard        # Load first card position
    lw $t1, ($t1)            # Get first card position value
    sll $t1, $t1, 2         # Calculate array offset
    add $t0, $t0, $t1       # Get address in revealed array
    li $t2, 1               # Load revealed status (1)
    sw $t2, ($t0)           # Mark first card as revealed
    
    # Show second card
    la $t0, revealed         # Load revealed array address
    move $t1, $s0            # Get second card position
    sll $t1, $t1, 2         # Calculate array offset
    add $t0, $t0, $t1       # Get address in revealed array
    sw $t2, ($t0)           # Mark second card as revealed
    
    # Show both cards to player
    jal displayGrid          # Display current board state
    
    # Show no match message
    li $v0, 4               # Load syscall for printing string
    la $a0, noMatch         # Load no match message
    syscall                 # Print message
    
    # Delay to let player see cards
    li $v0, 32              # Load syscall for sleep
    li $a0, 1000           # Load delay time (1 second)
    syscall                # Sleep
    
    # Hide first card again
    la $t0, revealed        # Load revealed array address
    la $t1, firstCard       # Load first card position
    lw $t1, ($t1)           # Get first card position
    sll $t1, $t1, 2        # Calculate array offset
    add $t0, $t0, $t1      # Get address in revealed array
    sw $zero, ($t0)        # Hide first card (0)
        
    # Hide second card again
    la $t0, revealed        # Load revealed array address
    la $t1, secondCard      # Load second card position
    lw $t1, ($t1)           # Get second card position
    sll $t1, $t1, 2        # Calculate array offset
    add $t0, $t0, $t1      # Get address in revealed array
    sw $zero, ($t0)        # Hide second card (0)
    
    j check_match_done      # Go to function cleanup

match_found:
    # Handle case where cards match
    # Update remaining cards counter
    lw $t0, remainingCards  # Load remaining cards count
    addi $t0, $t0, -2      # Subtract 2 for matched pair
    sw $t0, remainingCards  # Store updated count
    
    # Show match message
    li $v0, 4              # Load syscall for printing string
    la $a0, matchFound     # Load match found message
    syscall               # Print message
    
    # Mark first card as permanently matched
    la $t0, matched        # Load matched array address
    la $t1, firstCard      # Load first card position
    lw $t1, ($t1)          # Get first card position
    sll $t1, $t1, 2       # Calculate array offset
    add $t0, $t0, $t1     # Get address in matched array
    li $t2, 1             # Load matched status (1)
    sw $t2, ($t0)         # Mark first card as matched
    
    # Mark second card as permanently matched
    la $t0, matched        # Load matched array address
    move $t1, $s0          # Get second card position
    sll $t1, $t1, 2       # Calculate array offset
    add $t0, $t0, $t1     # Get address in matched array
    sw $t2, ($t0)         # Mark second card as matched
    
check_match_done:
    # Function cleanup
    lw $ra, 0($sp)         # Restore return address
    addi $sp, $sp, 4       # Deallocate stack space
    jr $ra                 # Return to caller