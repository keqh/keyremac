
require 'keyremac/base'

require 'set'

module Keyremac

  CONSUMER_KEYS = [
    'BRIGHTNESS_DOWN',
    'BRIGHTNESS_UP',
    'KEYBOARDLIGHT_OFF',
    'KEYBOARDLIGHT_LOW',
    'KEYBOARDLIGHT_HIGH',
    'MUSIC_PREV',
    'MUSIC_PLAY',
    'MUSIC_NEXT',
    'MUSIC_PREV_18',
    'MUSIC_NEXT_17',
    'VOLUME_MUTE',
    'VOLUME_DOWN',
    'VOLUME_UP',
    'EJECT',
    'POWER',
    'NUMLOCK',
    'VIDEO_MIRROR',
  ]

  SYMBOL_TABLE = {
    '`'  => 'BACKQUOTE',
    '\\' => 'BACKSLASH',
    '['  => 'BRACKET_LEFT',
    ']'  => 'BRACKET_RIGHT',
    ','  => 'COMMA',
    '.'  => 'DOT',
    '='  => 'EQUAL',
    '-'  => 'MINUS',
    '\'' => 'QUOTE',
    ';'  => 'SEMICOLON',
    '0'  => 'KEY_0',
    '1'  => 'KEY_1',
    '2'  => 'KEY_2',
    '3'  => 'KEY_3',
    '4'  => 'KEY_4',
    '5'  => 'KEY_5',
    '6'  => 'KEY_6',
    '7'  => 'KEY_7',
    '8'  => 'KEY_8',
    '9'  => 'KEY_9',
  }

  SHIFT_TABLE = Hash[
    %q[!@#$%^&*()_+~QWERTYUIOP{}ASDFGHJKL:"|ZXCVBNM<>?~].each_char.to_a.zip(
    %q(1234567890-=`qwertyuiop[]asdfghjkl;'\zxcvbnm,./`).each_char.to_a
  )]

  module Keyable
    {
      ctrl:   :VK_CONTROL,
      shift:  :VK_SHIFT,
      opt:    :VK_OPTION,
      cmd:    :VK_COMMAND,
      extra1: :EXTRA1,
      none:   :NONE,
    }.each { |k,v|
      define_method(k, -> { self.to_key.add_mod v })
      define_method("#{k}?", -> { self.to_key.mods.include? v })
    }

    def to(*keys)
      key = keys.first.to_key
      autogen = if key.consumer_key?
        Keyremac::KeyToConsumer.new self.to_key, key
      else
        Keyremac::KeyToKey.new self.to_key, keys.map(&:to_key)
      end
      Keyremac.get_focus.add autogen
      autogen
    end

    def overlaid(mod, keys: [], repeat: false)
      autogen = Keyremac::KeyOverlaidModifier.new self.to_key, mod.to_key, keys: keys.map(&:to_key), repeat: repeat
      Keyremac.get_focus.add autogen
      autogen
    end

    def consumer_key?
      false
    end

    def to_key
      if Keyremac::CONSUMER_KEYS.include?(self.to_s)
        Keyremac::ConsumerKey.new self.to_s
      else
        Keyremac::Key.new self.to_s
      end
    end
  end

  class ConsumerKey < Struct.new(:code)
    include Keyable
    def consumer_key?; true end
    def to_key; self end
  end

  class Key
    include Keyable
    attr_reader :code, :mods

    def to_key
      self
    end

    def initialize(name)
      @mods = Set.new

      if key = SHIFT_TABLE[name]
        @code = SYMBOL_TABLE[key] || key
        self.shift
      else
        @code = SYMBOL_TABLE[name] || name
      end
    end

    def add_mod(mod)
      @mods.add mod
      self
    end
  end
end

class Symbol
  include Keyremac::Keyable
end

class String
  include Keyremac::Keyable
end
