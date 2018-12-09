class Module
  # Automatically reroutes the methods from the list to the instance variable specified.
  # @param methods [Array<Symbol>] the list of methods.
  # @param to [Symbol] the instance variable to reroute the methods to.
  def delegate(methods, to:)
    methods = Array(methods)
    validate to: [Symbol, String]

    methods.map! do |method|
      signature = /[^\]]=$/.match(method) ? "arg" : "*args, &block"

      <<-RUBY
        def #{method}(#{signature})
          #{to}.#{method}(#{signature})
        end
      RUBY
    end

    module_eval(methods.join(';'))
  end
end
