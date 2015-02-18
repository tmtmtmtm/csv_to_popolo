require 'csv_to_popolo/version'
require 'csv'
require 'securerandom'

class Popolo
  class CSV

    @@opts = { 
      headers:           true,
      converters:        :numeric,
      header_converters: :symbol 
    }
    
    def initialize(csv)
      raise "Need a CSV table, not a #{csv.class}" unless csv.class.name == 'CSV::Table'
      @csv = csv
    end

    def self.from_file(file)
      new ::CSV.read(file, @@opts)
    end

    def self.from_data(data)
      new ::CSV.parse(data, @@opts)
    end

    # http://stackoverflow.com/questions/5490952/merge-array-of-hashes-to-get-hash-of-arrays-of-values
    def data
      @data ||= {}.tap { |r| uncombined_data.each { |h| h.each{ |k,v| (r[k]||=[]).concat v } } }
    end

    private

    def popolo_for(r)
      Record.new(r).as_popolo
    end

    def uncombined_data 
      @csv.map { |r| popolo_for(r) }
    end


  end

  class Record

    def initialize(row)
      @r = row
      @r[:id] = "person/#{SecureRandom.uuid}" unless given? :id
    end

    def given?(key)
      @r.has_key? key and not @r[key].nil?
    end


    def memberships
      mems = []
      mems << legislature
      mems << party_membership if party
      mems
    end

    def organizations
      [party].compact
    end

    def legislature
      membership = { 
        # TODO way to provide name of legislature
        person_id:        @r[:id],
        organization_id:  'legislature',
        role:             'representative',
      }
      membership[:area] = { name: @r[:area] } if given? :area
      return membership
    end

    def party
      return unless given? :group
      @party ||= { 
        id: "party/#{SecureRandom.uuid}",
        name: @r[:group],
        classification: 'party',
      }
    end

    def party_membership
      org = party or return
      @party_membership ||= { 
        role:  'party representative',
        person_id: @r[:id],
        organization_id: org[:id],
      }
    end

    def contact_details
      return unless given? :twitter
      twitter = { 
        type: 'twitter',
        value: @r[:twitter],
      }
      return [ twitter ]
    end

    def person
      as_is = [
        :id, :name, :family_name, :given_name, :additional_name, 
        :honorific_prefix, :honorific_suffix, :patronymic_name, :sort_name,
        :email, :gender, :birth_date, :death_date, :image, :summary,
        :biography, :national_identity
      ]

      remap = { 
        first_name: :given_name,
        last_name: :family_name,
        organization: :group,
        organisation: :group,
      }

      remap.each { |old, new| @r[new] ||= @r[old] if given? old }

      popolo = {}
      as_is.each do |sym|
        popolo[sym] = @r[sym] if given? sym
      end

      popolo[:contact_details] = contact_details

      if given? :other_name
        popolo[:other_names] = [ @r[:other_name] ]
      end

      return popolo.select { |_, v| !v.nil? } 

    end

    def as_popolo
      return {
        persons: [ person ],
        organizations: organizations,
        memberships: memberships,
      }
    end

  end

end
