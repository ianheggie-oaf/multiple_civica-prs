# frozen_string_literal: true

require "timecop"

RSpec.describe CivicaScraper do
  it "has a version number" do
    expect(CivicaScraper::VERSION).not_to be nil
  end

  describe ".scrape_and_save" do
    def test_scrape_and_save(authority)
      File.delete("./data.sqlite") if File.exist?("./data.sqlite")

      VCR.use_cassette(authority) do
        # Vincent doesn't have older data in their system
        date = authority == :vincent ? Date.new(2023, 5, 1) : Date.new(2019, 5, 15)
        Timecop.freeze(date) do
          Scraper.scrape([authority], 1)
        end
      end

      expected = if File.exist?("spec/expected/#{authority}.yml")
                   YAML.safe_load(File.read("spec/expected/#{authority}.yml"))
                 else
                   []
                 end
      results = ScraperWiki.select("* from data order by council_reference")

      ScraperWiki.close_sqlite

      if results != expected
        # Overwrite expected so that we can compare with version control
        # (and maybe commit if it is correct)
        File.open("spec/expected/#{authority}.yml", "w") do |f|
          f.write(results.to_yaml)
        end
      end

      expect(results).to eq expected
      geocodable = results.count { |r| AddressHelper.geocodable? r["address"]}
      expect(geocodable).to be > (0.7 * results.count)
    end

    Scraper.selected_authorities.each do |authority|
      it authority do
        test_scrape_and_save(authority)
      end
    end
  end
end
