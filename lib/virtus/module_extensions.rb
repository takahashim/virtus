module Virtus

  # Virtus module that can define attributes for later inclusion
  #
  # @private
  module ModuleExtensions
    include ConstMissingExtensions

    # @api private
    def self.extended(mod)
      super
      setup(mod)
    end

    # @api private
    def self.setup(mod, inclusions = [Model], attribute_definitions = [])
      mod.instance_variable_set('@inclusions', inclusions)
      mod.instance_variable_set('@attribute_definitions', attribute_definitions)
    end

    # Define an attribute in the module
    #
    # @see Virtus::Extensions#attribute
    #
    # @return [self]
    #
    # @api private
    def attribute(name, type, options = {})
      @attribute_definitions << [name, type, options]
      self
    end

    private

    # Extend an object with Virtus methods and define attributes
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    def extended(object)
      super
      @inclusions.each { |mod| object.extend(mod) }
      define_attributes(object)
      object.set_default_attributes
    end

    # Extend a class with Virtus methods and define attributes
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    def included(object)
      super

      if Class === object
        @inclusions.each { |mod| object.send(:include, mod) }
        define_attributes(object)
      else
        object.extend(ModuleExtensions)
        ModuleExtensions.setup(object, @inclusions, @attribute_definitions)
      end
    end

    # Define attributes on a class or instance
    #
    # @param [Object,Class] object
    #
    # @return [undefined]
    #
    # @api private
    def define_attributes(object)
      @attribute_definitions.each do |attribute_args|
        object.attribute(*attribute_args)
      end
    end

  end # module ModuleExtensions
end # module Virtus
