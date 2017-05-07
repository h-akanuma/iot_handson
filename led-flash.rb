require 'bundler/setup'
require 'pi_piper'

pin = PiPiper::Pin.new(pin: 22, direction: :out)

loop do
  pin.on
  sleep 1
  pin.off
  sleep 1
end
