# ezLCD-ADC Example Program

This program demonstrates how to read the ADC ports of the ezLCD-5035

Check comment in the code for firmware versions that this code has been tested on.

The differential ADC inputs are not yet working and you can only use them in single ended mode.  ADC Ports 7 & 8 are part of a differential pair and if you try to open port 8 after port 7 has been opened (or visa versa) the program will crash.  This is why there is an if statement that skips port 8 when opening the ports.

![IMG_2230](https://github.com/earthlcd/ezLCD-ADC/assets/198251/40ef5dbd-b8b3-47bb-b129-6b0bb4bb7ebe)

![IMG_2224](https://github.com/earthlcd/ezLCD-ADC/assets/198251/7b2744d9-1d6f-40ca-8840-4059d6e4735a)

