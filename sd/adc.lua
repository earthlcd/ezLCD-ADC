----------------------------------------------------------------------
-- ezLCD ADC test application note example
--
-- Created  01/4/2024  -  Robert Garito
-- Update   01/5/2023  -  Jacob Christ
--
-- This program has tested on the following:
--   ezLCD-5035 Firmware 01042024 
--
----------------------------------------------------------------------
-- *** ezLCD-5035 ADC Pin Definitions ***
-- 0=VBat / 4    (Raw value)
-- 1=Temp Sensor (Raw value)
-- 2=VREFInt
-- 3=DAC1
-- 4=DAC2
-- 5=Pin U1-11 (ADC3_In1_N)
-- 6=Pin U1-12 (ADC3_In1_P) / Pin U1-11 (ADC3_In1_N) Differential
-- 7=Pin U1-13 (ADC2_In5_P) / Pin U1-14 (ADC2_In5_N) Differential
-- 8=Pin U1-14 (ADC2_In5_N) 
-- 9=Pin U1-15 (ADC1_In1_N) 
-- 10=Pin U1-16 (ADC1_In1_P) / Pin U1-15 (ADC1_In1_N) Differential
-- 11=Pin U1-25 (SPI5_MOSI)
-- 12=Pin U2-30 (GPIO 14)


-- Notes on why ports 7 and 8:
--
-- Port 7 is differential.  Those do NOT work properly.  So if you open 7 that could break
-- everything if you then try to work with 8 or vice-versa.  Also, ADC input 8 uses one of the two
-- pins needed by ADC input 7 (they share pins).  So you can’t open both at the same time.  
-- ST’s mux is a bit confusing. 
--
-- 	From the comments you can see that port 7 and 8 both use ADC2_In5_N:
-- 	  7=Pin U1-13 (ADC2_In5_P) / Pin U1-14 (**ADC2_In5_N**) Differential
-- 	  8=Pin U1-14 (**ADC2_In5_N**)

-- 	ST really didn’t design the ADC to be really flexible in accessing ports like Lua would permit.  
--  Basically you have 3 ADC’s and depending on what you try to do, you can get different “ports”
--  to interfere with each-other (ie, you cannot have both single ended and differential open on
--  the same ADC at the same time or have 2 inputs on the same ADC with different timing params).  
--  This is going to be handled by adding error handling to prevent a customer from doing this 
--  (throwing an error) but I have not decided on the exact implementation yet in the code.
-- 	Additionally, with the differential pins, I have to “reserve” two pins (rather than one) when
--  you open the port and make sure both are currently avail.  I it is handled in the code but 
--  it’s not well-tested yet.  (Remember that for many of these pins [and it’s chip specific, so 
--  the SE2023 is different], the pins have multiple purposes.  Part of the reason for “Open” 
--  functions is to reserve the pin and make sure no other function is already using it, etc)
--	
-- 	There is an ADCClose() function too (not in this example) that releases the ADC pins for
--  re-use as other things, etc.


-- ADC Global Variables
ADC_StartPort = 0
ADC_StopPort = 12
ADC_Ports = ADC_StopPort + 1
ADC_MAX = 4095.0

function mainFunction()
	
	ez.Cls(ez.RGB(0,0,0))
	ez.SetColor(ez.RGB(255,255,255))

	-- Open the selected ADC Pin NOTE this is a change from the previous version of the example code
	for i = ADC_StartPort,ADC_StopPort,1
	do
		if (i < 8) or (i > 8) then
			print(string.format("Opening ADC port %d", i))
			ez.ADCOpen(i)
		else
			print(string.format("Skip opening ADC port %d", i))
		end
	end
	ez.Wait_ms(5000)


	ez.Cls(ez.RGB(0,0,0))
	while (1) do
		ez.SetColor(ez.RGB(0,0,255))

		ez.SetXY(0,0)
		print(string.format("EarthLCD ADC Example Program"))

		--print(string.format("VBatt=%1.2f", ez.ADCGetVBat()))
		--print(string.format("Temp=%3.1f F", ez.ADCGetDieTemperature() * (9.0/5.0) + 32))

		-- Volatge input (0 to 3.3v between 5035 Pin "ADC3 IN1 N" and GND)
		-- NOTE that the "N" is not a typo - ST's pinmux makes this the negative side of the Differential Pair Input (which is ADC port 6, just to confuse people)

		for i = ADC_StartPort,ADC_StopPort,1
		do
			value = ez.ADCGetValue(i)
			color = math.floor(value / ADC_MAX * 255.0) -- math.floor makes sure we get an integer to pass to ez.RGB()

			x1 = math.floor(0)
			x2 = math.floor(value / ADC_MAX * ez.Width)
			y1 = math.floor((i+1) * ez.Height / (ADC_Ports + 1))
			y2 = math.floor((i+2) * ez.Height / (ADC_Ports + 1))
			ez.BoxFill(x1,y1, x2,y2, ez.RGB(255-color,color,0)) -- X1, Y1, X2, Y2, Color
			x1 = math.floor(x2)
			x2 = math.floor(ez.Width)
			ez.BoxFill(x1,y1, x2,y2, ez.RGB(0,0,0)) -- X1, Y1, X2, Y2, Color

			ez.SetXY(0,y1+3)
			ez.SetColor(ez.RGB(255,255,255))
			print(string.format(" ADC %2d: %4d", i, value))
			-- print(string.format("  ADC %2d = %4d %4d %3d %3d %3d %3d", i, value, color, x1, y1, x2, y2 ))
		end
		
		ez.Wait_ms(250)
	end
	
end

function errorHandler(errmsg)
    print(debug.traceback())
    print(errmsg)
end

-- Call mainFunction() protected by errorHandler
rc, err = xpcall(function() mainFunction() end, errorHandler)
