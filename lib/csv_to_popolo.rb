require 'csv_to_popolo/version'
require 'smarter_csv'
require 'securerandom'

class Popolo
  class CSV

    @@opts = { 
      convert_values_to_numeric: false,
      row_sep: :auto,
      key_mapping: {
        first_name: :given_name,
        last_name: :family_name,
        org: :group,
        org_id: :group,
        organization: :group,
        organisation: :group,
        organization_id: :group_id,
        organisation_id: :group_id,
        faction: :group,
        faction_id: :group_id,
        party: :group,
        party_id: :group_id,
        bloc: :group,
        bloc_id: :group_id,
        mobile: :cell,
        post: :executive,
        constituency: :area,
        region: :area,
        dob: :birth_date,
        img: :image,
        picture: :image,
        photo: :image,
      },
    }
    
    def initialize(file)
      # Ugh.
      f = File.open(file, "r:bom|utf-8"); 
      @csv = SmarterCSV.process(f, @@opts); 
      f.close
      @csv.each { |r| r[:id] ||= "person/#{SecureRandom.uuid}" }
    end

    def data
      @data ||= {
        persons:       persons,
        organizations: organizations,
        memberships:   memberships,
      }
    end

    def persons
      @csv.map { |r| Person.new(r).as_popolo }
    end

    def organizations
      parties + legislatures + executive
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

    # For now, assume that we always have a legislature
    # TODO cope with a file that *only* lists executive posts
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
          organization_id:  'legislature',
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


    private

    def find_party_id(name)
      (parties.find { |p| p[:name] == name } or return)[:id]
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
      contacts = %w(phone cell fax twitter).map { |type|
        if given? type.to_sym
          {
            type: type,
            value: @r[type.to_sym],
          }
        end
      }.compact
      return contacts.length.zero? ? nil : contacts
    end

    def as_popolo
      as_is = [
        :id, :name, :family_name, :given_name, :additional_name, 
        :honorific_prefix, :honorific_suffix, :patronymic_name, :sort_name,
        :email, :gender, :birth_date, :death_date, :image, :summary,
        :biography, :national_identity
      ]

      popolo = {}
      as_is.each do |sym|
        popolo[sym] = @r[sym] if given? sym
      end

      popolo[:contact_details] = contact_details
      popolo[:images] = [{ url: @r[:image] }] if @r[:image]

      if given? :other_name
        popolo[:other_names] = [{ name: @r[:other_name] }]
      end

      return popolo.select { |_, v| !v.nil? } 

    end

  end

end
