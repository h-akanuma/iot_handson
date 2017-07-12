require 'bundler/setup'
require 'mqtt'

BEAM_URL = 'beam.soracom.io'
TOPIC = 'topic/sample'

MQTT::Client.connect(host: BEAM_URL) do |client|
  client.subscribe(TOPIC)
  puts "Subscribed to the topic: #{TOPIC}"

  client.get do |topic, message|
    puts "#{topic}: #{message}"
  end
end
