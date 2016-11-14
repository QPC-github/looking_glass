require 'method_source'

class LookingGlass
  # A MethodMirror should reflect on methods, but in a more general
  # sense than the Method and UnboundMethod classes in Ruby are able
  # to offer.
  #
  # In actual execution, a method is pretty much every chunk of code,
  # even loading a file triggers a process not unlike compiling a
  # method (if only for the side-effects). Method mirrors should allow
  # access to the runtime objects, but also to their static
  # representations (bytecode, source, ...), their debugging
  # information and statistical information
  class MethodMirror < Mirror
    reflect! Method, UnboundMethod

    # @return [String] The filename
    def file
      source_location.first
    end

    # @return [Fixnum] The source line
    def line
      source_location.last - 1
    end

    # @return [String] The method name
    def selector
      @subject.name.to_s
    end

    # @return [ClassMirror] The class this method was originally defined in
    def defining_class
      reflection.reflect @subject.send(:owner)
    end

    def delete
      @subject.send(:owner).send(:remove_method, @subject.name)
    end

    # Return the value the block argument, or nil
    #
    # @return [FieldMirror, nil]
    def block_argument
      args(:block).first
    end

    # Returns a field mirror with name and possibly value of the splat
    # argument, or nil, if there is none to this method.
    #
    # @return [FieldMirror, nil]
    def splat_argument
      args(:rest).first
    end

    # Returns names and values of the optional arguments.
    #
    # @return [Array<FieldMirror>, nil]
    def optional_arguments
      args(:opt)
    end

    # Returns the name and possibly values of the required arguments
    # @return [Array<FieldMirror>, nil]
    def required_arguments
      args(:req)
    end

    # Queries the method for it's arguments and returns a list of
    # mirrors that hold name and value information.
    #
    # @return [Array<FieldMirror>]
    def arguments
      @subject.send(:parameters).map { |t,a| a.to_s }
    end

    def protected?
      visibility? :protected
    end

    def public?
      visibility? :public
    end

    def private?
      visibility? :private
    end

    # @return [String] The source code of this method
    def source
      @subject.send(:source)
    end

    # Returns the compiled code if available. Disasemble it with `.disasm`
    # @return [RubyVM::InstructionSequence, nil] native code
    def native_code
      RubyVM::InstructionSequence.of(@subject)
    end

    private

    def visibility?(type)
      list = @subject.send(:owner).send("#{type}_instance_methods")
      list.any? { |m| m.to_s == selector }
    end

    def args(type)
      args = []
      @subject.send(:parameters).select { |t,n| args << n.to_s if t == type }
      args
    end

    def source_location
      @subject.send(:source_location)
    end
  end
end
