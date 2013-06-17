module Keyremac

  class Key
    def dump(xml)
      if @mods.empty?
        "KeyCode::#{@name.upcase}"
      else
        mods = @mods.to_a
        mods = mods.map { |mod| "ModifierFlag::#{mod.to_s}" }
        mods = mods.join(',')
        "KeyCode::#{@name.upcase}, #{mods}"
      end
    end
  end

  class KeyToKey
    def dump(xml)
      xml.autogen "__KeyToKey__ #{@from.dump(xml)}, #{@to.dump(xml)}"
    end
  end

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
        @children.each { |child|
          child.dump xml
        }
      end
    end
  end

  class Root
    def dump
      xml = Builder::XmlMarkup.new(indent: 2)
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