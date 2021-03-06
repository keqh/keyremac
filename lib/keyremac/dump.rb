
require 'keyremac/base'

module Keyremac
  # key
  # ===========================

  class Key
    def dump(xml)
      if @mods.empty?
        "KeyCode::#{code.upcase}"
      else
        mods = @mods.to_a
        mods = mods.map { |mod|
          mod = mod.to_s
          if mod =~ /^VK_/
            mod
          else
            "ModifierFlag::#{mod}"
          end
        }
        mods = mods.join(' | ')
        "KeyCode::#{code.upcase}, #{mods}"
      end
    end
  end

  class ConsumerKey
    def dump(xml)
      "ConsumerKeyCode::#{code.upcase}"
    end
  end

  # autogen
  # ===========================

  module Autogen
    class KeyToKey
      def dump(xml)
        seqs = [from, *to].map{ |k| k.dump(xml) }.join(', ')
        xml.autogen "__KeyToKey__ #{seqs}"
      end
    end

    class KeyToConsumer
      def dump(xml)
        xml.autogen "__KeyToConsumer__ #{from.dump(xml)}, #{to.dump(xml)}"
      end
    end

    class KeyOverlaidModifier
      def dump(xml)
        seqs = [key, mod, *keys].map { |k| k.dump(xml) }.join(', ')
        autogen = repeat ? '__KeyOverlaidModifierWithRepeat__' : '__KeyOverlaidModifier__'
        xml.autogen "#{autogen} #{seqs}"
      end
    end
  end

  # container
  # ===========================

  class Raw
    def dump(xml)
      if @children.class == String
        xml.tag! @tag, @children
      else
        xml.tag! @tag do
          @children.each { |child|
            child.dump xml
          }
        end
      end
    end
  end

  class Item
    def dump(xml)
      xml.item do
        xml.name @name
        xml.identifier "private.#{@name}"
        @children.each { |child|
          child.dump xml
        }
      end
    end
  end

  class Root
    def dump(xml = nil)
      xml ||= Builder::XmlMarkup.new(indent: 2)
      xml.instruct!
      xml.root do
        @root_item.dump xml
        @children.each { |child|
          child.dump(xml)
        }
      end
    end
  end
end