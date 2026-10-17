# frozen_string_literal: true

require_relative "test_helper"

class BasketParserTest < Minitest::Test
  def setup
    @parser = SalesTax::BasketParser.new
  end

  def test_parses_quantity_description_and_price
    item = @parser.parse("3 imported boxes of chocolates at 11.25\n").first

    assert_equal 3, item.quantity
    assert_equal "imported boxes of chocolates", item.description
    assert_equal BigDecimal("11.25"), item.unit_price
    assert item.imported?
  end

  def test_ignores_blank_lines_and_accepts_windows_line_endings
    items = @parser.parse("\r\n1 book at 12.49\r\n\r\n1 music CD at 14.99\r\n")

    assert_equal 2, items.length
    assert_equal "music CD", items.last.description
  end

  def test_rejects_empty_basket
    error = assert_raises(SalesTax::ParseError) { @parser.parse("  \n\n") }
    assert_match(/empty/, error.message)
  end

  def test_rejects_malformed_line_with_location
    error = assert_raises(SalesTax::ParseError) do
      @parser.parse("1 book at 12.49\nnot a basket line\n")
    end

    assert_match(/line 2/, error.message)
  end

  def test_rejects_zero_quantity
    assert_raises(SalesTax::ParseError) { @parser.parse("0 book at 12.49") }
  end

  def test_rejects_invalid_price_precision
    assert_raises(SalesTax::ParseError) { @parser.parse("1 book at 12.499") }
  end

  def test_rejects_negative_price
    assert_raises(SalesTax::ParseError) { @parser.parse("1 book at -1.00") }
  end

  def test_item_is_immutable
    item = @parser.parse("1 book at 12.49").first

    assert item.frozen?
    assert item.description.frozen?
    assert_raises(FrozenError) { item.instance_variable_set(:@quantity, 3) }
  end
end