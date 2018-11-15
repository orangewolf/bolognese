# frozen_string_literal: true

require 'spec_helper'

describe Bolognese::Metadata, vcr: true do
  let(:input) { "https://blog.datacite.org/eating-your-own-dog-food/" }
  let(:fixture_path) { "spec/fixtures/" }

  subject { Bolognese::Metadata.new(input: input) }

  context "get schema_org raw" do
    it "BlogPosting" do
      input = fixture_path + 'schema_org.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.raw).to eq(IO.read(input).strip)
    end
  end

  context "get schema_org metadata" do
    it "BlogPosting" do
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creator).to eq([{"type"=>"Person", "id"=>"https://orcid.org/0000-0003-1419-2405", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.subjects).to eq([{"subject"=>"datacite"}, {"subject"=>"doi"}, {"subject"=>"metadata"}, {"subject"=>"featured"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.publisher).to eq("DataCite")
    end

    it "BlogPosting with new DOI" do
      subject = Bolognese::Metadata.new(input: input, doi: "10.5438/0000-00ss")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/0000-00ss")
      expect(subject.doi).to eq("10.5438/0000-00ss")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
    end

    it "zenodo" do
      input = "https://www.zenodo.org/record/1196821"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.errors.size).to eq(2)
      expect(subject.errors.first).to eq("43:0: ERROR: Element '{http://datacite.org/schema/kernel-4}publisher': [facet 'minLength'] The value has a length of '0'; this underruns the allowed minimum length of '1'.")
      expect(subject.identifier).to eq("https://doi.org/10.5281/zenodo.1196821")
      expect(subject.doi).to eq("10.5281/zenodo.1196821")
      expect(subject.url).to eq("https://zenodo.org/record/1196821")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"PsPM-SC4B: SCR, ECG, EMG, PSR and respiration measurements in a delay fear conditioning task with auditory CS and electrical US"}])
      expect(subject.creator.size).to eq(6)
      expect(subject.creator.first).to eq("type"=>"Person", "id"=>"https://orcid.org/0000-0001-9688-838X", "name"=>"Matthias Staib", "givenName"=>"Matthias", "familyName"=>"Staib")
    end

    it "pangaea" do
      input = "https://doi.pangaea.de/10.1594/PANGAEA.836178"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.1594/pangaea.836178")
      expect(subject.doi).to eq("10.1594/pangaea.836178")
      expect(subject.url).to eq("https://doi.pangaea.de/10.1594/PANGAEA.836178")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"Hydrological and meteorological investigations in a lake near Kangerlussuaq, west Greenland"}])
      expect(subject.creator.size).to eq(8)
      expect(subject.creator.first).to eq("type"=>"Person", "name"=>"Johansson, Emma", "givenName"=>"Emma", "familyName"=>"Johansson")
    end

    # service doesn't return html to script
    # it "ornl daac" do
    #   input = "https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1418"
    #   subject = Bolognese::Metadata.new(input: input, from: "schema_org")
    #   subject.id = "https://doi.org/10.3334/ornldaac/1418"
    #   #expect(subject.errors).to be true
    #   expect(subject.identifier).to eq("https://doi.org/10.3334/ornldaac/1418")
    #   expect(subject.doi).to eq("10.3334/ornldaac/1418")
    #   expect(subject.url).to eq("https://doi.org/10.3334/ornldaac/1418")
    #   expect(subject.type).to eq("DataSet")
    #   expect(subject.title).to eq("AirMOSS: L2/3 Volumetric Soil Moisture Profiles Derived From Radar, 2012-2015")
    #   expect(subject.creator.size).to eq(8)
    #   expect(subject.creator.first).to eq("type"=>"Person", "name"=>"M. MOGHADDAM", "givenName"=>"M.", "familyName"=>"MOGHADDAM")
    # end

    it "harvard dataverse" do
      input = "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NJ7XSO"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7910/dvn/nj7xso")
      expect(subject.doi).to eq("10.7910/dvn/nj7xso")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"Summary data ankylosing spondylitis GWAS"}])
      expect(subject.periodical).to eq("title"=>"Harvard Dataverse", "type"=>"DataCatalog", "url"=>"https://dataverse.harvard.edu")
      expect(subject.creator).to eq([{"name" => "International Genetics Of Ankylosing Spondylitis Consortium (IGAS)"}])
      expect(subject.schema_version).to eq("https://schema.org/version/3.3")
    end

    it "harvard dataverse via identifiers.org" do
      input = "https://identifiers.org/doi/10.7910/DVN/NJ7XSO"
      subject = Bolognese::Metadata.new(input: input, from: "schema_org")
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.7910/dvn/nj7xso")
      expect(subject.doi).to eq("10.7910/dvn/nj7xso")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.titles).to eq([{"title"=>"Summary data ankylosing spondylitis GWAS"}])
      expect(subject.periodical).to eq("title"=>"Harvard Dataverse", "type"=>"DataCatalog", "url"=>"https://dataverse.harvard.edu")
      expect(subject.creator).to eq([{"name" => "International Genetics Of Ankylosing Spondylitis Consortium (IGAS)"}])
    end
  end

  context "get schema_org metadata as string" do
    it "BlogPosting" do
      input = fixture_path + 'schema_org.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.5438/4k3m-nyvg")
      expect(subject.url).to eq("https://blog.datacite.org/eating-your-own-dog-food")
      expect(subject.types).to eq("bibtex"=>"article", "citeproc"=>"post-weblog", "resourceTypeGeneral"=>"Text", "ris"=>"GEN", "schemaOrg"=>"BlogPosting")
      expect(subject.creator).to eq([{"type"=>"Person", "id"=>"http://orcid.org/0000-0003-1419-2405", "name"=>"Martin Fenner", "givenName"=>"Martin", "familyName"=>"Fenner"}])
      expect(subject.titles).to eq([{"title"=>"Eating your own Dog Food"}])
      expect(subject.descriptions.first["description"]).to start_with("Eating your own dog food")
      expect(subject.subjects).to eq([{"subject"=>"datacite"}, {"subject"=>"doi"}, {"subject"=>"metadata"}, {"subject"=>"featured"}])
      expect(subject.dates).to eq([{"date"=>"2016-12-20", "dateType"=>"Issued"}, {"date"=>"2016-12-20", "dateType"=>"Created"}, {"date"=>"2016-12-20", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2016")
      expect(subject.related_identifiers.length).to eq(3)
      expect(subject.related_identifiers.last).to eq("relatedIdentifier"=>"10.5438/55e5-t5c0", "relatedIdentifierType"=>"DOI", "relationType"=>"References")
      expect(subject.publisher).to eq("DataCite")
    end

    it "GTEx dataset" do
      input = fixture_path + 'schema_org_gtex.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.25491/d50j-3083")
      expect(subject.alternate_identifiers).to eq([{"alternateIdentifier"=>"687610993", "alternateIdentifierType"=>"md5"}])
      expect(subject.url).to eq("https://ors.datacite.org/doi:/10.25491/d50j-3083")
      expect(subject.content_url).to eq(["https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL_expression_matrices.tar.gz"])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"Gene expression matrices", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creator).to eq([{"name"=>"The GTEx Consortium", "type"=>"Organization"}])
      expect(subject.titles).to eq([{"title"=>"Fully processed, filtered and normalized gene expression matrices (in BED format) for each tissue, which were used as input into FastQTL for eQTL discovery"}])
      expect(subject.version).to eq("v7")
      expect(subject.subjects).to eq([{"subject"=>"gtex"}, {"subject"=>"annotation"}, {"subject"=>"phenotype"}, {"subject"=>"gene regulation"}, {"subject"=>"transcriptomics"}])
      expect(subject.dates).to eq([{"date"=>"2017", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.periodical).to eq("title"=>"GTEx", "type"=>"DataCatalog")
      expect(subject.publisher).to eq("GTEx")
      expect(subject.funding_references.length).to eq(7)
      expect(subject.funding_references.first).to eq("funderIdentifier"=>"https://doi.org/10.13039/100000052", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"Common Fund of the Office of the Director of the NIH")
    end

    it "TOPMed dataset" do
      input = fixture_path + 'schema_org_topmed.json'
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.23725/8na3-9s47")
      expect(subject.alternate_identifiers).to eq([{"alternateIdentifier"=>"3b33f6b9338fccab0901b7d317577ea3","alternateIdentifierType"=>"md5"},{"alternateIdentifier"=>"ark:/99999/fk41CrU4eszeLUDe","alternateIdentifierType"=>"minid"},{"alternateIdentifier"=>"dg.4503/c3d66dc9-58da-411c-83c4-dd656aa3c4b7", "alternateIdentifierType"=>"dataguid"}])
      expect(subject.url).to eq("https://ors.datacite.org/doi:/10.23725/8na3-9s47")
      expect(subject.content_url).to eq(["s3://cgp-commons-public/topmed_open_access/197bc047-e917-55ed-852d-d563cdbc50e4/NWD165827.recab.cram", "gs://topmed-irc-share/public/NWD165827.recab.cram"])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"CRAM file", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creator).to eq([{"name"=>"TOPMed IRC", "type"=>"Organization"}])
      expect(subject.titles).to eq([{"title"=>"NWD165827.recab.cram"}])
      expect(subject.subjects).to eq([{"subject"=>"topmed"}, {"subject"=>"whole genome sequencing"}])
      expect(subject.dates).to eq([{"date"=>"2017-11-30", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("TOPMed")
      expect(subject.related_identifiers).to eq([{"relatedIdentifier"=>"10.23725/2g4s-qv04", "relatedIdentifierType"=>"DOI", "relationType"=>"References", "resourceTypeGeneral"=>"Dataset"}])
      expect(subject.funding_references).to eq([{"funderIdentifier"=>"https://doi.org/10.13039/100000050", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"National Heart, Lung, and Blood Institute (NHLBI)"}])
    end

    it "geolocation" do
      input = fixture_path + 'schema_org_geolocation.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.6071/z7wc73")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creator.length).to eq(6)
      expect(subject.creator.first).to eq("familyName"=>"Bales", "givenName"=>"Roger", "name"=>"Roger Bales", "type"=>"Person")
      expect(subject.titles).to eq([{"title"=>"Southern Sierra Critical Zone Observatory (SSCZO), Providence Creek meteorological data, soil moisture and temperature, snow depth and air temperature"}])
      expect(subject.subjects).to eq([{"subject"=>"Earth sciences"},
        {"subject"=>"soil moisture"},
        {"subject"=>"soil temperature"},
        {"subject"=>"snow depth"},
        {"subject"=>"air temperature"},
        {"subject"=>"water balance"},
        {"subject"=>"Nevada"},
        {"subject"=>"Sierra (mountain range)"}])
      expect(subject.dates).to eq([{"date"=>"2013", "dateType"=>"Issued"}, {"date"=>"2014-10-17", "dateType"=>"Updated"}])
      expect(subject.publication_year).to eq("2013")
      expect(subject.publisher).to eq("UC Merced")
      expect(subject.funding_references).to eq([{"funderName"=>"National Science Foundation, Division of Earth Sciences, Critical Zone Observatories"}])
      expect(subject.geo_locations).to eq([{"geoLocationPlace"=>"Providence Creek (Lower, Upper and P301)", "geoLocationPoint"=>{"pointLatitude"=>"37.047756", "pointLongitude"=>"-119.221094"}}])
    end

    it "geolocation geoshape" do
      input = fixture_path + 'schema_org_geoshape.json'
      subject = Bolognese::Metadata.new(input: input)

      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.1594/pangaea.842237")
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creator.length).to eq(2)
      expect(subject.creator.first).to eq("name"=>"Tara Oceans Consortium, Coordinators", "type"=>"Organization")
      expect(subject.titles).to eq([{"title"=>"Registry of all stations from the Tara Oceans Expedition (2009-2013)"}])
      expect(subject.dates).to eq([{"date"=>"2015-02-03", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2015")
      expect(subject.publisher).to eq("PANGAEA")
      expect(subject.geo_locations).to eq([{"geoLocationBox"=>{"eastBoundLongitude"=>"174.9006", "northBoundLatitude"=>"79.6753", "southBoundLatitude"=>"-64.3088", "westBoundLongitude"=>"-168.5182"}}])
    end

    it "schema_org list" do
      data = IO.read(fixture_path + 'schema_org_list.json').strip
      input = JSON.parse(data).first.to_json
      subject = Bolognese::Metadata.new(input: input)
      expect(subject.valid?).to be true
      expect(subject.identifier).to eq("https://doi.org/10.23725/7jg3-v803")
      expect(subject.alternate_identifiers).to eq([{"alternateIdentifier"=>"ark:/99999/fk4E1n6n1YHKxPk","alternateIdentifierType"=>"minid"},{"alternateIdentifier"=>"dg.4503/01b048d0-e128-4cb0-94e9-b2d2cab7563d","alternateIdentifierType"=>"dataguid"},{"alternateIdentifier"=>"f9e72bdf25bf4b4f0e581d9218fec2eb","alternateIdentifierType"=>"md5"}])
      expect(subject.url).to eq("https://ors.datacite.org/doi:/10.23725/7jg3-v803")
      expect(subject.content_url).to eq(["s3://cgp-commons-public/topmed_open_access/44a8837b-4456-5709-b56b-54e23000f13a/NWD100953.recab.cram","gs://topmed-irc-share/public/NWD100953.recab.cram","dos://dos.commons.ucsc-cgp.org/01b048d0-e128-4cb0-94e9-b2d2cab7563d?version=2018-05-26T133719.491772Z"])
      expect(subject.types).to eq("bibtex"=>"misc", "citeproc"=>"dataset", "resourceType"=>"CRAM file", "resourceTypeGeneral"=>"Dataset", "ris"=>"DATA", "schemaOrg"=>"Dataset")
      expect(subject.creator).to eq([{"name"=>"TOPMed", "type"=>"Organization"}])
      expect(subject.titles).to eq([{"title"=>"NWD100953.recab.cram"}])
      expect(subject.subjects).to eq([{"subject"=>"topmed"}, {"subject"=>"whole genome sequencing"}])
      expect(subject.dates).to eq([{"date"=>"2017-11-30", "dateType"=>"Issued"}])
      expect(subject.publication_year).to eq("2017")
      expect(subject.publisher).to eq("TOPMed")
      expect(subject.funding_references).to eq([{"funderIdentifier"=>"https://doi.org/10.13039/100000050", "funderIdentifierType"=>"Crossref Funder ID", "funderName"=>"National Heart, Lung, and Blood Institute (NHLBI)"}])
    end
  end
end
