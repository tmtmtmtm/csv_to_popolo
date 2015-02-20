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
      # Make sure every row has an ID
      @csv = csv.map do |r| 
        r[:id] ||= "person/#{SecureRandom.uuid}" 
        r
      end
    end

    def self.from_file(file)
      new ::CSV.read(file, @@opts)
    end

    def self.from_data(data)
      new ::CSV.parse(data, @@opts)
    end

    def data
      @data ||= {
        persons:       uncombined_data.flat_map { |r| r[:persons] }.uniq,
        organizations: organizations,
        memberships:   memberships,
      }
    end

    def organizations
      parties + legislatures
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

    # For now, assume that we always have a legislature
    # TODO cope with a file that *only* lists executive posts
    def legislatures
      [{
        id: 'legislature',
        name: 'Legislature', 
        classification: 'legislature',
      }]
    end

    def memberships 
      party_memberships + legislative_memberships
    end

    def party_memberships 
      @_pmems ||= @csv.find_all { |r| r.has_key? :group }.map do |r|
        { 
          person_id: r[:id],
          organization_id: r[:group_id] || find_party_id(r[:group]),
          role: 'party representative',
        }
      end
    end

    def legislative_memberships 
      @_lmems ||= @csv.find_all { |r| r.has_key? :group }.map do |r|
        { 
          person_id:        r[:id],
          organization_id:  'legislature',
          role:             'representative',
        }
      end
    end




    private

    def find_party_id(name)
      (parties.find { |p| p[:name] == name } or return)[:id]
    end

    def popolo_for(r)
      Record.new(r).as_popolo
    end

    def uncombined_data 
      @uc ||= @csv.map { |r| popolo_for(r) }
    end


  end

  class Record

    @@orgs = {}

    def initialize(row)
      @r = row
      @r[:id] = "person/#{SecureRandom.uuid}" unless given? :id
    end

    def given?(key)
      @r.has_key? key and not @r[key].nil?
    end


    def memberships
      mems = []
      mems << legislature_membership
      mems << party_membership if party
      mems
    end

    def organizations
      [legislature, party].compact
    end

    def legislature
      # TODO way to provide name of legislature
      @@orgs['legislature'] ||= {
        id: 'legislature',
        name: 'Legislature',
        classification: 'legislature',
      }
    end

    def legislature_membership
      membership = { 
        person_id:        @r[:id],
        organization_id:  'legislature',
        role:             'representative',
      }
      membership[:area] = { name: @r[:area] } if given? :area
      return membership
    end

    def find_or_create_party(name)
      @@orgs[name] ||= {
        id: @r[:group_id] || "party/#{SecureRandom.uuid}",
        name: @r[:group],
        classification: 'party',
      }
    end

    def party
      return unless given? :group
      @party ||= find_or_create_party(@r[:group])
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
