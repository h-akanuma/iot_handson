require 'bundler/setup'
require 'mqtt'

BEAM_URL = 'beam.soracom.io'
TOPIC = 'topic/sample'

MQTT::Client.connect(host: BEAM_URL) do |client|
  now = Time.now
  client.publish(TOPIC, "Test from publisher.rb: #{now}")
  puts "Published to the topic '#{TOPIC}': #{now}"
end
