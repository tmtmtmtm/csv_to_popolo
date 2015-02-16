require 'csv_to_popolo/version'
require 'csv'

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

    def data
      { persons: @csv.map { |r| popolo_for(r) } }
    end


    def popolo_for(r)
      Record.new(r).as_popolo
    end

  end

  class Record

    def initialize(row)
      @r = row
    end

    def given?(key)
      @r.has_key? key and not @r[key].nil?
    end


    def memberships
      (mems ||= []) << legislature 
      (mems ||= []) << party       if given? :group
      return mems
    end

    def legislature
      membership = { 
        # TODO way to provide name of legislature
        organization_id:  'legislature',
        role:             'representative',
      }
      membership[:area] = { name: @r[:area] } if given? :area
      return membership
    end

    def party
      return unless given? :group
      membership = { 
        role:          'party representative',
        organization:  { 
          name: @r[:group],
          classification: 'party',
        } 
      }
      return membership
    end

    def contact_details
      return unless given? :twitter
      twitter = { 
        type: 'twitter',
        value: @r[:twitter],
      }
      return [ twitter ]
    end


    def as_popolo
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

      popolo[:memberships] = memberships
      popolo[:contact_details] = contact_details

      if given? :other_name
        popolo[:other_names] = [ @r[:other_name] ]
      end

      return popolo.select { |_, v| !v.nil? }

    end

  end

end
