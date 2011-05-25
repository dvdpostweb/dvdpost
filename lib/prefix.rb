require 'routing_filter'

module RoutingFilter
  class Kind < Filter

    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    def around_recognize(path, env, &block)
      if path =~ /\/adult/ 
         kind = :adult
      elsif  path =~ /\/normal/ 
        kind = :normal
      elsif path =~ /\/fr|nl|en/ 
        path.sub! %r(^/(fr|nl|en)) do kind = :normal; "/#{$1}/normal" end
      else
        kind = :normal
      end
      yield.tap do |params|
        params[:kind] = kind
      end
    end

    def around_generate(*args, &block)
      arg = args.extract_options!
      if arg[:kind] 
        kind = arg[:kind]
      else
        kind = :normal 
      end
      yield.tap do |result|
        if kind.to_sym == :normal
          result.sub!(%r((.+)(\/normal)(.*))){ "#{$1}#{$3}" }
        end 
      end
    end

  end
end