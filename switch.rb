require 'bundler/setup'
require 'pi_piper'

pin = PiPiper::Pin.new(pin: 23, direction: :in, pull: :up)

loop do
  pin.read
  if pin.value == 0
    puts 'The switch has been pushed.'
  end
  sleep 1
end
