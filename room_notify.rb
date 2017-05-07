require 'bundler/setup'
require 'net/http'
require 'pi_piper'
require './distance.rb'

TRIG_GPIO = 17
ECHO_GPIO = 27
LED_GPIO  = 18
THRESHOLD = 40 # cm

trig_pin = PiPiper::Pin.new(pin: TRIG_GPIO, direction: :out)
echo_pin = PiPiper::Pin.new(pin: ECHO_GPIO, direction: :in)
led_pin  = PiPiper::Pin.new(pin: LED_GPIO,  direction: :out)

occupied = false
state_changed_at = Time.now

interval = 5.0
unless ARGV.empty?
  interval = ARGV.first.to_f
end

loop do
  start_time = Time.now
  distance = read_distance(trig_pin, echo_pin)

  current_status = distance < THRESHOLD
  if occupied != current_status
    duration = Time.now - state_changed_at
    state_changed_at = Time.now
    message = "Distance: %.1f cm - Status changed to %s. (Duration: %d sec)" % [distance, current_status ? 'OCCUPIED' : 'EMPTY', duration]
    puts message
    payload = '{"text":"%s"}' % message
    uri = URI.parse('http://beam.soracom.io:8888/room')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path)
    req.body = payload
    res = http.start {|http| http.request(req) }
    puts "Beam Response: #{res.code}"
    occupied = current_status
  end

  if occupied
    led_pin.on
  else
    led_pin.off
  end

  if Time.now < start_time + interval
    sleep(start_time + interval - Time.now)
    next
  end

  sleep(0.1)
end
