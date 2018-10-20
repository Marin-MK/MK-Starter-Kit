class Module
  def delegate(methods, to:)
    methods = Array(methods)
    validate to: [Symbol, String]
    
    to = to.to_s

    methods.map! do |method|
      signature = /[^\]]=$/.match?(method) ? "arg" : "*args, &block"

      <<~RUBY.split('\n').join(';')
        def #{method}(#{signature})
          #{to}.#{method}(#{signature})
        end
      RUBY
    end

    module_eval(methods.join(';'))
  end
end