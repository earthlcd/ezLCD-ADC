----------------------------------------------------------------------
-- ezLCD GPIO test application note example
--  This program sets all GPIO on the 5035 as inputs and displays
--  thier values on the LCD display.
--
-- Created  11/18/2024  -  Jacob Christ
-- Updated  11/18/2024  -  Jacob Christ
--
-- This program has tested on the following:
--   ezLCD-5035 Firmware 3.0.1 04-24-2024 
--
----------------------------------------------------------------------
-- *** ezLCD-5035 GPIO Pin Definitions ***
-- 
-- GPIO 0  = LED
-- GPIO 1  = (PA0)
-- GPIO 2  = (PB2)
-- GPIO 3  = (PE3)
-- GPIO 4  = (PJ5)
-- GPIO 5  = (PJ6)
-- GPIO 6  = (PC7)
-- GPIO 7  = (PH8)
-- GPIO 8  = (PG9)
-- GPIO 9  = (PI10)
-- GPIO 10 = (PH11)
-- GPIO 11 = (PD11)
-- GPIO 12 = (PC13)
-- GPIO 13 = (PG14)
-- GPIO 14 = (PH2)
-- GPIO 15 = (PH6)
-- GPIO 16 = (PH7)
-- GPIO 17 = (PI9)
-- GPIO 18 = (PI11)
-- GPIO 19 = (PB12) I2S2_WS
-- GPIO 20 = (PI2)  I2S2_SDI
-- GPIO 21 = (PA9)  I2S2_CLK
-- GPIO 22 = (PC6)  I2S2_MCK
-- GPIO 23 = (PI3)  I2S2_SDO
-- GPIO 24 = (PD12) USART3_DE
-- GPIO 25 = (PH14) CAN1_RX
-- GPIO 26 = (PH13) CAN1_TX
-- GPIO 27 = (PB5)  CAN2_RX
-- GPIO 28 = (PB13) CAN2_TX
-- GPIO 29 = (PB0)  ADC2_IN5_N
-- GPIO 30 = (PB1)  ADC2_IN5_P
-- GPIO 31 = (PK0)  SPI5_SCK
-- GPIO 32 = (PK1)  SPI5_NSS
-- GPIO 33 = (PF9)  SPI5_MOSI
-- GPIO 34 = (PJ11) SPI5_MISO
-- GPIO 35 = (PA4)  DAC1_OUT1
-- GPIO 36 = (PA5)  DAC1_OUT2
-- GPIO 37 = (PH9)  DAC1_EXTI9
-- GPIO 38 = (PA3)  SERIAL0_RX
-- GPIO 39 = (PD5)  SERIAL0_TX
-- GPIO 40 = (PB8)  I2C1_SCL
-- GPIO 41 = (PB7)  I2C1_SDA
-- GPIO 42 = (PE2)  SPI4_SCK
-- GPIO 43 = (PE6)  SPI4_MOSI
-- GPIO 44 = (PE4)  SPI4_NSS
-- GPIO 45 = (PE5)  SPI4_MISO


-- ADC Global Vaiables
GPIO_StartPort = 1
GPIO_StopPort = 45
GPIO_Ports = (GPIO_StopPort - GPIO_StartPort) + 1

ExitWhenLowPinIs = 17

function mainFunction()
  -- Clear the screen
  ez.Cls(ez.RGB(0,0,0))
  ez.SetColor(ez.RGB(255,255,255))

  print(string.format("Opening GPIO ports with pullup's"))

  local columns = 4
  local rows = math.ceil(GPIO_Ports/columns) -- math.ceil(45/4) = 12

  -- Open the selected GPIO Pin for Input
  for pin = GPIO_StartPort, GPIO_StopPort, 1
  do
    local pin_column = math.floor((pin-GPIO_StartPort) / rows)
    local pin_row = math.floor((pin-GPIO_StartPort) - (pin_column * rows) + 1)
    local x1 = math.floor(pin_column * (ez.Width / columns))
    local y1 = math.floor((pin_row * ez.Height) / (rows+1))
    ez.SetXY(x1,y1)
    print(string.format("GPIO %2d", pin))
    ez.SetPinInp(pin, true, false)
  end
  ez.Wait_ms(15000)

  -- Draw GPIO Status
  ez.Cls(ez.RGB(0,0,0))
  while (1) do
    ez.SetColor(ez.RGB(0,0,255))

    ez.SetXY(0,0)
    print(string.format("EarthLCD GPIO Exit When %2d Is Low", ExitWhenLowPinIs))

    for pin = GPIO_StartPort, GPIO_StopPort, 1
    do
      local value = ez.Pin(pin)
      local color = math.floor(value * 255.0) -- math.floor makes sure we get an integer to pass to ez.RGB()

      local pin_column = math.floor((pin-GPIO_StartPort) / rows)
      local pin_row = math.floor((pin-GPIO_StartPort) - (pin_column * rows) + 1)
      local x1 = math.floor(pin_column * (ez.Width / columns))
      local y1 = math.floor((pin_row * ez.Height) / (rows+1))

      local x2 = math.floor((pin_column+1) * (ez.Width / columns))
      local y2 = math.floor(((pin_row+1) * ez.Height) / (rows+1))
      ez.BoxFill(x1,y1, x2,y2, ez.RGB(255-color,color,0)) -- X1, Y1, X2, Y2, Color

      ez.SetXY(x1,math.floor(y1 + (y2-y1)/3))
      ez.SetColor(ez.RGB(255,255,255))
      print(string.format("GPIO %2d:%1d", pin, value))
      -- print(string.format("  ADC %2d = %4d %4d %3d %3d %3d %3d", i, value, color, x1, y1, x2, y2 ))

      if(pin == ExitWhenLowPinIs and value == 0) then
        return
      end
    end
    ez.Wait_ms(50)
  end
end

function errorHandler(errmsg)
  print(debug.traceback())
  print(errmsg)
  ez.Wait_ms(30000)
end

-- Call mainFunction() protected by errorHandler
rc, err = xpcall(function() mainFunction() end, errorHandler)

ez.Wait_ms(1000)
-- Clear the screen
ez.Cls(ez.RGB(0,0,255))
ez.SetColor(ez.RGB(255,255,255))
print("")
print("")
print("")
print("")
print("   The program has exited")

