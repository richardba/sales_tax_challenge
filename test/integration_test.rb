# frozen_string_literal: true

require_relative "test_helper"
require "open3"
require "rbconfig"

class IntegrationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_all_supplied_baskets_match_expected_receipts
    (1..3).each do |number|
      input = File.read(File.join(ROOT, "samples/input_#{number}.txt"))
      expected = File.read(File.join(ROOT, "samples/expected_#{number}.txt"))
      items = SalesTax::BasketParser.new.parse(input)
      actual = SalesTax::ReceiptFormatter.new.format(SalesTax::Receipt.new(items))

      assert_equal expected, "#{actual}\n", "basket #{number}"
    end
  end

  def test_cli_reads_a_file
    output, error, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin/receipt"),
      File.join(ROOT, "samples/input_1.txt")
    )

    assert status.success?, error
    assert_equal File.read(File.join(ROOT, "samples/expected_1.txt")), output
  end

  def test_cli_reads_stdin
    output, error, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin/receipt"),
      stdin_data: "1 book at 12.49\n"
    )

    assert status.success?, error
    assert_equal "1 book: 12.49\nSales Taxes: 0.00\nTotal: 12.49\n", output
  end

  def test_cli_reports_invalid_input_without_a_stack_trace
    output, error, status = Open3.capture3(
      RbConfig.ruby,
      File.join(ROOT, "bin/receipt"),
      stdin_data: "this is invalid\n"
    )

    refute status.success?
    assert_empty output
    assert_match(/Error: line 1/, error)
    refute_match(/backtrace|\.rb:\d+:in/, error)
  end
end