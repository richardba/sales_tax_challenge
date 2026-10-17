# frozen_string_literal: true

module SalesTax
  class ParseError < StandardError; end

  # Parses the input format
  # pricing rules are not processed.
  class BasketParser
    LINE_PATTERN = /\A(?<quantity>\d+)[ \t]+(?<description>.+?)[ \t]+at[ \t]+(?<price>\d+\.\d{2})\z/

    def parse(input)
      raise ArgumentError, "input must be a string" unless input.is_a?(String)

      items = input.each_line.with_index(1).filter_map do |line, line_number|
        next if line.strip.empty?

        parse_line(line.strip, line_number)
      end

      raise ParseError, "shopping basket is empty" if items.empty?

      items.freeze
    end

    private

    def parse_line(line, line_number)
      match = LINE_PATTERN.match(line)
      raise ParseError, "line #{line_number}: invalid item format" unless match

      Item.new(
        quantity: Integer(match[:quantity], 10),
        description: match[:description],
        unit_price: BigDecimal(match[:price])
      )
    rescue ArgumentError => e
      raise ParseError, "line #{line_number}: #{e.message}"
    end
  end
end