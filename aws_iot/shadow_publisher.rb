require 'bundler/setup'
require 'mqtt'
require 'json'

BEAM_URL = 'beam.soracom.io'
TOPIC = '$aws/things/raspberry_pi/shadow/update'

MQTT::Client.connect(host: BEAM_URL) do |client|
  statement = {
    state: {
      desired: {
        power: 'on'
      }
    }
  }

  client.publish(TOPIC, statement.to_json)
  puts "Published to the topic: '#{TOPIC}'"
end
