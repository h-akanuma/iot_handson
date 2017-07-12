require 'bundler/setup'
require 'mqtt'
require 'json'

BEAM_URL = 'beam.soracom.io'
TOPIC = '$aws/things/raspberry_pi/shadow/update/accepted'

MQTT::Client.connect(host: BEAM_URL) do |client|
  client.subscribe(TOPIC)
  puts "Subscribed to the topic: #{TOPIC}"

  client.get do |topic, json|
    puts "#{topic}: #{JSON.parse(json)}"
  end
end
