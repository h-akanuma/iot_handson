require 'bundler/setup'
require 'pi_piper'

PiPiper.watch :pin => 26 do
  puts "#{last_value} -> #{value}"
end

PiPiper.wait
