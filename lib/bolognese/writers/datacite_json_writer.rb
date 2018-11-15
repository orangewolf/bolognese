module Bolognese
  # frozen_string_literal: true
  
  module Writers
    module DataciteJsonWriter
      def datacite_json
        hsh = {
          "id" => identifier,
          "doi" => doi,
          "url" => url,
          "creator" => creator,
          "titles" => titles,
          "publisher" => publisher,
          "periodical" => periodical,
          "types" => to_datacite_json(types, first: true),
          "subjects" => to_datacite_json(subjects),
          "contributor" => contributor,
          "dates" => to_datacite_json(dates),
          "publicationYear" => publication_year,
          "language" => language,
          "alternateIdentifiers" => to_datacite_json(alternate_identifiers),
          "relatedIdentifiers" => to_datacite_json(related_identifiers),
          "sizes" => sizes,
          "formats" => formats,
          "version" => version,
          "rightsList" => to_datacite_json(rights_list),
          "descriptions" => to_datacite_json(descriptions),
          "geoLocations" => to_datacite_json(geo_locations),
          "fundingReferences" => to_datacite_json(funding_references),
          "schemaVersion" => schema_version,
          "providerId" => provider_id,
          "clientIsd" => client_id,
          "source" => source
        }.compact
        JSON.pretty_generate hsh.presence
      end
    end
  end
end
