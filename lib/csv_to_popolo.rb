require 'csv_to_popolo/version'
require 'securerandom'
require 'csv'

class Popolo

  @@model = {
    additional_name: { 
      type: 'asis',
    },
    area: { 
      aliases: %w(constituency region),
    },
    biography: { 
      type: 'asis',
    },
    birth_date: { 
      aliases: %w(dob date_of_birth),
      type: 'asis',
    },
    blog: { 
      type: 'link',
    },
    cell: { 
      aliases: %w(mobile),
      type: 'contact',
    }, 
    chamber: { 
      aliases: %w(house),
    },
    death_date: { 
      type: 'asis',
    },
    email: { 
      type: 'asis',
    },
    end_date: { 
      aliases: %w(end ended until to),
    },
    executive: { 
      aliases: %w(post),
    },
    facebook: { 
      type: 'link',
    },
    family_name: { 
      aliases: %w(last_name surname),
      type: 'asis',
    },
    fax: { 
      aliases: %w(facsimile),
      type: 'contact',
    }, 
    flickr: { 
      type: 'link',
    },
    gender: { 
      type: 'asis',
    },
    given_name: { 
      aliases: %w(first_name forename),
      type: 'asis',
    },
    group: { 
      aliases: %w(party faction faktion bloc block org organization organisation),
    },
    group_id: { 
      # TODO: default
      aliases: %w(party_id faction_id faktion_id bloc_id block_id org_id organization_id organisation_id),
    },
    honorific_prefix: { 
      type: 'asis',
    },
    honorific_suffix: { 
      type: 'asis',
    },
    id: { 
      # TODO: default
      type: 'asis',
    },
    image: { 
      aliases: %w(img picture photo portrait),
      type: 'asis',
    },
    instagram: { 
      type: 'link',
    },
    linkedin: { 
      type: 'link',
    },
    name: { 
      type: 'asis',
    },
    national_identity: { 
      type: 'asis',
    },
    patronymic_name: { 
      type: 'asis',
    },
    phone: { 
      aliases: %w(tel telephone),
      type: 'contact',
    }, 
    sort_name: { 
      type: 'asis',
    },
    start_date: { 
      aliases: %w(start started from since),
    },
    summary: { 
      type: 'asis',
    },
    twitter: { 
      type: 'contact',
    }, 
    website: { 
      type: 'link',
      aliases: %w(homepage href url),
    },
    wikipedia: { 
      type: 'link',
    },
    youtube: { 
      type: 'link',
    },
    
    other_name: { },
  }

  def self.model 
    @@model 
  end

  class CSV

    @@key_map = Popolo.model.find_all { |k, v| v.has_key? :aliases }.map { |k, v| 
      v[:aliases].map { 
        |v| { v => k } 
      } 
    }.flatten.reduce({}, :update)

    @@opts = {
      headers: true,
      header_converters: lambda { |h| 
        # = HeaderConverters.symbol + remapping
        hc = h.encode(::CSV::ConverterEncoding).downcase.gsub(/\s+/, "_").gsub(/\W+/, "")
        (@@key_map[hc] || hc).to_sym
      }
    }

    def initialize(file)
      @raw_csv = ::CSV.read(file, @@opts)
      @csv = @raw_csv.map { |r|
        r[:id] ||= "person/#{SecureRandom.uuid}"
        r.to_hash.select { |_, v| !v.nil? }
      }
    end

    def data
      @data ||= {
        persons:       persons,
        organizations: organizations,
        memberships:   memberships,
        warnings:      warnings,
      }.select { |_,v| !v.nil? }
    end

    def persons
      @csv.map { |r| Person.new(r).as_popolo }
    end

    def organizations
      parties + chambers + legislatures + executive
    end

    def memberships 
      party_memberships + legislative_memberships + executive_memberships
    end

    def parties 
      @_parties ||= @csv.find_all { |r| r.has_key? :group }.uniq { |r| r[:group] }.map do |r| 
        {
          id: r[:group_id] || "party/#{SecureRandom.uuid}",
          name: r[:group],
          classification: 'party',
        }
      end
    end

    def chambers 
      # TODO the chambers should be members of the Legislature
      @_chambers ||= @csv.find_all { |r| r.has_key? :chamber }.uniq { |r| r[:chamber] }.map do |r| 
        {
          id: r[:chamber_id] || "chamber/#{r[:chamber].downcase.gsub(/\s+/,'_')}",
          name: r[:chamber],
          classification: 'chamber',
        }
      end
    end

    def legislatures
      legislative_memberships.count.zero? ? [] : [{
        id: 'legislature',
        name: 'Legislature', 
        classification: 'legislature',
      }]
    end

    def executive
      executive_memberships.count.zero? ? [] : [{
        id: 'executive',
        name: 'Executive', 
        classification: 'executive',
      }]
    end

    def party_memberships 
      @_pmems ||= @csv.find_all { |r| r.has_key? :group }.map do |r|
        { 
          person_id:       r[:id],
          organization_id: r[:group_id] || find_party_id(r[:group]),
          role:            'representative',
        }
      end
    end

    def legislative_memberships 
      @_lmems ||= @csv.find_all { |r| r.has_key? :group }.map do |r|
        mem = { 
          person_id:        r[:id],
          organization_id:  find_chamber_id(r[:chamber]) || "legislature",
          role:             'member',
          start_date:       r[:start_date],
          end_date:         r[:end_date],
        }.select { |_, v| !v.nil? } 
        mem[:area] = { name: r[:area] } if r.has_key? :area and !r[:area].nil?
        mem
      end
    end

    def executive_memberships 
      @_emems ||= @csv.find_all { |r| r.has_key? :executive and !r[:executive].nil? }.map do |r|
        { 
          person_id:        r[:id],
          organization_id:  'executive',
          role:             r[:executive],
        }
      end
    end


    def warnings
      handled = @raw_csv.headers.partition { |got| Popolo.model.has_key? got }
      return if handled.last.count.zero?
      {
        skipped: handled.last,
      }
    end

    private

    def find_party_id(name)
      (parties.find { |p| p[:name] == name } or return)[:id]
    end

    def find_chamber_id(name='Legislature')
      (chambers.find { |p| p[:name] == name } or return)[:id]
    end


  end

  class Person

    def initialize(row)
      @r = row
    end

    def given?(key)
      @r.has_key? key and not @r[key].nil?
    end

    def contact_details
      contact_types = Popolo.model.find_all { |k, v| v[:type] == 'contact' }.map { |k,v| k }
      contacts = contact_types.map { |type|
        if given? type
          {
            type: type.to_s,
            value: @r[type],
          }
        end
      }.compact
      return contacts.length.zero? ? nil : contacts
    end

    def links
      link_types = Popolo.model.find_all { |k, v| v[:type] == 'link' }.map { |k,v| k }
      links = link_types.map { |type|
        if given? type
          {
            url: @r[type],
            note: type.to_s,
          }
        end
      }.compact
      return links.length.zero? ? nil : links
    end

    def as_popolo
      popolo = {}
      as_is = Popolo.model.find_all { |k, v| v[:type] == 'asis' }.map { |k,v| k }
      as_is.each do |sym|
        popolo[sym] = @r[sym] if given? sym
      end

      popolo[:contact_details] = contact_details
      popolo[:links] = links
      popolo[:images] = [{ 
        url: @r[:image],
      }] if @r[:image]

      if given? :other_name
        popolo[:other_names] = [{ name: @r[:other_name] }]
      end

      return popolo.select { |_, v| !v.nil? } 

    end

  end

end
