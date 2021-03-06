require 'mongoid'

module MongoidDates
  extend ActiveSupport::Concern

  included do
    field :start_date, type: String
    field :end_date, type: String
    field :is_current, type: Boolean

    # before_save :rationalize_fields

    def current?
      is_current
    end
    
    def rationalize_fields
      is_current = !(end_date <= Date.today.to_s)
    end
  end
end