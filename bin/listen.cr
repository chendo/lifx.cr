require "../src/lifx/message"
require "socket"
s = UDPSocket.new
s.broadcast = true

s.bind("0.0.0.0", 56700)

loop do
  buffer = Slice(UInt8).new(128)
  s.receive(buffer)

  msg = LIFX::Message.decode(buffer)
  puts "Device:\t#{msg.address}"
  puts "Payload: \t#{msg.payload}"
  puts
  puts "============="
end
