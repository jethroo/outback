module Outback
  class Configuration
    @loaded = []

    class << self
      def add(configuration)
        raise ConfigurationError.new("duplicate configuration #{configuration.name}") if loaded.any?(&its.name == configuration.name)
        loaded << configuration
      end
      
      def loaded
        @loaded
      end
      
      def [](name)
        loaded.detect { |configuration| configuration.name == name.to_s }
      end
      
      def reset
        @loaded = []
      end
    end

    attr_reader :name, :sources, :targets, :errors

    def initialize(name, &block)
      raise(ConfigurationError.new("configuration name can't be blank")) if name.blank?
      @name = name.to_s
      raise(ConfigurationError.new('configuration name may not contain underscores')) if @name.include?('_')
      @sources, @targets, @errors = [], [], []
      if block_given?
        if block.arity == 1 then yield(self) else instance_eval(&block) end
      end
      self.class.add(self)
    end

    def valid?
      errors.clear
      return error('no targets specified') if targets.empty?
      moving_targets = targets.select { |t| t.is_a?(DirectoryTarget) && t.move }
      return error('cannot define more than one moving target') if moving_targets.size > 1
      return error('moving target must be defined last') if moving_targets.first && moving_targets.first != targets.last
      true
    end
    
    protected

    def tmpdir(dir = nil)
      @tmpdir = dir if dir
      @tmpdir
    end

    def source(type, *args, &block)
      "Outback::#{type.to_s.classify}Source".constantize.configure(*args, &block).tap { |instance| sources << instance }
    end
    
    def target(type, *args, &block)
      "Outback::#{type.to_s.classify}Target".constantize.configure(*args, &block).tap { |instance| targets << instance }
    end

    def error(message)
      errors << ConfigurationError.new(message)
      false
    end
  end
end
