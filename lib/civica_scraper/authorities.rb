# frozen_string_literal: true

module CivicaScraper
  AUTHORITIES = {
    bayside: {
      url: "https://ecouncil.bayside.vic.gov.au/eservice/daEnquiryInit.do?nodeNum=480390",
      period: :last30days
    },
    bunbury: {
      url: "https://ecouncil.bunbury.wa.gov.au/eservice/daEnquiryInit.do?nodeNum=11264",
      period: :last30days,
      australian_proxy: true
    },
    burwood: {
      url: "https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=219",
      period: :last7days,
      # Looks like they're geoblocking non australian web requests. Sigh.
      australian_proxy: true
    },
    cairns: {
      url: "https://eservices.cairns.qld.gov.au/eservice/daEnquiryInit.do?nodeNum=227",
      period: :last30days
    },
    dorset: {
      url: "https://eservices.dorset.tas.gov.au/eservice/daEnquiryInit.do?nodeNum=12238",
      period: :last30days
    },
    lane_cove: {
      url: "https://ecouncil.lanecove.nsw.gov.au/eservice/dialog/daEnquiryInit.do?doc_type=8&nodeNum=6636",
      period: :last30days,
      notice_period: true,
      australian_proxy: true
    },
    nambucca: {
      url:
        "https://eservices.nambucca.nsw.gov.au/eservice/daEnquiryInit.do?doc_typ=10&nodeNum=2811",
      period: :last10days,
      # Because of incomplete certificate chain
      disable_ssl_certificate_check: true
    },
    orange: {
      url: "https://ecouncil.orange.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=24",
      period: :last30days,
      australian_proxy: true
    },
    vincent: {
      url: "https://eservices.vincent.wa.gov.au/eservice/daEnquiryInit.do?doc_typ=5&nodeNum=8053",
      period: :last30days
    },
    wanneroo: {
      url: "https://eservice.wanneroo.wa.gov.au/eservice/daEnquiry.do?nodeNum=8047",
      period: :last30days,
      # Because of incomplete certificate chain
      disable_ssl_certificate_check: true
    },
    whittlesea: {
      url:
        "https://eservice.whittlesea.vic.gov.au/eservice/daEnquiryInit.do?doc_typ=5&nodeNum=21161",
      period: :last30days
    },
    woollahra: {
      url: "https://auth.woollahra.nsw.gov.au/eservice/daEnquiryInit.do?nodeNum=5270",
      period: :advertised,
      notice_period: true
    }
  }.freeze
end
