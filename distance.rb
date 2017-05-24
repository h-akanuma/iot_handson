require 'bundler/setup'
require 'pi_piper'

TRIG_GPIO = 17
ECHO_GPIO = 27

def read_distance(trig_pin_no, echo_pin_no)
  trig_pin = PiPiper::Pin.new(pin: trig_pin_no, direction: :out)
  echo_pin = PiPiper::Pin.new(pin: echo_pin_no, direction: :in, trigger: :both)
  trig_pin.off
  sleep(0.3)

  trig_pin.on
  sleep(0.00001)
  trig_pin.off

  echo_pin.wait_for_change
  signal_off = Time.now

  echo_pin.wait_for_change
  signal_on = Time.now

  time_passed = signal_on - signal_off
  distance = time_passed * 17_000

  PiPiper::Platform.driver.unexport_pin(trig_pin_no)
  PiPiper::Platform.driver.unexport_pin(echo_pin_no)

  return distance if distance <= 500
end

if $0 == __FILE__
  loop do
    start_time = Time.now
    distance = read_distance(TRIG_GPIO, ECHO_GPIO)
    unless distance.nil?
      puts "Distance: %.1f cm" % distance
    end

    wait = start_time + 3 - Time.now
    sleep(wait) if wait > 0
  end
end
