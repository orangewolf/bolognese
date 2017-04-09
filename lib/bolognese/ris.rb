module Bolognese
  class Ris < Metadata

    BIB_TO_SO_TRANSLATIONS = {
      "article" => "ScholarlyArticle"
    }

    SO_TO_BIB_TRANSLATIONS = {
      "Article" => "article",
      "AudioObject" => "misc",
      "Blog" => "misc",
      "BlogPosting" => "article",
      "Collection" => "misc",
      "CreativeWork" => "misc",
      "DataCatalog" => "misc",
      "Dataset" => "misc",
      "Event" => "misc",
      "ImageObject" => "misc",
      "Movie" => "misc",
      "PublicationIssue" => "misc",
      "ScholarlyArticle" => "article",
      "Service" => "misc",
      "SoftwareSourceCode" => "misc",
      "VideoObject" => "misc",
      "WebPage" => "misc",
      "WebSite" => "misc"
    }

    BIB_TO_CP_TRANSLATIONS = {
      "article" => "article-journal"
    }

    def initialize(string: nil)
      @raw = string
    end

    def metadata
      @metadata ||= raw.present? ? BibTeX.parse(raw).first : {}
    end

    def exists?
      metadata.present?
    end

    def valid?
      bibtex.present?
    end

    def type
      BIB_TO_SO_TRANSLATIONS[metadata.type.to_s] || "ScholarlyArticle"
    end

    def citeproc_type
      BIB_TO_CP_TRANSLATIONS[metadata.type.to_s] || "misc"
    end

    def resource_type_general
      SO_TO_DC_TRANSLATIONS[type]
    end

    def doi
      metadata.doi
    end

    def url
      metadata.url
    end

    def id
      normalize_doi(doi)
    end

    def author
      Array(metadata.author).map do |a|
        { "@type" => "Person",
          "givenName" => a.first,
          "familyName" => a.last }.compact
      end
    end

    def title
      metadata.title
    end

    def container_title
      metadata.journal.to_s.presence || metadata.publisher.to_s
    end

    alias_method :journal, :container_title

    def date_published
      metadata.date.to_s.presence
    end

    def publication_year
      metadata.year.to_s.presence
    end

    def is_part_of
      if metadata.journal.present?
        { "type" => "Periodical",
          "name" => metadata.journal.to_s,
          "issn" => metadata.issn.to_s.presence }.compact
      else
        nil
      end
    end

    def description
      { "text" => metadata.field?(:abstract) && metadata.abstract.to_s.presence }
    end

    def license
      { "id" => metadata.field?(:copyright) && metadata.copyright.to_s.presence }
    end
  end
end
