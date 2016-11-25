module LookingGlass
  module PackageInference
    class ClassToFileResolver
      def initialize
        @files = {}
      end

      def resolve(klass)
        try_fast(klass, klass.name) ||
          try_fast(klass.singleton_class, klass.name) ||
          try_slow(klass) ||
          try_slow(klass.singleton_class)
      end

      def try_fast(klass, class_name)
        klass.instance_methods(false).each do |name|
          meth = klass.instance_method(name)

          file = begin
            meth.source_location[0]
          rescue # MethodSource::Something...
            next
          end

          contents = (@files[file] ||= File.open(file, 'r') { |f| f.readpartial(4096) })
          n = class_name.sub(/.*::/, '') # last component of module name
          return file if contents =~ /^\s+(class|module) ([\S]+::)?#{Regexp.quote(n)}\s/
        end
        nil
      end

      def try_slow(klass)
        methods = klass
          .instance_methods(false)
          .map { |n| klass.instance_method(n) }

        defined_directly_on_class = methods
          .select do |meth|
            # as a mostly-useful heuristic, we just eliminate everything that was
            # defined using a template eval or define_method.
            meth.source =~ /\A\s+def (self\.)?#{Regexp.quote(meth.name)}/
          end

        files = Hash.new(0)

        defined_directly_on_class.each do |meth|
          begin
            files[meth.source_location[0]] += 1
          rescue # which class?
            raise
          end
        end

        file = files.max_by { |_k, v| v }
        file ? file[0] : nil
      end
    end
  end
end
