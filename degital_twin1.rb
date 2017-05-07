require 'bundler/setup'
require 'pi_piper'
require 'open-uri'

interval = 60.0
unless ARGV.empty?
  interval = ARGV[0].to_f
end

led_pin = PiPiper::Pin.new(pin: 22, direction: :out)

loop do
  print 'Connecting to Meta-data service... '
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

  if interval > 0
    sleep(interval)
    next
  end

  break
end

