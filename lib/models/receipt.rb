# frozen_string_literal: true

module SalesTax
  # Represents the calculated receipt independently of its text presentation.
  class Receipt
    Line = Data.define(:item, :tax, :total)

    attr_reader :lines, :sales_taxes, :total

    def initialize(items, tax_calculator: TaxCalculator.new)
      @lines = items.map do |item|
        unit_tax = tax_calculator.tax_per_unit(item)

        Line.new(
          item: item,
          tax: unit_tax * item.quantity,
          total: (item.unit_price + unit_tax) * item.quantity
        )
      end.freeze

      zero = BigDecimal("0")
      @sales_taxes = @lines.sum(zero, &:tax)
      @total = @lines.sum(zero, &:total)
      freeze
    end
  end
end