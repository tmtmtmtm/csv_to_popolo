require 'csv_to_popolo/version'
require 'csv'

VERSION = "0.0.1"

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
      {
        id: r[:id],
        name: r[:name],
        image: r[:img],
        email: r[:email],
        memberships: [
          {
            organization: { 
              name: r[:faction],
            },
            area: { 
              name: r[:area],
            },
          }
        ],
      }
    end

  end

end
