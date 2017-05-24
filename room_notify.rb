require 'bundler/setup'
require 'httpclient'
require 'logger'
require 'pi_piper'
require './distance.rb'

BEAM_URL = 'http://beam.soracom.io:8888/room'

TRIG_GPIO = 17
ECHO_GPIO = 27
LED_GPIO  = 18
INTERVAL  = 5.0 # sec

logger = Logger.new('room_notify.log')

led_pin  = PiPiper::Pin.new(pin: LED_GPIO,  direction: :out)

occupied = false
state_changed_at = Time.now

threshold = 50 # cm
unless ARGV.empty?
  threshold = ARGV.first.to_f
end

http_client = HTTPClient.new
loop do
  start_time = Time.now
  distance = read_distance(TRIG_GPIO, ECHO_GPIO)

  current_status = distance < threshold
  if occupied != current_status
    duration = Time.now - state_changed_at
    state_changed_at = Time.now
    message = "Distance: %.1f cm - Status changed to %s. (Duration: %d sec)" % [distance, current_status ? 'OCCUPIED' : 'EMPTY', duration]
    payload = '{"text":"%s"}' % message
    res = http_client.post(BEAM_URL, payload, 'Content-Type' => 'application/json')
    logger.info("PAYLOAD: #{payload} / BEAM Response: #{res.status}")
    occupied = current_status
  end

  occupied ? led_pin.on : led_pin.off

  if Time.now < start_time + INTERVAL
    sleep(start_time + INTERVAL - Time.now)
    next
  end
end
