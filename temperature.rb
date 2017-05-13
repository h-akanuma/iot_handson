require 'bundler/setup'
require 'httpclient'
require 'logger'

SENSOR_FILE_PATH = "/sys/bus/w1/devices/28-*/w1_slave"
HARVEST_URL = 'http://harvest.soracom.io/'

logger = Logger.new('temperature.log')

interval = 60.0
unless ARGV.empty?
  interval = ARGV.first.to_f
end

device_file_name = Dir.glob(SENSOR_FILE_PATH).first
http_client = HTTPClient.new
loop do
  sensor_data = File.read(device_file_name)
  temperature = sensor_data.match(/t=(.*$)/)[1].to_f / 1000
  payload = '{"temperature":"%.3f"}' % temperature
  res = http_client.post(HARVEST_URL, payload, 'Content-Type' => 'application/json')
  logger.info("PAYLOAD: #{payload} / HARVEST Response: #{res.status}")

  sleep(interval)
end
