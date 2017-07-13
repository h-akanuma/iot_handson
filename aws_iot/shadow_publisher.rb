require 'bundler/setup'
require 'mqtt'
require 'json'

BEAM_URL = 'beam.soracom.io'
TOPIC = '$aws/things/raspberry_pi/shadow/update'

def statement(power)
  {
    state: {
      desired: {
        power: power
      }
    }
  }
end

def publish(client, power)
  client.publish(TOPIC, statement(power).to_json)
  puts "Published to the topic: '#{TOPIC}'. power: #{power}"
end

MQTT::Client.connect(host: BEAM_URL) do |client|
  power = 'on'
  publish(client, power)

  sleep(3)

  power = 'off'
  publish(client, power)

  sleep(3)

  publish(client, power)

  sleep(3)

  power = 'on'
  publish(client, power)

  sleep(3)
end
