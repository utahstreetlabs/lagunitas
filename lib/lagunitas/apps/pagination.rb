require 'active_support/concern'

module Lagunitas
  module Pagination
    extend ActiveSupport::Concern

    # Returns the paged query options that were provided as the +page+ and +per+ request parameters.
    #
    # @return [Hash]
    def pagination_params
      page = params[:page].to_i
      page = 1 unless page > 0
      per = params[:per].to_i
      per = 25 unless per > 0
      {page: page, per: per}
    end

    def paged_query?
      params[:page].present? || params[:per].present?
    end
  end
end
