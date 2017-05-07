require 'bundler/setup'
require 'pi_piper'

TRIG_GPIO = 17
ECHO_GPIO = 27

def read_distance(trig_pin, echo_pin)
  trig_pin.off

  trig_pin.on
  sleep(0.00001)
  trig_pin.off

  signal_off = Time.now
  echo_pin.read
  while echo_pin.off?
    signal_off = Time.now
    echo_pin.read
  end

  signal_on = signal_off
  while Time.now < signal_off + 0.1
    echo_pin.read
    if echo_pin.off?
      signal_on = Time.now
      break
    end
  end

  time_passed = signal_on - signal_off
  distance = time_passed * 17_000

  return distance if distance <= 500
end

if $0 == __FILE__
  trig_pin = PiPiper::Pin.new(pin: TRIG_GPIO, direction: :out)
  echo_pin = PiPiper::Pin.new(pin: ECHO_GPIO, direction: :in)

  loop do
    start_time = Time.now
    distance = read_distance(trig_pin, echo_pin)
    unless distance.nil?
      puts "Distance: %.1f cm" % distance
    end

    wait = start_time + 1 - start_time
    sleep(wait) if wait > 0
  end
end