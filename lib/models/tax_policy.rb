# frozen_string_literal: true

module SalesTax
  # Determines applicable rates. With the supplied plain-text input, exempt
  # products must be identified by their names (see README for this assumption).
  class TaxPolicy
    BASIC_RATE = BigDecimal("0.10")
    IMPORT_RATE = BigDecimal("0.05")
    ZERO_RATE = BigDecimal("0")

    EXEMPT_NAME_PATTERNS = [
      /\bbooks?\b/i,
      /\bchocolates?\b/i,
      /\bpills?\b/i
    ].freeze

    def rate_for(item)
      basic_rate = exempt?(item.description) ? ZERO_RATE : BASIC_RATE
      basic_rate + (item.imported? ? IMPORT_RATE : ZERO_RATE)
    end

    private

    def exempt?(description)
      EXEMPT_NAME_PATTERNS.any? { |pattern| pattern.match?(description) }
    end
  end
end