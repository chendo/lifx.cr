lib LIFXProtocol

  @[Packed]
  struct Header
    msg_size : UInt16

    # 0-11  = protocol version
    # 12    = unknown
    # 13    = broadcast
    # 14-15 = unknown
    descriptor : UInt16
    source : UInt32

    address : UInt8[6]
    reserved : UInt8[2]
    site : UInt8[6]

    # 0 = resp req
    # 1 = ack req
    options : UInt8
    sequence : UInt8
    at_time : UInt64
    type_id : UInt16
    _reserved : UInt16
  end

  @[Packed]
  struct HSBK
    hue : UInt16
    saturation : UInt16
    brightenn : UInt16
    kelvin : UInt16
  end

  @[Packed]
  struct Unknown
    data : UInt8[128]
  end

  @[Packed]
  struct UnknownMessage
    header : Header
    payload : Unknown
  end
end

struct LIFXProtocol::Empty
end


macro define_messages(payload_map)
  {% for type_id_name, fields in payload_map %}
    lib LIFXProtocol

      {% if fields %}
        @[Packed]
        struct {{type_id_name[1]}}
          {% for field, type in fields %}
            {{field}} : {{type}}
          {% end %}
        end
      {% end %}

      @[Packed]
      struct {{type_id_name[1]}}Message
        header : Header
        {% if fields %}
          payload : {{type_id_name[1]}}
        {% end %}
      end
    end

    {% if !fields %}
      @[Extern]
      struct LIFXProtocol::{{type_id_name[1]}}
      end

      struct LIFXProtocol::{{type_id_name[1]}}Message
        property payload : {{type_id_name[1]}}

        def initialize
          @payload = LIFXProtocol::{{type_id_name[1]}}.new
        end
      end

    {% end %}

  {% end %}

  lib LIFXProtocol
    TYPE_ID_TO_MESSAGE = {
      {% for type_id_name, fields in payload_map %}
      {{type_id_name[0]}} => LIFXProtocol::{{type_id_name[1]}}Message,
      {% end %}
    }

    PAYLOAD_TO_TYPE_ID = {
      {% for type_id_name, fields in payload_map %}
      {{type_id_name[1]}} => {{type_id_name[0]}},
      {% end %}
    }

    alias Message =
      {% for type_id_name, fields in payload_map %}
      {{type_id_name[1]}}Message |
      {% end %}
      UnknownMessage

    alias Payload =
      {% for type_id_name, fields in payload_map %}
      {{type_id_name[1]}} |
      {% end %}
      Unknown
  end

  {{debug()}}
end

define_messages({
  [2, DeviceGetService] => nil,
  [3, DeviceStateService] => {
    service: UInt8,
    port: UInt16,
  },
  [20, DeviceGetPower] => nil,
  [21, DeviceSetPower] => {
    power: UInt16
  },
  [107, LightState] => {
    color: HSBK,
    dim: Int16,
    power: UInt16,
    label: UInt8[32],
    tags: UInt64,
  }
})
