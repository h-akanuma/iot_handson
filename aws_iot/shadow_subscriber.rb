require 'bundler/setup'
require 'mqtt'
require 'json'

BEAM_URL = 'beam.soracom.io'
TOPIC = '$aws/things/raspberry_pi/shadow/update'
DELTA_TOPIC = "#{TOPIC}/delta"

def statement(power)
  {
    state: {
      reported: {
        power: power
      }
    }
  }
end

MQTT::Client.connect(host: BEAM_URL) do |client|
  power = 'off'
  client.publish(TOPIC, statement(power).to_json)
  puts "Published initial statement. power: #{power}"

  client.subscribe(DELTA_TOPIC)
  puts "Subscribed to the topic: #{DELTA_TOPIC}"

  client.get do |topic, json|
    power = JSON.parse(json)['state']['power']
    client.publish(TOPIC, statement(power).to_json)
    puts "Changed power state to: #{power}"
    puts json
  end
end
