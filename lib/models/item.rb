# frozen_string_literal: true

module SalesTax
  # A single entry in a shopping basket, before taxes are applied.
  class Item
    attr_reader :quantity, :description, :unit_price

    def initialize(quantity:, description:, unit_price:)
      raise ArgumentError, "quantity must be a positive integer" unless quantity.is_a?(Integer) && quantity.positive?
      raise ArgumentError, "description cannot be empty" unless description.is_a?(String) && !description.strip.empty?
      unless unit_price.is_a?(BigDecimal) && unit_price.finite? && unit_price >= 0 && (unit_price * 100).frac.zero?
        raise ArgumentError, "unit price must be a non-negative amount in cents"
      end

      @quantity = quantity
      @description = description.strip.freeze
      @unit_price = unit_price
      freeze
    end

    def imported?
      description.match?(/\bimported\b/i)
    end
  end
end