# frozen_string_literal: true

RSpec.describe CivicaScraper do
  it "has a version number" do
    expect(CivicaScraper::VERSION).not_to be nil
  end

  # Test of scraper is done in scraper_spec
end
