require "./protocol.cr"

struct LIFX::Message
  # For some reason I can't seem to use the inline macro form if the macro is inside the if block
  macro handle_messages
    case header.type_id
    {% for type_id, msg_class in LIFXProtocol::TYPE_ID_TO_MESSAGE %}
    when {{type_id}}
      ptr.as({{msg_class}}*).value
    {% end %}
    else
      ptr.as(LIFXProtocol::UnknownMessage*).value
    end
  end

  def self.decode(data)
    ptr = data.to_unsafe
    header = ptr.as(LIFXProtocol::Header*).value

    raw_msg = handle_messages

    self.new(raw_msg)
  end

  # Desired API

  # msg.header
  # msg.payload

  # light_state_msg
  # def handle_light_state(state)
  #



  def initialize(@raw_msg : LIFXProtocol::Message)
    @address = Address.new(@raw_msg.header.address)
    # @msg_type = typeof(@raw_msg)
    @payload = @raw_msg.payload
    self
  end


  struct Address
    def self.broadcast
      new([0, 0, 0, 0, 0, 0, 0, 0])
    end

    def initialize(@bytes : UInt8[6])
    end

    def to_s
      @bytes.hexdump
    end
  end

  property address : Address
  # property msg_type : T.class
  property payload : LIFXProtocol::Payload?
end


struct LIFX::Address
  def initialize(serial : String)
    if serial.size != 12
      raise "Serial must be 12 characters"
    end
    @value = serial.scan(/../).map(&.[0].to_i8)
  end
end

class LIFX::Light
  def initialize(@address : Address)
  end
end
