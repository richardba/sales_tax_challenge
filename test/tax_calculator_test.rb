# frozen_string_literal: true

require_relative "test_helper"

class TaxCalculatorTest < Minitest::Test
  def setup
    @calculator = SalesTax::TaxCalculator.new
  end

  def test_basic_tax_rounds_up_to_nearest_five_cents
    assert_equal BigDecimal("1.50"), tax("music CD", "14.99")
    assert_equal BigDecimal("0.05"), tax("pen", "0.01")
    assert_equal BigDecimal("0.10"), tax("pen", "1.00")
  end

  def test_books_food_and_medical_products_are_exempt
    assert_equal BigDecimal("0"), tax("book", "12.49")
    assert_equal BigDecimal("0"), tax("chocolate bar", "0.85")
    assert_equal BigDecimal("0"), tax("packet of headache pills", "9.75")
  end

  def test_imported_exempt_product_pays_only_import_tax
    assert_equal BigDecimal("0.50"), tax("imported box of chocolates", "10.00")
    assert_equal BigDecimal("0.60"), tax("imported boxes of chocolates", "11.25")
    assert_equal BigDecimal("0.65"), tax("imported book", "12.49")
  end

  def test_imported_nonexempt_product_pays_combined_rate
    assert_equal BigDecimal("7.15"), tax("imported bottle of perfume", "47.50")
    assert_equal BigDecimal("4.20"), tax("imported bottle of perfume", "27.99")
  end

  def test_tax_rounds_once_on_combined_rate
    # 0.30 * 15% = 0.045 => 0.05 (not separately rounded 0.05 + 0.05).
    assert_equal BigDecimal("0.05"), tax("imported pen", "0.30")
  end

  def test_nonexempt_unknown_product_is_taxable
    assert_equal BigDecimal("0.20"), tax("notebook stand", "2.00")
  end

  def test_zero_price_has_zero_tax
    assert_equal BigDecimal("0"), tax("imported perfume", "0.00")
  end

  def test_shared_calculator_is_safe_to_use_from_multiple_threads
    item = item_for("imported bottle of perfume", "47.50")
    results = 8.times.map do
      Thread.new { 100.times.map { @calculator.tax_per_unit(item) } }
    end.flat_map(&:value)

    assert_equal [BigDecimal("7.15")], results.uniq
  end

  private

  def item_for(description, unit_price)
    SalesTax::Item.new(quantity: 1, description: description, unit_price: BigDecimal(unit_price))
  end

  def tax(description, unit_price)
    @calculator.tax_per_unit(item_for(description, unit_price))
  end
end