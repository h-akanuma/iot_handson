require 'bundler/setup'
require 'pi_piper'

led_pin = PiPiper::Pin.new(pin: 22, direction: :out)
switch_pin = PiPiper::Pin.new(pin: 23, direction: :in, pull: :up)

loop do
  switch_pin.read
  if switch_pin.off?
    led_pin.on
  else
    led_pin.off
  end
  sleep(0.5)
end
