
require 'minitest/autorun'
require 'keyremac/base'

describe 'root' do
  before do
    @root = Keyremac::Root.new
  end

  it '末尾に_で任意のtagを書くことができる' do
    @root.item_ 'hoge'
    @root.children.length.must_equal 1
  end

  it '任意のtagはblockで入れ子にできる' do
    @root.item_ {
      name_ 'hoge'
    }
    @root.children.length.must_equal 1
  end

  describe 'item' do
    it '' do
      @root.item {}
      @root.children.length.must_equal 1
    end

    it 'raw' do
      @root.item {
        autogen_ '__KeyToKey__ KeyCode::J, KeyCode::K'
      }
      @root.children.length.must_equal 1
    end
  end
end