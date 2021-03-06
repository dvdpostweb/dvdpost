class ProductDvd < ActiveRecord::Base
  set_table_name :products_dvd

  belongs_to :product, :foreign_key => :products_id
  belongs_to :status, :class_name => 'ProductDvdStatus', :foreign_key => :products_dvd_status

  def to_param
    products_dvdid
  end

  def update_status!(new_status)
    old_status = status
    connection.execute("UPDATE products_dvd SET products_dvd_status = #{new_status.to_param}, last_admindate = '#{Time.now.to_s(:db)}' WHERE products_id = #{products_id} AND products_dvdid = #{products_dvdid}")
    ProductDvdStatusHistory.create(:status => new_status,
                                   :user_id => 55,
                                   :old_status => old_status,
                                   :comment => "site (#{new_status.name})",
                                   :product => product,
                                   :product_dvd_id => to_param)
     ProductsDvdStateHistory.create(:status => new_status.to_param,
                                    :user_modified => 0,
                                    :product => product,
                                    :type_process => 8,
                                    :box_id => box_id,
                                    :pibox_id => pibox_id,
                                    :products_dvd_id => to_param)
    true
  end
end
