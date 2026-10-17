# frozen_string_literal: true

require_relative "test_helper"

class ReceiptTest < Minitest::Test
  def setup
    @parser = SalesTax::BasketParser.new
  end

  def test_three_units_are_taxed_and_rounded_individually
    receipt = SalesTax::Receipt.new(@parser.parse("3 imported boxes of chocolates at 11.25"))

    assert_equal BigDecimal("1.80"), receipt.sales_taxes
    assert_equal BigDecimal("35.55"), receipt.total
    assert_equal BigDecimal("1.80"), receipt.lines.first.tax
  end

  def test_receipt_is_immutable
    receipt = SalesTax::Receipt.new(@parser.parse("1 music CD at 14.99"))

    assert receipt.frozen?
    assert receipt.lines.frozen?
    assert receipt.lines.first.frozen?
  end
end