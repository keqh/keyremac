
require 'minitest/autorun'
require 'keyremac/base'
require 'keyremac/dump'

module MiniTest::Assertions
  def assert_xml(expected, rule)
    xml = Builder::XmlMarkup.new(indent: 2)
    actual = rule.dump(xml)
    assert actual == expected, message { diff expected, actual }
  end
end
Object.infect_an_assertion :assert_xml, :must_be_xml

describe 'dump' do
  before do
    @root = Keyremac::Root.new
    @xml = Builder::XmlMarkup.new(indent: 2)
  end

  it 'rootが出力される' do
    expected = <<-EOR
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <item>
  </item>
</root>
    EOR
    @root.must_be_xml expected
  end

  it '任意のtagを書くことができる' do
    expected = "<hoge>\n</hoge>\n"
    @root.hoge_ {}.must_be_xml expected
  end

  describe 'item' do
    ITEM = <<-EOI
<item>
  %s
</item>
    EOI

    it 'blank' do
      expected = "<item>\n</item>\n"
      @root.item {}.must_be_xml expected
    end

    it 'raw' do
      expected = ITEM % "<autogen>__KeyToKey__ KeyCode::J, KeyCode::K</autogen>"
      @root.item {
        autogen_ '__KeyToKey__ KeyCode::J, KeyCode::K'
      }.must_be_xml expected
    end

    it 'app' do
      expected = ITEM % "<only>TERMINAL</only>"
      @root.item(app: 'TERMINAL') {}.must_be_xml expected
    end

    it 'inputsource' do
      expected = ITEM % "<inputsource_only>JAPANESE</inputsource_only>"
      @root.item(inputsource: 'JAPANESE') {}.must_be_xml expected
    end
  end

  describe 'app' do
    it 'raw' do
      expected = ITEM % "<only>TERMINAL</only>"
      @root.app('TERMINAL') {}.must_be_xml expected
    end
  end

  describe 'to' do
    it 'basic' do
      expected = "<autogen>__KeyToKey__ KeyCode::J, KeyCode::K</autogen>\n"
      (:j .to :k).must_be_xml expected
    end

    it '複数' do
      expected = "<autogen>__KeyToKey__ KeyCode::J, KeyCode::K, KeyCode::L</autogen>\n"
      (:j .to :k, :l).must_be_xml expected
    end
  end

  ROOT2 = <<-EOR
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <item>
    %s
  </item>
</root>
  EOR

  describe 'root直下' do
    it 'root直下にautogenを書くとroot_itemに追加される' do
      :j .to :k
      expected = ROOT2 % "<autogen>__KeyToKey__ KeyCode::J, KeyCode::K</autogen>"
      @root.dump.must_equal expected
    end
  end

  describe 'mods' do
    it 'ctrl' do
      expected = "KeyCode::J, ModifierFlag::CONTROL_L"
      :j.ctrl.must_be_xml expected
    end

    it 'none' do
      expected = "KeyCode::J, ModifierFlag::NONE"
      :j.none.must_be_xml expected
    end

    it '複数' do
      expected = "KeyCode::J, ModifierFlag::CONTROL_L | ModifierFlag::COMMAND_L"
      :j.ctrl.cmd.must_be_xml expected
    end
  end

  describe 'consumer' do
    it 'consumer_key' do
      expected = "ConsumerKeyCode::MUSIC_PREV"
      :MUSIC_PREV.to_key.must_be_xml expected
    end
    it 'key_to_consumer' do
      expected = "<autogen>__KeyToConsumer__ KeyCode::F7, ConsumerKeyCode::MUSIC_PREV</autogen>\n"
      (:F7.to:MUSIC_PREV).must_be_xml expected
    end
  end

  describe 'key_overlaid_modifier' do
    it 'basic' do
      expected = "<autogen>__KeyOverlaidModifier__ KeyCode::JIS_EISUU, KeyCode::COMMAND_L, KeyCode::JIS_EISUU</autogen>\n"
      (:JIS_EISUU.overlaid:COMMAND_L).must_be_xml expected
    end
    it 'keys' do
      expected = "<autogen>__KeyOverlaidModifier__ KeyCode::CONTROL_L, KeyCode::CONTROL_L, KeyCode::JIS_EISUU, KeyCode::ESCAPE</autogen>\n"
      autogen = :CONTROL_L .overlaid :CONTROL_L, keys: [:JIS_EISUU, :ESCAPE]
      autogen.must_be_xml expected
    end

    it 'repeat' do
      expected = "<autogen>__KeyOverlaidModifierWithRepeat__ KeyCode::SPACE, KeyCode::SHIFT_L, KeyCode::SPACE</autogen>\n"
      autogen = :SPACE .overlaid :SHIFT_L, repeat: true
      autogen.must_be_xml expected
    end
  end
end