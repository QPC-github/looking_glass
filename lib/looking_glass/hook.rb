require 'looking_glass/invoke'

module LookingGlass
  CLASS_DEFINITION_POINTS = {}

  NoGemfile = Class.new(StandardError)

  class << self
    attr_accessor :project_root
  end
end

begin
  unless LookingGlass.project_root
    appline = caller.detect { |line| line !~ /:in `require'/ }
    f = File.expand_path(appline.sub(/:\d.*/, ''))
    LookingGlass.project_root = loop do
      f = File.dirname(f)
      raise LookingGlass::NoGemfile if f == '/'
      break f if File.exist?("#{f}/Gemfile")
    end
  end
end

class Class
  alias_method :__lg_orig_inherited, :inherited
  def inherited(subclass)
    file = caller[0].sub(/:\d+:in.*/, '')
    key = LookingGlass.module_invoke(subclass, :inspect)
    LookingGlass::CLASS_DEFINITION_POINTS[key] = file
    __lg_orig_inherited(subclass)
  end
end
