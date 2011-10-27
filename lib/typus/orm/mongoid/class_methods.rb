module Typus
  module Orm
    module Mongoid
      module ClassMethods

        include Typus::Orm::Base

        delegate :any?, :to => :all

        def table_name
          collection_name
        end

        def typus_order_by(order_field = nil, sort_order = nil)
          if order_field.nil? || sort_order.nil?
            order_array = typus_defaults_for(:order_by).map do |field|
              field.include?('-') ? [field.delete('-'), :desc] : [field, :asc]
            end
          else
            order_array = [[order_field, sort_order.downcase.to_sym]]
          end
          self.order_by(order_array)
        end

        def typus_fields_for(filter)
          ActiveSupport::OrderedHash.new.tap do |fields_with_type|
            get_typus_fields_for(filter).each do |field|
              [:virtual, :custom, :association, :selector].each do |attribute|
                if (value = send("#{attribute}_attribute?", field))
                  fields_with_type[field.to_s] = value
                end
              end
              fields_with_type[field.to_s] ||= model_fields[field]
            end
          end
        end

        def virtual_fields
          instance_methods.map { |i| i.to_s } - model_fields.keys.map { |i| i.to_s }
        end

        def virtual_attribute?(field)
          :virtual if virtual_fields.include?(field.to_s)
        end
        def selector_attribute?(field)
          :selector if typus_field_options_for(:selectors).include?(field)
        end

        def association_attribute?(field)
          reflect_on_association(field).macro if reflect_on_association(field)
        end

        def custom_attribute?(field)
          case field.to_s
          when 'parent', 'parent_id' then :tree
          when /password/            then :password
          when 'position'            then :position
          when /\./                  then :transversal
          end
        end

        #
        # Model fields as an <tt>ActiveSupport::OrderedHash</tt>.
        def model_fields
          ActiveSupport::OrderedHash.new.tap do |hash|
            fields.values.map { |u| hash[u.name.to_sym] = u.type.name.downcase.to_sym }
          end
        end

        # Model relationships as an <tt>ActiveSupport::OrderedHash</tt>.
        def model_relationships
          ActiveSupport::OrderedHash.new.tap do |hash|
            relations.values.map { |i| hash[i.name] = i.macro }
          end
        end

        def typus_user_id?
          fields.keys.include?(Typus.user_foreign_key)
        end

      end
    end
  end
end
