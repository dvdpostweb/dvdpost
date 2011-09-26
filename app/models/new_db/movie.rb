class Movie < ActiveRecord::Base
    establish_connection "development2"

    belongs_to :director, :primary_key => :id
    
    #belongs_to :studio, :foreign_key => :products_studio
    #belongs_to :country, :class_name => 'ProductCountry', :foreign_key => :products_countries_id
    #belongs_to :picture_format, :foreign_key => :products_picture_format, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
    #has_one :public, :primary_key => :products_public, :foreign_key => :public_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
    has_many :descriptions, :class_name => 'MovieDescription'
    has_and_belongs_to_many :actors
    has_and_belongs_to_many :categories
    has_many :products
    #has_and_belongs_to_many :product_lists, :join_table => :listed_products, :order => 'listed_products.order asc'
    #has_and_belongs_to_many :soundtracks, :join_table => :products_to_soundtracks, :foreign_key => :products_id, :association_foreign_key => :products_soundtracks_id
    
#   define_index do
 #     indexes descriptions.name,  :as => :descriptions_text
 #     indexes director.name,            :as => :director_name
 #     indexes actors.name,                 :as => :actors_name
 #
 #     has categories(:id), :as => :category_id
 #
 #     set_property :enable_star => true
 #     set_property :min_prefix_len => 3
 #     set_property :charset_type => 'sbcs'
 #     set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
 #     set_property :ignore_chars => "U+AD"
 #     #set_property :field_weights => {:brand_name => 10, :name_fr => 5, :name_nl => 5, :description_fr => 4, :description_nl => 4}
 #   end
 #   
 #   sphinx_scope(:by_actor)           {|actor|            {:with =>       {:actors_id => actor.to_param}}}
 #   sphinx_scope(:by_category)        {|category|         {:with =>       {:category_id => category.to_param}}}
  end
