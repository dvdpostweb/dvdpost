#############################################################
#	Application
#############################################################

set :application, "dvdpostapp"
set :deploy_to, "/home/webapps/dvdpostapp/staging"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :scm_verbose, true
set :rails_env, "staging" 

#############################################################
#	Servers
#############################################################

set :user, "dvdpostapp"
set :domain,  "217.112.190.50"
set :port, 23051
role :web, domain
role :app, domain
role :db, domain, :primary => true

#############################################################
#	Git
#############################################################

set :scm, :git
set :branch, "production"
set :scm_user, 'dvdpost'
set :scm_passphrase, "[y'|\E7U158]9*"
set :repository, "git@github.com:dvdpost/dvdpost.git"
set :deploy_via, :remote_cache

#############################################################
#	Passenger
#############################################################

namespace :deploy do
  desc "Create the database yaml file"
  after "deploy:update_code" do
    db_config = <<-EOF
    common_staging:
     adapter: mysql
     encoding: utf8
     database: common_staging
     username: webuser
     password: 3gallfir-
     host: matadi
     port: 3306
    staging:
      adapter: mysql
      encoding: utf8
      database: dvdpost_test
      username: webuser
      password: 3gallfir-
      host: 192.168.100.204
      port: 3306
      slave01:
        adapter: mysql
        encoding: utf8
        database: dvdpost_test
        username: webuser
        password: 3gallfir-
        host: 192.168.100.204
        port: 3306
      slave02:
        adapter: mysql
        encoding: utf8
        database: dvdpost_test
        username: webuser
        password: 3gallfir-
        host: 192.168.100.204
        port: 3306
    EOF
    put db_config, "#{release_path}/config/database.yml"
  end

  namespace :deploy do
  desc "Create the sphinx config file"
  after "deploy:update_code" do
    sphinx_config = <<-EOF
    indexer
    {
    }

    searchd
    {
      listen = 127.0.0.1:7444
      log = log/searchd.log
      query_log = log/searchd_query.log
      pid_file = log/searchd.pid
      max_matches = 100000
    }

    source actor_core_0
    {
      type = mysql
      sql_host = 192.168.100.204
      sql_user = webuser
      sql_pass = 3gallfir-
      sql_db = dvdpost_test
      sql_query_pre = SET TIME_ZONE = '+0:00'
      sql_query = SELECT SQL_NO_CACHE `actors`.`actors_id` * CAST(3 AS SIGNED) + 0 AS `actors_id` , `actors`.`actors_name` AS `actors_name`, `actors`.`actors_id` AS `sphinx_internal_id`, 0 AS `sphinx_deleted`, 2243197437 AS `class_crc`, IFNULL(`actors`.`actors_name`, '') AS `actors_name_sort`, IFNULL(`actors`.`actors_type`, '') AS `kind`, if(actors_type='dvd_adult',0,1) AS `kind_int`, `actors`.`image_active` AS `image_active` FROM `actors`    WHERE `actors`.`actors_id` >= $start AND `actors`.`actors_id` <= $end GROUP BY `actors`.`actors_id`  ORDER BY NULL
      sql_query_range = SELECT IFNULL(MIN(`actors_id`), 1), IFNULL(MAX(`actors_id`), 1) FROM `actors` 
      sql_attr_uint = sphinx_internal_id
      sql_attr_uint = sphinx_deleted
      sql_attr_uint = class_crc
      sql_attr_uint = kind_int
      sql_attr_uint = image_active
      sql_attr_str2ordinal = actors_name_sort
      sql_attr_str2ordinal = kind
      sql_query_info = SELECT * FROM `actors` WHERE `actors_id` = (($id - 0) / 3)
    }

    index actor_core
    {
      source = actor_core_0
      path = /home/dvdpost/sphinx/staging/actor_core
      charset_type = sbcs
      charset_table = 0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,
      ignore_chars = U+AD
      min_prefix_len = 3
      enable_star = 1
    }

    index actor
    {
      type = distributed
      local = actor_core
    }

    source director_core_0
    {
      type = mysql
      sql_host = 192.168.100.204
      sql_user = webuser
      sql_pass = 3gallfir-
      sql_db = dvdpost_test
      sql_query_pre = SET TIME_ZONE = '+0:00'
      sql_query = SELECT SQL_NO_CACHE `directors`.`directors_id` * CAST(3 AS SIGNED) + 1 AS `directors_id` , `directors`.`directors_name` AS `directors_name`, `directors`.`directors_id` AS `sphinx_internal_id`, 0 AS `sphinx_deleted`, 3890655654 AS `class_crc`, IFNULL(`directors`.`directors_name`, '') AS `directors_name_sort` FROM `directors`    WHERE `directors`.`directors_id` >= $start AND `directors`.`directors_id` <= $end GROUP BY `directors`.`directors_id`  ORDER BY NULL
      sql_query_range = SELECT IFNULL(MIN(`directors_id`), 1), IFNULL(MAX(`directors_id`), 1) FROM `directors` 
      sql_attr_uint = sphinx_internal_id
      sql_attr_uint = sphinx_deleted
      sql_attr_uint = class_crc
      sql_attr_str2ordinal = directors_name_sort
      sql_query_info = SELECT * FROM `directors` WHERE `directors_id` = (($id - 1) / 3)
    }

    index director_core
    {
      source = director_core_0
      path = /home/dvdpost/sphinx/staging/director_core
      charset_type = sbcs
      charset_table = 0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,
      ignore_chars = U+AD
      min_prefix_len = 3
      enable_star = 1
    }

    index director
    {
      type = distributed
      local = director_core
    }

    source product_core_0
    {
      type = mysql
      sql_host = 192.168.100.204
      sql_user = webuser
      sql_pass = 3gallfir-
      sql_db = dvdpost_test
      sql_query_pre = SET TIME_ZONE = '+0:00'
      sql_query = SELECT SQL_NO_CACHE `products`.`products_id` * CAST(3 AS SIGNED) + 2 AS `products_id` , `products`.`products_media` AS `products_media`, `products`.`products_type` AS `products_type`, GROUP_CONCAT(DISTINCT IFNULL(`actors`.`actors_name`, '0') SEPARATOR ' ') AS `actors_name`, `directors`.`directors_name` AS `director_name`, `studio`.`studio_name` AS `studio_name`, GROUP_CONCAT(DISTINCT IFNULL(`products_description`.`products_name`, '0') SEPARATOR ' ') AS `descriptions_title`, (select      group_concat(distinct `country` SEPARATOR ',') from streaming_products where imdb_id = products.imdb_id and status = 'online_test_ok' and available = 1 and ((date(now())  >= date(available_backcatalogue_from) and date(now()) <= date(date_add(available_backcatalogue_from, interval 3 month)))or(date(now())  >= date(available_from) and date(now()) <= date(date_add(available_from, interval 3 month))))) AS `new_vod`, (select group_concat(distinct country) from streaming_products where imdb_id = products.imdb_id and streaming_products.status = 'online_test_ok' and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1 limit 1) AS `streaming_available`, `products`.`products_id` AS `sphinx_internal_id`, 0 AS `sphinx_deleted`, 485965105 AS `class_crc`, `products`.`products_availability` AS `availability`, `products`.`products_countries_id` AS `country_id`, UNIX_TIMESTAMP(`products`.`products_date_available`) AS `available_at`, UNIX_TIMESTAMP(`products`.`products_date_added`) AS `created_at`, `products`.`products_dvdpostchoice` AS `dvdpost_choice`, `products`.`products_id` AS `id`, `products`.`products_next` AS `next`, CAST(vod_next AS SIGNED) AS `vod_next`, CAST(vod_next_lux AS SIGNED) AS `vod_next_lux`, if(products_next = 1,1,if(vod_next=1,1,0)) AS `all_next`, `products`.`products_public` AS `audience`, `products`.`products_year` AS `year`, `products`.`products_language_fr` AS `french`, `products`.`products_undertitle_nl` AS `dutch`, `products`.`products_rating` AS `dvdpost_rating`, `products`.`imdb_id` AS `imdb_id`, `products`.`in_cinema_now` AS `in_cinema_now`, GROUP_CONCAT(DISTINCT IFNULL(`actors`.`actors_id`, '0') SEPARATOR ',') AS `actors_id`, GROUP_CONCAT(DISTINCT IFNULL(`categories`.`categories_id`, '0') SEPARATOR ',') AS `category_id`, GROUP_CONCAT(DISTINCT IFNULL(`themes`.`themes_id`, '0') SEPARATOR ',') AS `collection_id`, `directors`.`directors_id` AS `director_id`, `studio`.`studio_id` AS `studio_id`, GROUP_CONCAT(DISTINCT IFNULL(`products_languages`.`languages_id`, '0') SEPARATOR ',') AS `language_ids`, GROUP_CONCAT(DISTINCT IFNULL(`product_lists`.`id`, '0') SEPARATOR ',') AS `products_list_ids`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST" and language_id = 1 and product_id = products.products_id limit 1) AS `highlight_best_fr`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST" and language_id = 2 and product_id = products.products_id limit 1) AS `highlight_best_nl`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST" and language_id = 3 and product_id = products.products_id limit 1) AS `highlight_best_en`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_BE" and language_id = 1 and product_id = products.products_id limit 1) AS `highlight_best_vod_be_fr`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_BE" and language_id = 2 and product_id = products.products_id limit 1) AS `highlight_best_vod_be_nl`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_BE" and language_id = 3 and product_id = products.products_id limit 1) AS `highlight_best_vod_be_en`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_LU" and language_id = 1 and product_id = products.products_id limit 1) AS `highlight_best_vod_lu_fr`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_LU" and language_id = 2 and product_id = products.products_id limit 1) AS `highlight_best_vod_lu_nl`, (select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_LU" and language_id = 3 and product_id = products.products_id limit 1) AS `highlight_best_vod_lu_en`, CAST(listed_products.order AS SIGNED) AS `special_order`, GROUP_CONCAT(DISTINCT IFNULL(`products_undertitles`.`undertitles_id`, '0') SEPARATOR ',') AS `subtitle_ids`, cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) AS `rating`, GROUP_CONCAT(DISTINCT IFNULL(`streaming_products`.`imdb_id`, '0') SEPARATOR ',') AS `streaming_imdb_id`, GROUP_CONCAT(DISTINCT IFNULL(`streaming_products`.`is_ppv`, '0') SEPARATOR ' ') AS `is_ppv`, GROUP_CONCAT(DISTINCT IFNULL(`streaming_products`.`ppv_price`, '0') SEPARATOR ' ') AS `ppv_price`, min(streaming_products.id) AS `streaming_id`, concat(GROUP_CONCAT(DISTINCT IFNULL(`products_languages`.`languages_id`, '0') SEPARATOR ','),',', GROUP_CONCAT(DISTINCT IFNULL(`products_undertitles`.`undertitles_id`, '0') SEPARATOR ',')) AS `speaker`, (select (ifnull(replace(available_from,'-',''),replace(available_backcatalogue_from, '-',''))) date_order from streaming_products where imdb_id = products.imdb_id and status = 'online_test_ok' and available = 1 and ((date(now())  >= date(available_backcatalogue_from) and date(now()) <= date(date_add(available_backcatalogue_from, interval 3 month)))or(date(now())  >= date(available_from) and date(now()) <= date(date_add(available_from, interval 3 month)))) limit 1) AS `available_order`, (select studio_id from streaming_products where imdb_id = products.imdb_id and status = 'online_test_ok' and available = 1 order by expire_backcatalogue_at asc limit 1) AS `streaming_studio_id`, cast((SELECT count(*) FROM `wishlist_assigned` wa WHERE wa.products_id = products.products_id and date_assigned > date_sub(now(), INTERVAL 1 MONTH) group by wa.products_id) AS SIGNED) AS `most_viewed`, cast((SELECT count(*) FROM `wishlist_assigned` wa WHERE wa.products_id = products.products_id and date_assigned > date_sub(now(), INTERVAL 1 YEAR) group by wa.products_id) AS SIGNED) AS `most_viewed_last_year`, IFNULL((select products_name AS products_name_ord from products_description pd where  language_id = 1 and pd.products_id = products.products_id), '') AS `descriptions_title_fr`, IFNULL((select products_name AS products_name_ord from products_description pd where  language_id = 2 and pd.products_id = products.products_id), '') AS `descriptions_title_nl`, IFNULL((select products_name AS products_name_ord from products_description pd where  language_id = 3 and pd.products_id = products.products_id), '') AS `descriptions_title_en`, (select case              when (products_media = 'DVD' and streaming_products.imdb_id is not null) or (products_media = 'DVD' and vod_next = 1) then 2             when (products_media = 'VOD' and streaming_products.imdb_id is not null) or (products_media = 'VOD' and vod_next = 1) then 5             when products_media = 'DVD' then 1              when (products_media = 'blueray' and streaming_products.imdb_id is not null) or (products_media = 'blueray' and vod_next = 1) then 4              when products_media = 'blueray' then 3             when products_media = 'bluray3d' then 6             when products_media = 'bluray3d2d' then 7             else 8 end from products p              left join streaming_products on streaming_products.imdb_id = p.imdb_id and country ='BE' and ( streaming_products.status = 'online_test_ok' and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1)             where  p.products_id =  products.products_id limit 1) AS `special_media_be`, (select case              whe\
    n (products_media = 'DVD' and streaming_products.imdb_id is not null ) or (products_media = 'DVD' and vod_next_lux = 1) then 2             when (products_media = 'VOD' and streaming_products.imdb_id is not null ) or (products_media = 'VOD' and vod_next_lux = 1) then 5             when products_media = 'DVD' then 1              when (products_media = 'blueray' and streaming_products.imdb_id is not null ) or (products_media = 'blueray' and vod_next_lux = 1) then 4              when products_media = 'blueray' then 3             when products_media = 'bluray3d' then 6             when products_media = 'bluray3d2d' then 7             else 8 end              from products p             left join streaming_products on streaming_products.imdb_id = p.imdb_id and country ='LU' and ( streaming_products.status = 'online_test_ok' and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1)             where p.products_id =  products.products_id limit 1) AS `special_media_lu`, (select case              when (products_media = 'DVD' and streaming_products.imdb_id is not null ) then 2             when (products_media = 'VOD' and streaming_products.imdb_id is not null ) then 5             when products_media = 'DVD' then 1              when (products_media = 'blueray' and streaming_products.imdb_id is not null ) then 4              when products_media = 'blueray' then 3             when products_media = 'bluray3d' then 6             when products_media = 'bluray3d2d' then 7             else 8 end              from products p             left join streaming_products on streaming_products.imdb_id = p.imdb_id and country ='NL' and ( streaming_products.status = 'online_test_ok' and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1)             where p.products_id =  products.products_id limit 1) AS `special_media_nl`, (select count(*) c from tokens where tokens.imdb_id = products.imdb_id and (datediff(now(),created_at) < 8)) AS `count_tokens`, (select count(*) c from tokens where tokens.imdb_id = products.imdb_id and (datediff(now(),created_at) < 31)) AS `count_tokens_month`, case     when products_date_available > DATE_SUB(now(), INTERVAL 8 MONTH) and products_date_available < DATE_SUB(now(), INTERVAL 3 MONTH) and products_series_id = 0 and cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) >= 3 and products_quantity > 0 then 1     when products_date_available < DATE_SUB(now(), INTERVAL 8 MONTH) and products_series_id = 0 and cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) >= 4 and products_quantity > 2 then 1     else 0 end AS `popular`, concat(if(products_quantity>0 or products_media = "vod" or (  select count(*) > 0 from products p           join streaming_products on streaming_products.imdb_id = p.imdb_id           where  ((country="BE" and streaming_products.status = "online_test_ok" and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1) or p.vod_next=1 or streaming_products.imdb_id is null)  and p.products_id =  products.products_id),1,0),date_format(products_date_available,"%Y%m%d")) AS `default_order_be`, concat(if(products_quantity>0  or (  select count(*) > 0 from products p           join streaming_products on streaming_products.imdb_id = p.imdb_id           where  ((country="LU" and streaming_products.status = "online_test_ok" and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1) or p.vod_next_lux=1 or streaming_products.imdb_id is null)  and p.products_id =  products.products_id),1,0),date_format(products_date_available,"%Y%m%d")) AS `default_order_lu`, concat(if(products_quantity>0 or (  select count(*) > 0 from products p           join streaming_products on streaming_products.imdb_id = p.imdb_id           where  ((country="NL" and streaming_products.status = "online_test_ok" and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1) or streaming_products.imdb_id is null)  and p.products_id =  products.products_id),1,0),date_format(products_date_available,"%Y%m%d")) AS `default_order_nl`, case      when  products_status = -1 then 99     else products_status end AS `status`, `products`.`products_quantity` AS `in_stock`, `products`.`products_series_id` AS `series_id` FROM `products`    LEFT OUTER JOIN `products_to_actors` ON `products_to_actors`.products_id = `products`.products_id  LEFT OUTER JOIN `actors` ON `actors`.actors_id = `products_to_actors`.actors_id   LEFT OUTER JOIN `directors` ON `directors`.directors_id = `products`.products_directors_id   LEFT OUTER JOIN `studio` ON `studio`.studio_id = `products`.products_studio   LEFT OUTER JOIN `products_description` ON products_description.products_id = products.products_id   LEFT OUTER JOIN `products_to_categories` ON `products_to_categories`.products_id = `products`.products_id  LEFT OUTER JOIN `categories` ON `categories`.categories_id = `products_to_categories`.categories_id   LEFT OUTER JOIN `products_to_themes` ON `products_to_themes`.products_id = `products`.products_id  LEFT OUTER JOIN `themes` ON `themes`.themes_id = `products_to_themes`.themes_id   LEFT OUTER JOIN `products_to_languages` ON `products_to_languages`.products_id = `products`.products_id  LEFT OUTER JOIN `products_languages` ON `products_languages`.languages_id = `products_to_languages`.products_languages_id AND products_languages.`languagenav_id` = 1   LEFT OUTER JOIN `listed_products` ON `listed_products`.product_id = `products`.products_id  LEFT OUTER JOIN `product_lists` ON `product_lists`.id = `listed_products`.product_list_id   LEFT OUTER JOIN `products_to_undertitles` ON `products_to_undertitles`.products_id = `products`.products_id  LEFT OUTER JOIN `products_undertitles` ON `products_undertitles`.undertitles_id = `products_to_undertitles`.products_undertitles_id AND products_undertitles.`language_id` = 1   LEFT OUTER JOIN `streaming_products` ON streaming_products.imdb_id = products.imdb_id AND streaming_products.`available` = 1  WHERE `products`.`products_id` >= $start AND `products`.`products_id` <= $end GROUP BY `products`.`products_id`  ORDER BY NULL
      sql_query_range = SELECT IFNULL(MIN(`products_id`), 1), IFNULL(MAX(`products_id`), 1) FROM `products` 
      sql_attr_uint = sphinx_internal_id
      sql_attr_uint = sphinx_deleted
      sql_attr_uint = class_crc
      sql_attr_uint = availability
      sql_attr_uint = country_id
      sql_attr_uint = dvdpost_choice
      sql_attr_uint = id
      sql_attr_uint = next
      sql_attr_uint = vod_next
      sql_attr_uint = vod_next_lux
      sql_attr_uint = all_next
      sql_attr_uint = audience
      sql_attr_uint = year
      sql_attr_uint = french
      sql_attr_uint = dutch
      sql_attr_uint = dvdpost_rating
      sql_attr_uint = imdb_id
      sql_attr_uint = in_cinema_now
      sql_attr_uint = director_id
      sql_attr_uint = studio_id
      sql_attr_uint = highlight_best_fr
      sql_attr_uint = highlight_best_nl
      sql_attr_uint = highlight_best_en
      sql_attr_uint = highlight_best_vod_be_fr
      sql_attr_uint = highlight_best_vod_be_nl
      sql_attr_uint = highlight_best_vod_be_en
      sql_attr_uint = highlight_best_vod_lu_fr
      sql_attr_uint = highlight_best_vod_lu_nl
      sql_attr_uint = highlight_best_vod_lu_en
      sql_attr_uint = special_order
      sql_attr_uint = streaming_id
      sql_attr_uint = available_order
      sql_attr_uint = streaming_studio_id
      sql_attr_uint = most_viewed
      sql_attr_uint = most_viewed_last_year
      sql_attr_uint = special_media_be
      sql_attr_uint = special_media_lu
      sql_attr_uint = special_media_nl
      sql_attr_uint = count_tokens
      sql_attr_uint = count_tokens_month
      sql_attr_uint = popular
      sql_attr_uint = default_order_be
      sql_attr_uint = default_order_lu
      sql_attr_uint = default_order_nl
      sql_attr_uint = status
      sql_attr_uint = in_stock
      sql_attr_uint = series_id
      sql_attr_timestamp = available_at
      sql_attr_timestamp = created_at
      sql_attr_str2ordinal = descriptions_title_fr
      sql_attr_str2ordinal = descriptions_title_nl
      sql_attr_str2ordinal = descriptions_title_en
      sql_attr_float = rating
      sql_attr_float = ppv_price
      sql_attr_multi = uint actors_id from field
      sql_attr_multi = uint category_id from field
      sql_attr_multi = uint collection_id from field
      sql_attr_multi = uint language_ids from field
      sql_attr_multi = uint products_list_ids from field
      sql_attr_multi = uint subtitle_ids from field
      sql_attr_multi = uint streaming_imdb_id from field
      sql_attr_multi = uint is_ppv from field
      sql_attr_multi = uint speaker from field
      sql_query_info = SELECT * FROM `products` WHERE `products_id` = (($id - 2) / 3)
    }

    index product_core
    {
      source = product_core_0
      path = /home/dvdpost/sphinx/staging/product_core
      charset_type = sbcs
      charset_table = 0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,
      ignore_chars = U+AD
      min_prefix_len = 3
      enable_star = 1
    }

    index product
    {
      type = distributed
      local = product_core
    }

    EOF
    put sphinx_config, "#{release_path}/config/staging.sphinx.conf"
  end
  
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  after "deploy:restart" do
    env_config = <<-EOF
    # Settings specified here will take precedence over those in config/environment.rb

    # In the development environment your application's code is reloaded on
    # every request.  This slows down response time but is perfect for development
    # since you don't have to restart the webserver when you make code changes.
    config.cache_classes = false

    # Log error messages when you accidentally call methods on nil.
    config.whiny_nils = true

    # Show full error reports and disable caching
    config.action_controller.consider_all_requests_local = true
    config.action_view.debug_rjs                         = true
    config.action_controller.perform_caching             = true
    #config.cache_store = :file_store, RAILS_ROOT + "/tmp/cache"
    config.cache_store = :mem_cache_store, '192.168.100.206:11211'
    # Don't care if the mailer can't send
    config.action_mailer.raise_delivery_errors = false
    ENV['APP'] = "1"
    EOF
    put env_config, "#{current_path}/config/environments/staging.rb"

  end
end
before 'deploy:create_symlink', 'deploy:stop_ts'
after 'deploy:create_symlink', 'deploy:update_ts'
