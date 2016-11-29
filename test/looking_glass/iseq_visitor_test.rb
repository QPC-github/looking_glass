require 'test_helper'
require 'looking_glass/visitors/disasm_visitor'

module LookingGlass
  class ISeqVisitorTest < MiniTest::Test
    class CountingVisitor < LookingGlass::ISeqVisitor
      attr_reader :count
      def initialize
        @count = 0
      end

      def visit(_bytecode)
        @count += 1
      end
    end

    def test_all_methods
      class_count = 0
      method_count = 0
      bytecode_count = 0
      smallest = 1024
      smallest_method = nil
      largest = 0
      largest_method = nil

      LookingGlass.classes.each do |clazz|
        clazz.methods.each do |meth|
          visitor = CountingVisitor.new
          visitor.call(meth)
          bytecode_count += visitor.count

          if visitor.count > largest
            largest = visitor.count
            largest_method = meth
          end

          if visitor.count < smallest && visitor.count > 0
            smallest = visitor.count
            smallest_method = meth
          end
          bytecode_count += visitor.count
          method_count += 1
        end
        class_count += 1
      end
      assert(class_count >= 788)
      assert(method_count >= 4782)
      assert(bytecode_count >= 47308)

      puts "Walked #{class_count} classes with #{method_count} methods and #{bytecode_count} bytecodes."
      puts "Largest method #{largest_method.defining_class.name}.#{largest_method.name}, #{largest} bytecodes."
      puts "Smallest method #{smallest_method.defining_class.name}.#{smallest_method.name}, #{smallest} bytecodes."
      puts "Average method #{bytecode_count / method_count}  bytecodes."
    end
  end
end
