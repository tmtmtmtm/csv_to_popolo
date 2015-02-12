require 'csv_to_popolo/version'
require 'csv'

class Popolo
  class CSV
    
    def initialize(file)
      @file = file
      @csv_args = { :headers => true }
    end

    def data
      ::CSV.table(@file, @csv_args).map { |r| popolo_for(r) }
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
      return unless given? :group
      membership = { organization: { name: @r[:group] } }
      membership[:area] = { name: @r[:area] } if given? :area
      return [ membership ]
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
