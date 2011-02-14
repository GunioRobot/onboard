require 'dansguardian/list'
require 'onboard/content-filter/dg/managed-list/filepath-mixin'

class OnBoard
  module ContentFilter
    class DG
      module ManagedList
        class List

          include ManagedList::FilePathMixin

          def initialize(h)
            @relative_path  = h[:relative_path]
            @data           = ::DansGuardian::List.new(absolute_path)
          end

          # Delegate to ::DansGuardian::List instance methods.

          def items;        @data.items;        end
          def listcategory; @data.listcategory; end
          def read!;        @data.read!;        end

          def includes
            @data.includes.map do |abspath| 
              relpath = ManagedList.relative_path abspath
              ManagedList::List.new :relative_path => relpath
            end
          end

          def <=>(other)
            if other.is_a? ManagedList::Dir
              +1 # list directories before files
            else
              @relative_path <=> other.relative_path
            end
          end

        end
      end
    end
  end
end
