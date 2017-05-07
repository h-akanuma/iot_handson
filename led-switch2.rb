require 'bundler/setup'
require 'pi_piper'

led_pin = PiPiper::Pin.new(pin: 22, direction: :out)
led_pin.off

switch_pin = PiPiper::Pin.new(pin: 23, direction: :in, pull: :up)

loop do
  switch_pin.read
  if switch_pin.value == 0
    puts "Turn %s the LED since the switch has been pushed." % (led_pin.off? ? 'ON' : 'OFF')
    led_pin.off? ? led_pin.on : led_pin.off
    led_pin.read
  end
  sleep(0.5)
end
