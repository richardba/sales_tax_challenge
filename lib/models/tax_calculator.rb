# frozen_string_literal: true

module SalesTax
  # Calculates tax for one unit, rounding the combined rate up to 0.05.
  class TaxCalculator
    ROUNDING_INCREMENT = BigDecimal("0.05")

    def initialize(policy: TaxPolicy.new)
      @policy = policy
      freeze
    end

    def tax_per_unit(item)
      unrounded_tax = item.unit_price * @policy.rate_for(item)
      (unrounded_tax / ROUNDING_INCREMENT).ceil * ROUNDING_INCREMENT
    end
  end
end