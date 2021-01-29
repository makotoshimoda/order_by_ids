require 'order_by_ids/version'
require 'order_by_ids/error'

module OrderByIds
  # Order model by array of ids.
  #
  # ==== Returns
  # * <tt>ActiveRecord</tt>
  def order_by_ids(ids)
    return order(:id) if ids.blank?

    order_by = ['CASE']
    ids.each_with_index do |id, index|
      order_by << "WHEN #{name.downcase.pluralize}.id='#{id}' THEN #{index}"
    end

    order_by << 'END'
    order(order_by.join(' '))
  end
end
