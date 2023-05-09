# frozen_string_literal: true

module Delayed
  module Backend
    class Bulk
      module Callbacks
        extend ActiveSupport::Concern
        include ActiveSupport::Callbacks

        included do
          define_callbacks :enqueue
        end

        class_methods do
          def before_enqueue(*args, &block)
            set_callback(:enqueue, :before, *args, &block)
          end
    
          def after_enqueue(*args, &block)
            set_callback(:enqueue, :after, *args, &block)
          end
    
          def around_enqueue(*args, &block)
            set_callback(:enqueue, :around, *args, &block)
          end
        end
      end
    end
  end
end
