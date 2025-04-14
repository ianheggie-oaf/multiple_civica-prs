# frozen_string_literal: true

require "bundler/setup"
require_relative "../scraper"
require "civica_scraper"
require "vcr"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.fail_fast = !ENV["FAIL_FAST"].to_s.empty?

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

AUSTRALIAN_STATES = %w[ACT NSW NT QLD SA TAS VIC WA].freeze
COMMON_STREET_TYPES =
  %w[
    Avenue Ave Boulevard Court Crt Circle Chase Circuit Close Crescent
    Drive Drv Lane Loop Parkway Place Parade Road Rd Street St Square Terrace Way
  ].freeze
AUSTRALIAN_POSTCODES = /\b\d{4}\b/.freeze

module SpecHelper
  # Check if an address is likely to be geocodable by analyzing its format
  # @param address [String] The address to check
  # @return [Boolean] True if the address appears to be geocodable.
  #
  # Based on: "The physical address that this application relates to.
  # This will be geocoded so doesn't need to be a specific format but
  # obviously the more explicit it is the more likely it will be
  # successfully geo-coded.
  # If the original address did not include the state (e.g. "QLD") at the end,
  # then add it. "
  def self.geocodable?(address)
    return false if address.nil? || address.empty?

    # Basic structure check - must have a street name, suburb, state and postcode
    has_state = AUSTRALIAN_STATES.any? { |state| address.end_with?(" #{state}") || address.include?(" #{state} ") }
    has_postcode = address.match?(AUSTRALIAN_POSTCODES)

    has_street_type = COMMON_STREET_TYPES.any? { |type| address.include?(" #{type}") || address.include?(" #{type.upcase}") }

    has_unit_or_lot = address.match?(/\b(Unit|Lot:?)\s+\d+/i)

    # Check for suburb in uppercase
    has_uppercase_suburb = address.match?(/\b[A-Z]{2,}(\s+[A-Z]+)*,?\s+(#{AUSTRALIAN_STATES.join('|')})\b/)

    if ENV["DEBUG"]
      missing = []
      unless has_street_type || has_unit_or_lot
        missing << "street type / unit / lot"
      end
      missing << "state" unless has_state
      missing << "postcode" unless has_postcode
      missing << "uppercase_suburb" unless has_uppercase_suburb
      puts "  address: #{address} is not geocodable, missing #{missing.join(', ')}" if missing.any?
    end

    (has_street_type || has_unit_or_lot) && has_state && has_postcode && has_uppercase_suburb
  end

  PLACEHOLDERS = [
    /no description/i,
    /not available/i,
    /to be confirmed/i,
    /\btbc\b/i,
    %r{\bn/a\b}i
  ].freeze

  def self.placeholder?(text)
    PLACEHOLDERS.any? { |placeholder| text.to_s.match?(placeholder) }
  end

  def self.reasonable_description?(text)
    !placeholder?(text) && text.to_s.split.size >= 3
  end
end
