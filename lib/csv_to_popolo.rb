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

    private 
    def popolo_for(r)

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

      remap.each { |old, new| r[new] ||= r[old] if r.has_key? old }

      popolo = {}
      as_is.each do |sym|
        popolo[sym] = r[sym] if r.has_key? sym and not r[sym].nil?
      end

      if r.has_key? :group and not r[:group].nil?
        membership = { organization: { name: r[:group] } }
        membership[:area] = { name: r[:area] } if r.has_key? :area and not r[:area].nil?
        popolo[:memberships] = [ membership ]
      end

      return popolo

    end

  end

end
