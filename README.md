# AssemblyBitindexCounter
A low-level program written in Assembly (comments in HU).

This was made for the EFM8 Busy Bee 8-bit microcontroller produced by Silicon Labs. Software environment: Simplicity (Eclipse-based IDE) v4, compiled with Keil 8051.  
The program consists of a subroutine, which given the IRAM's cell number (0-255) and the bit's serial number in the cell (0-7), in two registers, outputs the bit index in two registers (0-2047). 

Visual explanation pdf is available in Hungarian.

## Bitindex counter
  The task is to create a subroutine program as efficient as possible, that computes the bitindex of the internal memory, that is: given the index of cell (0-255) in the IRAM and the serial number/index of the current bit in the cell (0-7), output the serial number of the bit (equivalent to the number of bits between the given bit and the IRAM's starting bit, in cell 0 with index 0). I came up with a fast solution using bit shifting.

## The idea of the solution

Computation is done in base 2, all representations of numbers are binary. It can easily be shown, that the bitindex thus shall equal to 8 * cell's index + index of the bit inside the cell. Multiplying by 2<sup>3</sup>=8 in binary is equivalent to putting three 0's at the end of the number, and the bit's index inside the cell is at most 3 bits (<8), thus we can compute the value by putting three zeroes at the end of the cell's index, then adding the other value to it, and since it is a 3 bit (at most) number, we can further simplify by instead of putting zeroes first at the end of the cell's index, we just put a 3-bit representation of the index of the bit inside the cell. See figure for better understanding, *n* is the cell's index, *k* is the index of the bit inside the cell. In the end, our number is an 11-bit number (0-2047), with the highest 8 bits equalling the cell's index *n*, and *k* being the 3 lowest bits. For technical reasons, we have to put the lowest 8 bits in one register, and the highest 3 bits in another.

![Image 1](https://user-images.githubusercontent.com/82604073/236261895-998962fc-34b6-438e-8ced-ba8127ac092a.jpg)
![image](https://user-images.githubusercontent.com/82604073/236264876-2486dbee-8d0d-4ff8-a27b-724edd71663b.png)

## The technical solution

Since registers are 8-bit on the Busy Bee, an 11-bit number is represented with its lowest 8 bits in the lower register, and the highest 3 bits in the higher register. We can store these values in the *R3-R4* register pair. We can use the accumulator for in-between computations too, and most processor-commands use the A accumulator register.

The subroutine takes in *n* and *k* as inputs, stored in the *R1, R2* register pair.

For safety reasons, we make calculation operations only in the accumulator.

### Algorithm
First, copy the cell's index (*n*) to the accumulator with <code>MOV A,R1</code>. For easier addition later on, rotate the bits in the accumulator (*n*) to one position higher three times (highest bit is rotated to the lowest bit, without carry), with the RLA command. Marking the result as *n'* on the picture.

![image](https://user-images.githubusercontent.com/82604073/236266484-e6290569-c71f-4814-b4d5-58c661da4d1a.png)

Now, we copy the accumulator's value to *R4* for masking later on. <code>MOV R4,A</code>

![image](https://user-images.githubusercontent.com/82604073/236269190-6df1ee20-831b-4b5d-ba5a-5b734ceaee76.png)

We mask (bitwise AND) for the last three bits, to only use them for *k*. Masking is done with <code>ANL A,#00000111b</code> Save the value in *R3*: <code>MOV R3,A</code>.

![image](https://user-images.githubusercontent.com/82604073/236270379-604e1df3-a641-4fce-9dba-9dbeaadbe7dc.png)

Reload the value stored in *R4* to the accumulator (<code>MOV A,R4</code>). Mask for the 5 highest bits with <code>ANL A,#11111000b</code>, then add the *k* (to be stored last three bits): <code>ADD A,R2</code>. Lastly, store the value in *R4*: <code>MOV R4,A</code>, and return from the subroutine.

![image](https://user-images.githubusercontent.com/82604073/236274310-6dfcfbe3-d557-4f15-88d7-37514f90f7a8.png)


## Additional code

A main function is created for testing, and some extra commands are called for better functioning.
