class Director < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']

  set_primary_key :directors_id

  alias_attribute :name, :directors_name
  alias_attribute :birth_at, :directors_dateofbirth

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true, :cache_column => 'cached_slug' 

  has_many :products, :foreign_key => :products_directors_id
  
  define_index do
    indexes directors_name,                 :as => :directors_name, :sortable => true

    set_property :enable_star => true
    set_property :min_prefix_len => 3
    set_property :charset_type => 'sbcs'
    set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
    set_property :ignore_chars => "U+AD"
    set_property :field_weights => {:directors_name => 5}
  end

  def image(number = 1)
    if image_active
      File.join(DVDPost.images_path, "directors", "#{id}.jpg")
    else
      '/images/no_picture.jpg'
    end
  end

  # There are a lot of commented lines of code in here which are just used for development
  # Once all scopes are transformed to Thinking Sphinx scopes, it will be cleaned up.
  sphinx_scope(:order)              {|order, sort_mode| {:order => order, :sort_mode => sort_mode}}
  sphinx_scope(:group)              {|group,sort|       {:group_by => group, :group_function => :attr, :group_clause   => sort}}
  sphinx_scope(:limit)              {|limit|            {:limit => limit}}

  def self.search_clean(query_string, count = false)
    qs = []
    if query_string
      qs = query_string.split.collect do |word|
        "*#{replace_specials(word)}*".gsub(/[-_]/, ' ')
      end
    end
    query_string = qs.join(' ')
    if count
      self.search.search_count(query_string.gsub(/[-_]/, ' '), :max_matches => 1000, :order => :directors_name, :match_mode => :extended)
    else
      self.search.search(query_string.gsub(/[-_]/, ' '), :max_matches => 1000, :order => :directors_name, :match_mode => :extended)
    end
  end
  
  def self.replace_specials(str)
    #str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s
    str
  end

  def human_birth
    if birth_at
      str = "<b>Né(e) le :</b> #{birth_at.strftime('%d/%m/%Y') } #{}"
      str += " à #{birth_place}<br>" if birth_place
    end
    str
  end

  def human_death
    if death_at
      str = "<b>décédé(e) le :</b> #{death_at.strftime('%d/%m/%Y') }"
      str += " à #{death_place}<br>" if death_place
    end
    str
  end

end
