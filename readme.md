# Z80-computer

## Introduction
The Z80 is an 8-bit CPU designed by Zilog that was first introduced in 1976, and was one of the first microprocessors that allowed the general public, not just large businesses, to own a computer. The aim of this project is to design a Z80 computer with the following features: 256k of read only memory, and 256k of RAM, and output in the form of either 8 LEDs, or an LCD screen, the simplest possible way to load programs, and get some output from these programs. I hope to explain the design process and all the moving parts in this document. 

## TOC
[Components needed](#components-needed)

First stage:

[Power Supply](#power-supply)

[The Clock](#the-clock)

[The Z80](#The-Z80)

[Test 1](#test-1)

Connecting the ROM:

[Connecting the ROM](#Connecting-ROM)

[Our First Program](#Our-first-program)

[Test 2](#test-2)

LED OUTPUT:

[Getting Some Output](#Getting-Some-Output)


## Components needed
### The Big Three
- Zilog CPU. I am using a modern Z84C00. Its static design means that we can run the clock signal as slow, or as fast as we want (up to several MHz).
- AT28c256. A 256k EEPROM. Or more specifically, it can contain 32k words, each containing 8 bits. This will be used as our ROM (read only memory). The place where we store the instructions for our program.
- CY62256NLL-70PXC. A 256k SRAM. Yet again, its really 32k, each containing 8 bits of data. The "S" in SRAM means static, and it means we do not need to refresh the memory contents like we would if we were to use DRAM (dynamic).
### Power
> Alternatively to the components below, you can use an Arduino supply a clean 5V, as well as the ground. 
- LM7805. This is a linear power regulator. If we supply it with 9V (or atleast 7V) and it drops this to 5V, the voltage level that our system will be running at.
- 100nf capacitor. This will be used for decoupling the 5V to ground, to ensure a clean voltage.
- 100uf capacitor. This will be used for decoupling the 9V to ground, to ensure a clean voltage.
- Two 1N4001 diodes. These will be used as voltage protection, to ensure against too high currents/voltages, and reverse polarity.
### Clock pulse
> As opposed to the components below, you can use an Arduino to supply the clock pulse. If you're not using the Arduino to also supply the power, be sure to tie the ground of your power supply to the ground of the Arduino.
- NE555 timer. This will be used as the timer.
- 10nf to 100nf capacitor.
- 1M trim pot. 
### Output
- 8 LEDs for one of the output ports.
- 8 330 ohm resistors. Im using red LEDs and these seem to work fine. If you're using a different colour you may want to change these values.
- 74x373 chip. An 8 bit latch. This will be used to store the values we want to output on the LEDs.
- A generic LCD display. This will be used to output text from our programs.
### Logic
> If you're using an LS family chip (aka 74LS04), make sure to tie all the unused inputs to ground, if you're using a HCT or HC family chip, you do not need to do this.
- 74x04 chip. A NOT gate. This will be used to turn high signals low, and low signals high. 
- 74x08 chip. An AND gate. This will be used to output a high signal when both inputs are high.
- 74x32 chip. An OR gate. This will be used to output a high signal when either of the inputs are high.
### Miscellaneous
- A momentary push button. This will be used as our reset button.
- Some 100n capacitors to help clean out the voltage throughout the circuit.
- At least three 830 tiepoint breadboard.
- Some jumper wires.
- Some extra LEDs if you want to see the status of some outputs, such as HALT, MREQ, the clock pulse etc. Plus resistors for these.
- Some way to write data to an EEPROM. I am using an XGecuPro T48.


## Building

### Power Supply
> If you're using an Arduino to power your system, you can skip this part.

This is a good place to start because if the power supply of our system is faulty, it means that nothing else will work.

We will be using an LM7805 regulator for this. It is a very common linear power regulator. To make it work we need to supply it at least 7V, connect it to ground, and it will output 5V. However there is a bit of surrounding circuitry we need to add to make sure it is fully foolproof and to ensure it works to its potential. 

Here is the schematic for the power supply alongside how it looks on a breadboard.

![image](https://i.imgur.com/CLdJHuD.png)
