require 'bundler/setup'
require 'pi_piper'
require 'net/http'
require 'open-uri'

interval = 60.0
unless ARGV.empty?
  interval = ARGV[0].to_f
end

led_pin = PiPiper::Pin.new(pin: 22, direction: :out)
led_pin.off

switch_pin = PiPiper::Pin.new(pin: 23, direction: :in, pull: :up)

start_time = nil

loop do
  start_time = Time.now.to_i

  print '- Connecting to Meta-data service... '
  begin
    res = OpenURI.open_uri('http://metadata.soracom.io/v1/subscriber.tags.led', read_timeout: 5)
    code = res.status.first.to_i

    if code != 200
      puts "ERROR: Invalid response code: #{code} message: #{res.status[1]}"
      break
    end

    led_tag = res.read.rstrip
    if led_tag.downcase == 'off'
      puts 'LED tag is OFF. Turn off the LED.'
      led_pin.off
    elsif led_tag.downcase == 'on'
      puts 'LED tag is ON. Turn on the LED.'
      led_pin.on
    end
  rescue => e
    puts e.message
    puts e.backtrace.join("\n")
    break
  end

  puts "- Waiting input via the switch (%.1f sec)" % (start_time + interval - Time.now.to_i)
  loop do
    switch_pin.read
    led_pin.read
    if switch_pin.value == 0
      puts "The switch has been pushed. Turn %s the LED" % (led_pin.off? ? 'ON' : 'OFF')
      led_pin.off? ? led_pin.on : led_pin.off
      led_pin.read

      print 'Updating Meta-data... '
      payload = '[{"tagName":"led","tagValue":"%s"}]' % (led_pin.on? ? 'on' : 'off')
      uri = URI.parse('http://metadata.soracom.io/v1/subscriber/tags')
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Put.new(uri.path, initheader = { 'Content-Type' => 'application/json'})
      req.body = payload
      res = http.start {|http| http.request(req) }
      puts "response_code: #{res.code}"
    end

    if Time.now.to_i > start_time + interval
      break
    end

    sleep(0.1)
  end
end

