.data
    # First sound parameters (paper swoosh sound)
    flip_pitch1: .word 75       # Higher pitch for paper movement (G5)
    flip_duration1: .word 120   # Longer duration for swoosh
    flip_instrument1: .word 121 # Breath Noise/White noise for paper sound
    flip_volume1: .word 127     # Maximum volume for clear sound

    # Second sound parameters (paper settling sound)
    flip_pitch2: .word 72       # Slightly lower pitch for settling (C5)
    flip_duration2: .word 80    # Quick settling duration
    flip_instrument2: .word 11  # Music Box for crisp settling sound
    flip_volume2: .word 120     # Near maximum volume

    # Third sound parameters (final tap)
    flip_pitch3: .word 65       # Low pitch for final contact (F4)
    flip_duration3: .word 50    # Very short duration for tap
    flip_instrument3: .word 115 # Woodblock for final tap
    flip_volume3: .word 127     # Maximum volume for impact

.text
.globl play_flip_sound

# Function to play an enhanced paper flip sound effect
play_flip_sound:
    # Save return address
    addi $sp, $sp, -4        # Allocate stack space
    sw $ra, 0($sp)           # Save return address
    
    # Play first part (paper swoosh)
    lw $a0, flip_instrument1 # Load breath noise instrument
    lw $a1, flip_duration1   # Load swoosh duration
    lw $a2, flip_volume1     # Load maximum volume
    lw $a3, flip_pitch1      # Load high pitch
    
    # Play the swoosh sound
    li $v0, 31               # MIDI sound syscall
    syscall
    
    # Minimal delay for sound layering
    li $v0, 32               # Sleep syscall
    li $a0, 20               # 20ms delay
    syscall
    
    # Play second part (paper settling)
    lw $a0, flip_instrument2 # Load music box instrument
    lw $a1, flip_duration2   # Load settling duration
    lw $a2, flip_volume2     # Load high volume
    lw $a3, flip_pitch2      # Load medium pitch
    
    # Play the settling sound
    li $v0, 31               # MIDI sound syscall
    syscall
    
    # Quick delay before final tap
    li $v0, 32               # Sleep syscall
    li $a0, 10               # 10ms delay
    syscall
    
    # Play third part (final tap)
    lw $a0, flip_instrument3 # Load woodblock instrument
    lw $a1, flip_duration3   # Load tap duration
    lw $a2, flip_volume3     # Load maximum volume
    lw $a3, flip_pitch3      # Load low pitch
    
    # Play the tap sound
    li $v0, 31               # MIDI sound syscall
    syscall
    
    # Final delay for sound completion
    li $v0, 32               # Sleep syscall
    li $a0, 15               # 15ms delay
    syscall
    
    # Restore return address and return
    lw $ra, 0($sp)           # Restore return address
    addi $sp, $sp, 4         # Deallocate stack space
    jr $ra                   # Return to caller