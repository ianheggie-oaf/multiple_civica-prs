# frozen_string_literal: true

module CivicaScraper
  module Page
    # The general DA search page
    module Search
      # Return page with applications submitted between these dates
      def self.period(page, date_from, date_to)
        form = page.form_with(name: "daEnquiryForm")
        raise "Couldn't find form daEnquiryForm for period on #{page.uri}" if form.nil?

        form.dateFrom = date_from.strftime("%d/%m/%Y")
        form.dateTo   = date_to.strftime("%d/%m/%Y")
        form.submit
      end

      def self.advertised(page)
        form = page.form_with(name: "daEnquiryForm")
        raise "Couldn't find form daEnquiryForm for advertised on #{page.uri}" if form.nil?

        form.radiobutton_with(name: "searchMode", value: "C").check
        form.submit
      end
    end
  end
end
