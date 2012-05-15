class ActivationAction < ActiveRecord::Base
  belongs_to :activation_class, :foreign_key => :class_id
  
  def action_gfc(son_id)
    sponsor = Sponsorship.find_by_son_id(son_id.to_param)
    unless sponsor
      father = Customer.find(self.customer_id)
      if father.actived?
        Sponsorship.create(:created_at => Time.now.localtime, :father_id => father.to_param, :son_id => son_id.to_param , :points => 0, :expected_points => 400)
        options = {
          "\\$\\$\\$godfather_name\\$\\$\\$" => "#{father.first_name.capitalize} #{father.last_name.capitalize}", 
          "\\$\\$\\$son_name\\$\\$\\$" => "#{son_id.first_name.capitalize} #{son_id.last_name.capitalize}",
          "\\$\\$\\$godfather_point\\$\\$\\$" => father.inviation_points
          }
          send_message(DVDPost.email[:sponsorships_son], options, father)
      end
    end
  end
end