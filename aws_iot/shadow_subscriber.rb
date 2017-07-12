require 'bundler/setup'
require 'mqtt'
require 'json'

BEAM_URL = 'beam.soracom.io'
TOPIC = '$aws/things/raspberry_pi/shadow/update'
DELTA_TOPIC = "#{TOPIC}/delta"

MQTT::Client.connect(host: BEAM_URL) do |client|
  initial_statement = {
    state: {
      reported: {
        power: 'off'
      }
    }
  }

  client.publish(TOPIC, initial_statement.to_json)
  puts "Published initial statement."

  client.subscribe(DELTA_TOPIC)
  puts "Subscribed to the topic: #{DELTA_TOPIC}"

  client.get do |topic, json|
    puts "#{topic}: #{JSON.parse(json)}"
  end
end
