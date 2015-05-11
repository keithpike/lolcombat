module Api::ItemsHelper
  def fetch_categories
    items =  Rails.cache.fetch("items") do
    	
    end
  end
end
