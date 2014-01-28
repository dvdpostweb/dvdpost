class DomiciliationsController < ApplicationController
  def new
    respond_to do |format|
      format.pdf do
        
        if current_customer.customers_edd
          mandate_id = current_customer.customers_edd.edd_mandate_id
          current_customer.abo_history(34, current_customer.next_abo_type_id)
        else
          mandate = CustomersEdd.create(:edd_mandate_id => "#{current_customer.to_param}#{Time.now.strftime('%Y%m%d')}", :create_date => Date.today, :last_update => Date.today, :customers_id => current_customer.to_param, :volgnr => '', :reference => '')
          mandate_id = mandate.edd_mandate_id
          current_customer.abo_history(35, current_customer.next_abo_type_id)
        end
        
        filename = "#{RAILS_ROOT}/public/mandate_standard__core__#{I18n.locale}.pdf"
        at = case I18n.locale
          when :fr
            [54, 501]
          when :nl
            [54, 516]
          else
            [54, 516]
        end
        pdf = Prawn::Document.new(:template => filename) do
          go_to_page(2)
          character_spacing(5.7) do
              text_box mandate_id, :at => at, :size => 12, :kerning => true
          end
          go_to_page(3)
          character_spacing(5.7) do
              text_box mandate_id, :at => at, :size => 12, :kerning => true
          end
        end
        send_data pdf.render, :filename => 'dvdpost_european_domiciliation.pdf'
      end
    end
  end

end