# Sales Taxes Challenge (Ruby)

A small command-line application that calculates sales taxes and generates itemized receipts for shopping baskets. Built with plain Ruby, without Rails, external frameworks, or third-party runtime dependencies.

## Requirements

- Ruby 4.x (project version: 4.0.7).
- Minitest for automated testing.

Check your Ruby installation:

```sh
ruby --version
```

## Running the Application

From the project root:

```sh
ruby bin/receipt samples/input_1.txt
ruby bin/receipt samples/input_2.txt
ruby bin/receipt samples/input_3.txt
```

Alternatively, provide input through standard input:

```powershell
Get-Content samples/input_1.txt | ruby bin/receipt
```

Example input:

```text
2 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85
```

Expected output:

```text
2 book: 24.98
1 music CD: 16.49
1 chocolate bar: 0.85
Sales Taxes: 1.50
Total: 42.32
```

Invalid input produces a descriptive error message and a nonzero exit status.

## Running the Tests

Run the complete test suite:

```sh
ruby bin/test
```

The Minitest suite includes:

- **Unit tests** for input parsing, tax calculations, rounding, exemptions, quantities, and validation.
- **Integration tests** verifying the exact expected receipts for all three supplied shopping baskets, along with CLI input and error handling.
- **Concurrency and immutability tests** covering shared calculator usage and receipt data.

## Design and Architecture

The application follows an object-oriented approach using six focused classes, each with a single responsibility.

| Class | Responsibility |
|---|---|
| `Item` | Represents immutable shopping basket data |
| `BasketParser` | Parses and validates input |
| `TaxPolicy` | Determines applicable tax rates and exemptions |
| `TaxCalculator` | Calculates taxes with the required rounding |
| `Receipt` | Calculates receipt lines, taxes, and totals |
| `ReceiptFormatter` | Formats the receipt output |

Objects collaborate through **composition rather than inheritance**. For example, `Receipt` uses `TaxCalculator`, which delegates tax rules to `TaxPolicy`.

The implementation uses familiar Ruby idioms:

- `Data` for immutable receipt line value objects.
- `attr_reader` and keyword arguments for clear object interfaces.
- Enumerable methods such as `map` and `sum` for collection processing.
- `BigDecimal` for accurate monetary calculations.

The application separates domain logic, input parsing, calculations, and presentation. Immutable data and calculations without shared mutable state support safe concurrent use.

The code also includes input validation, explicit error handling, and automated tests to improve reliability.

The design intentionally avoids unnecessary abstractions, inheritance hierarchies, factories, databases, and frameworks.

## Tax Rules

- Basic sales tax: **10%** on nonexempt products.
- Books, food, and medical products are exempt from basic sales tax.
- Import duty: an additional **5%** on all imported products, including otherwise exempt products.
- Applicable rates are combined and tax is rounded **up to the nearest 0.05 per unit** before multiplying by quantity.
- Receipt totals are calculated from the itemized, tax-inclusive prices.

All monetary calculations use `BigDecimal` to avoid floating-point precision errors.

For example, an imported bottle of perfume priced at 47.50 is taxed at 15%:

```text
Tax before rounding: 7.125
Tax after rounding:  7.15
Final price:        54.65
```

## Assumptions and Limitations

**Product classification:** The supplied input does not include product categories. The application therefore uses explicit keyword matching to identify exempt products in the provided examples: books, chocolates, and pills.

Other descriptions are considered taxable by default. This approach satisfies the supplied test cases but does not attempt to classify every possible food or medical product.

Classification rules are isolated in `TaxPolicy`, allowing them to be extended without changing parsing, calculation, or formatting.

**Imported products:** Items containing the whole word `imported` are treated as imported goods.

**Input format:** Quantities must be positive integers, and prices must be nonnegative values with exactly two decimal places.

**Rounding:** Applicable tax rates are combined before rounding once per unit, rather than rounding each tax component separately.

**Scope:** The application is a synchronous command-line tool. Product catalogs, databases, persistence, and automatic product classification are outside the requested requirements.

## Project Structure

```text
sales_tax/
├── bin/
│   ├── receipt
│   └── test
├── lib/models/
│   ├── item.rb
│   ├── basket_parser.rb
│   ├── tax_policy.rb
│   ├── tax_calculator.rb
│   ├── receipt.rb
│   └── receipt_formatter.rb
├── samples/
│   ├── input_1.txt
│   ├── input_2.txt
│   ├── input_3.txt
│   ├── expected_1.txt
│   ├── expected_2.txt
│   └── expected_3.txt
├── test/
│   ├── test_helper.rb
│   ├── basket_parser_test.rb
│   ├── tax_calculator_test.rb
│   ├── receipt_test.rb
│   └── integration_test.rb
├── sales_tax.rb
├── .ruby-version
└── README.md
```

## Implementation Approach

The solution prioritizes correctness, readability, testability, and maintainability within the exercise's four-hour time limit.

The architecture is deliberately small. Each class has a clear responsibility, tax rules are isolated from receipt generation, and the implementation can be extended without introducing unnecessary complexity.

The goal is to provide reliable, idiomatic Ruby code that solves the requested problem completely while remaining easy to understand and maintain.