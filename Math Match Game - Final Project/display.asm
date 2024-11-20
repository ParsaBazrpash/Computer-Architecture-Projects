.data
    # Array of answers for the math problems
    answers: .word 4, 6, 8, 10, 6, 9, 12, 15, 8, 12, 16, 20, 10, 15, 20, 25  # Results of multiplications
    
    # Array of multiplication equations
    equations: .asciiz  "2x2", "2x3", "2x4", "2x5",    # First row equations
                       "3x2", "3x3", "3x4", "3x5",    # Second row equations
                       "4x2", "4x3", "4x4", "4x5",    # Third row equations
                       "5x2", "5x3", "5x4", "5x5"     # Fourth row equations

    # Visual formatting elements
    borders: .asciiz "|"           # Vertical border for cards
    hidden: .asciiz "?"            # Symbol for hidden cards
    space: .asciiz " "             # Space between cards
    newline: .asciiz "\n"          # New line character
    remainingMsg: .asciiz "Remaining Cards: "  # Message showing cards left
    
    # Time display messages
    timeMsg: .asciiz "Time: "                  # Current time label
    totalTime: .asciiz "\nTotal time: "        # Final time label
    colon: .asciiz ":"                        # Time separator
    minutes_label: .asciiz " minutes "         # Minutes label
    seconds_label: .asciiz " seconds\n"        # Seconds label
    
    # Make important variables globally accessible
    .globl answers, equations, newline

.text
.globl displayGrid, display_elapsed_time

# Main function to display the game grid
displayGrid:
    # Display remaining cards counter
    li $v0, 4                      # Load syscall for printing string
    la $a0, remainingMsg           # Load "Remaining Cards: " message
    syscall                        # Print message
    
    lw $t0, remainingCards        # Load number of remaining cards
    move $a0, $t0                 # Move to argument register
    li $v0, 1                     # Load syscall for printing integer
    syscall                       # Print remaining cards count
    
    # Print newline after remaining cards
    li $v0, 4                     # Load syscall for printing string
    la $a0, newline               # Load newline character
    syscall                       # Print newline
    
    # Update end time
    li $v0, 30                    # Load syscall for getting system time
    syscall                       # Get current time
    la $t0, end_time             # Load address of end_time
    sw $a0, ($t0)                # Store current time as end time
    
    # Calculate elapsed time
    la $t0, end_time             # Load address of end time
    lw $t0, ($t0)                # Load end time value
    la $t1, start_time           # Load address of start time
    lw $t1, ($t1)                # Load start time value
    sub $t2, $t0, $t1            # Calculate time difference in milliseconds

    # Convert milliseconds to seconds
    li $t3, 1000                 # Load 1000 for milliseconds conversion
    div $t2, $t3                 # Divide by 1000
    mflo $t2                     # Get quotient (seconds)

    # Convert seconds to minutes and remaining seconds
    li $t3, 60                   # Load 60 for minutes conversion
    div $t2, $t3                 # Divide total seconds by 60
    mflo $t4                     # Get quotient (minutes)
    mfhi $t5                     # Get remainder (seconds)

    # Display current time label
    li $v0, 4                    # Load syscall for printing string
    la $a0, timeMsg              # Load time message
    syscall                      # Print message

    # Display minutes
    li $v0, 1                    # Load syscall for printing integer
    move $a0, $t4                # Move minutes to argument register
    syscall                      # Print minutes

    # Display colon separator
    li $v0, 4                    # Load syscall for printing string
    la $a0, colon                # Load colon character
    syscall                      # Print colon

    # Display seconds
    li $v0, 1                    # Load syscall for printing integer
    move $a0, $t5                # Move seconds to argument register
    syscall                      # Print seconds

    # Print newline after time
    li $v0, 4                    # Load syscall for printing string
    la $a0, newline              # Load newline character
    syscall                      # Print newline
    
    # Save return address for function calls
    addi $sp, $sp, -4            # Allocate stack space
    sw $ra, 0($sp)               # Store return address
    
    li $s0, 0                    # Initialize row counter (0-3)
row_loop:
    li $s1, 0                    # Initialize column counter (0-3)
    
content_loop:
    # Calculate position in grid array
    mul $t0, $s0, 4              # Multiply row by 4
    add $t0, $t0, $s1            # Add column to get position
    
    # Print left border of card
    li $v0, 4                    # Load syscall for printing string
    la $a0, borders              # Load border character
    syscall                      # Print border
    
    # Check card status (matched or revealed)
    la $t1, matched              # Load address of matched array
    sll $t2, $t0, 2             # Multiply position by 4 (word size)
    add $t1, $t1, $t2           # Get address of current card in matched array
    lw $t3, ($t1)               # Load matched status
    
    la $t1, revealed            # Load address of revealed array
    add $t1, $t1, $t2           # Get address of current card in revealed array
    lw $t4, ($t1)               # Load revealed status
    
    or $t3, $t3, $t4            # Combine status (show if either matched or revealed)
    bnez $t3, print_revealed_card # If card should be shown, print it
    
    # Print hidden card symbol
    li $v0, 4                    # Load syscall for printing string
    la $a0, hidden               # Load hidden card symbol
    syscall                      # Print symbol
    j print_border               # Jump to border printing
    
print_revealed_card:
    # Get card's actual position
    la $t1, positions           # Load address of positions array
    sll $t2, $t0, 2             # Multiply current position by 4
    add $t1, $t1, $t2           # Get address of position value
    lw $t2, ($t1)               # Load position value
    
    # Determine if position is equation or answer
    li $t3, 16                  # Load separator value for equations/answers
    bge $t2, $t3, print_answer  # If position >= 16, print answer
    
    # Print equation
    la $t4, equations           # Load address of equations array
    mul $t5, $t2, 4             # Multiply position by 4 (string length)
    add $t4, $t4, $t5           # Get address of equation string
    li $v0, 4                   # Load syscall for printing string
    move $a0, $t4               # Move equation address to argument
    syscall                     # Print equation
    j print_border              # Jump to border printing
    
print_answer:
    # Print answer number
    addi $t2, $t2, -16         # Adjust index for answers array
    sll $t5, $t2, 2            # Multiply by 4 for word alignment
    la $t4, answers            # Load address of answers array
    add $t4, $t4, $t5          # Get address of answer
    lw $a0, ($t4)              # Load answer value
    li $v0, 1                  # Load syscall for printing integer
    syscall                    # Print answer
    
print_border:
    # Print right border of card
    li $v0, 4                  # Load syscall for printing string
    la $a0, borders            # Load border character
    syscall                    # Print border
    
    # Check if space needed after border
    li $t0, 3                  # Load max column value
    beq $s1, $t0, skip_space  # If last column, skip space
    li $v0, 4                  # Load syscall for printing string
    la $a0, space              # Load space character
    syscall                    # Print space

skip_space:
    addi $s1, $s1, 1          # Increment column counter
    blt $s1, 4, content_loop  # If more columns, continue loop
    
    # Print newline at end of row
    li $v0, 4                  # Load syscall for printing string
    la $a0, newline            # Load newline character
    syscall                    # Print newline
    
    addi $s0, $s0, 1          # Increment row counter
    blt $s0, 4, row_loop      # If more rows, continue loop
    
    # Print extra newline for spacing
    li $v0, 4                  # Load syscall for printing string
    la $a0, newline            # Load newline character
    syscall                    # Print newline
    
    # Restore return address and return
    lw $ra, 0($sp)             # Load return address
    addi $sp, $sp, 4           # Deallocate stack space
    jr $ra                     # Return to caller
    
# Function to display total elapsed time at end of game
display_elapsed_time:
    # Save return address
    addi $sp, $sp, -4          # Allocate stack space
    sw $ra, 0($sp)             # Store return address

    # Calculate total elapsed time
    la $t0, end_time           # Load address of end time
    lw $t0, ($t0)              # Load end time value
    la $t1, start_time         # Load address of start time
    lw $t1, ($t1)              # Load start time value
    sub $t2, $t0, $t1          # Calculate difference in milliseconds

    # Convert to seconds
    li $t3, 1000               # Load milliseconds per second
    div $t2, $t3               # Divide by 1000
    mflo $t2                   # Get seconds

    # Convert to minutes and seconds
    li $t3, 60                 # Load seconds per minute
    div $t2, $t3               # Divide total seconds by 60
    mflo $t4                   # Get minutes
    mfhi $t5                   # Get remaining seconds

    # Print total time message
    li $v0, 4                  # Load syscall for printing string
    la $a0, totalTime          # Load total time message
    syscall                    # Print message

    # Print minutes value
    li $v0, 1                  # Load syscall for printing integer
    move $a0, $t4              # Move minutes to argument register
    syscall                    # Print minutes

    # Print time separator
    li $v0, 4                  # Load syscall for printing string
    la $a0, colon              # Load colon character
    syscall                    # Print colon

    # Print seconds value
    li $v0, 1                  # Load syscall for printing integer
    move $a0, $t5              # Move seconds to argument register
    syscall                    # Print seconds

    # Print final newline
    li $v0, 4                  # Load syscall for printing string
    la $a0, newline            # Load newline character
    syscall                    # Print newline

    # Restore return address and return
    lw $ra, 0($sp)             # Load return address
    addi $sp, $sp, 4           # Deallocate stack space
    jr $ra                     # Return to caller