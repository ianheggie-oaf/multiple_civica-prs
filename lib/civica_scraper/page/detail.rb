# frozen_string_literal: true

module CivicaScraper
  module Page
    # A page with all the information (hopefully) about a single
    # development application
    module Detail
      def self.scrape(doc)
        rows = doc.search(".rowDataOnly > .inputField:nth-child(2)").map { |e| e.inner_text.strip }

        on_notice = extract_notification_period(doc)

        {
          council_reference: rows[2],
          address: rows[0].squeeze(" "),
          description: rows[1],
          date_received: Date.strptime(rows[3], "%d/%m/%Y").to_s,
          on_notice_from: on_notice[:from]&.to_s,
          on_notice_to: on_notice[:to]&.to_s
        }
      end

      def self.extract_event(values, url)
        stage_description = values[1]
        opened = values[2]
        completed_date = values[4]

        case stage_description
        when "Notification to Neighbours",
          "Advert-Went/Courier 30 Days",
          "Notification"
          {
            type: :notification,
            from: Date.strptime(opened, "%d/%m/%Y"),
            to: (Date.strptime(completed_date, "%d/%m/%Y") if completed_date != "")
          }
        when nil
          { type: :ignored }
        when /^Referred /,
          /^Refer /,
          "Referrals",
          "External Referrals",
          "Public Art Referral",
          "No Referrals Required"
          { type: :ignored }
        when "Applic Information Checked",
          "Plans Published on the WMC web",
          "Further Information Requested",
          "Stat Dec- Site Sign Received",
          "Replacement Application No. 1",
          "Adv Completed Objections Rec",
          "Advertised - Wentworth Courier",
          "Ref - SREP(Syd Harbour Cat) 05",
          "Registration",
          "Decision",
          "Determination Letter Posted",
          "Assessment",
          "Waste Co-Ordinator",
          "Information/RequestedApplicant",
          "Advertised  - WMC Website",
          "Advertised - WMC Web & WC",
          "Advert-WentCourier 30 Days",
          "Advert/Notify not required",
          "Assessment and Report Prep",
          "Evaluation",
          "Report to Mgr Dev Assessment"
          { type: :ignored }
        else
          if ENV["MORPH_UNKNOWN_STAGE_DESCRIPTIONS_ARE_FATAL"]
            # If you REALLY want something we don't actually use to be fatal!
            raise "Unknown stage_description: #{stage_description} on #{url}"
          end

          { type: :ignored }
        end
      end

      def self.extract_notification_period(doc)
        table = doc.at("table[summary='Tasks Associated this Development Application']") ||
          doc.at("table[summary='Tasks Associated with this Development Application']")

        events = table.search("tr").map do |tr|
          values = tr.search("td").map(&:inner_text)
          extract_event(values, doc.uri)
        end

        notice_periods = events.select { |e| e[:type] == :notification }

        return {} if notice_periods.empty?

        # Returns the most recent notice period
        notice_periods.max_by { |p| p[:from] }
      end
    end
  end
end
