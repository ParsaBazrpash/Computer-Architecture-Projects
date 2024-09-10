#
# Proj. 1 CS/SE 2340 M/W 5:30 - 7:00 PM -  Professor Wang
# Parsa Bazrpash Amalgar
# 08/23/2024
# Location: UTD
# The goal of this project is to set up MARS and practice 
# load/store/add/sub/addi instructions and syscalls.
#

.include "SysCalls.asm"  # Include the SysCalls.asm file

.data
    name: .space 20                # Space for the user's name
    sport: .space 20               # Space for the user's favorite sport
    promptName: .asciiz "Enter your name: "
    promptInt: .asciiz "Enter an integer between 1-50: "
    promptSport: .asciiz "Enter your favorite sport: "
    msg: .asciiz "Greetings "
    msg2: .asciiz "I see that you have entered the integers "
    dash: .asciiz " "
    newline: .asciiz "\n"
    msg3: .asciiz "Based on your input the score for the "
    msg4: .asciiz " game will be "
    

.text 
    main:
    # Prompt for name
    li $v0, SysPrintString         # Print string syscall
    la $a0, promptName            # Load Address from promptName
    syscall                       # System call

    li $v0, SysReadString          # Read string syscall
    la $a0, name                  # Load address from name variable
    li $a1, 20                    # Maximum number of characters
    syscall                       # System call

    # Prompt for 1st Integer
    li $v0, SysPrintString         # Print string syscall
    la $a0, promptInt             # Load Address from promptInt
    syscall                       # System call

    li $v0, SysReadInt             # Read integer syscall
    syscall                       # System call
    move $t0, $v0                 # Store integer in $t0 (a)

    # Prompt for second integer
    li $v0, SysPrintString         # Print string syscall
    la $a0, promptInt             # Load Address from promptInt
    syscall                       # System call

    li $v0, SysReadInt             # Read integer syscall
    syscall                       # System call
    move $t1, $v0                 # Store integer in $t1 (b)

    # Prompt for favorite sport
    li $v0, SysPrintString         # Print string syscall
    la $a0, promptSport           # Load Address from prompt
    syscall                       # System call

    li $v0, SysReadString          # Read string syscall
    la $a0, sport                 # Load address of sport variable
    li $a1, 20                    # Maximum number of characters
    syscall                       # System call

    # Calculate ans1 = 3a - 2b + 32
    add $t4, $t0, $t0             # t4 = 2a
    add $t4, $t4, $t0             # t4 = 3a

    add $t5, $t1, $t1             # t5 = 2b
    sub $t6, $t4, $t5             # t6 = 3a - 2b
    addi $t6, $t6, 32             # t6 = 3a - 2b + 32 (ans1)

    # Calculate ans2 = 2b - a - 12
    add $t7, $t1, $t1             # t7 = 2b
    sub $t8, $t7, $t0             # t8 = 2b - a
    addi $t8, $t8, -12            # t8 = 2b - a - 12 (ans2)

    # Display the results
    li $v0, SysPrintString         # Print string syscall
    la $a0, msg                   # Load address msg
    syscall                       # System call

    li $v0, SysPrintString         # Print string syscall
    la $a0, name                  # Load address name
    syscall                       # System call

    li $v0, SysPrintString         # Print string syscall
    la $a0, msg2                  # Load address msg2
    syscall                       # System call

    li $v0, SysPrintInt            # Print integer syscall
    move $a0, $t0                 # Print a
    syscall                       # System call
    
    li $v0, SysPrintString         # Print string syscall
    la $a0, dash                  # Load address dash between a & b
    syscall                       # System call

    li $v0, SysPrintInt            # Print integer syscall
    move $a0, $t1                 # Print b
    syscall                       # System call
    
    li $v0, SysPrintString         # Print string syscall
    la $a0, newline               # Load address newline
    syscall                       # System call
    
    li $v0, SysPrintString         # Print string syscall
    la $a0, msg3                  # Load address msg3
    syscall                       # System call

    li $v0, SysPrintString         # Print string syscall
    la $a0, sport                 # Load sport name
    syscall                       # System call

    li $v0, SysPrintString         # Print string syscall
    la $a0, msg4                  # Load address msg4
    syscall                       # System call

    li $v0, SysPrintInt            # Print integer syscall
    move $a0, $t6                 # Print ans1
    syscall                       # System call
    
    li $v0, SysPrintString         # Print string syscall
    la $a0, dash                  # Load address space between ans1 & ans2
    syscall                       # System call
    
    li $v0, SysPrintInt            # Print integer syscall
    move $a0, $t8                 # Print ans2
    syscall                       # System call

    # Exit program
    li $v0, SysExit                # Exit syscall
    syscall                       # System call
