# frozen_string_literal: true

module SalesTax
  # Responsible only for rendering the receipt in the requested format.
  class ReceiptFormatter
    def format(receipt)
      entries = receipt.lines.map do |line|
        "#{line.item.quantity} #{line.item.description}: #{money(line.total)}"
      end

      entries << "Sales Taxes: #{money(receipt.sales_taxes)}"
      entries << "Total: #{money(receipt.total)}"
      entries.join("\n")
    end

    private

    def money(value)
      Kernel.format("%.2f", value)
    end
  end
end