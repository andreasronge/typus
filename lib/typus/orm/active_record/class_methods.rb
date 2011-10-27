module Typus
  module Orm
    module ActiveRecord
      module ClassMethods

        include Typus::Orm::Base

        # Model fields as an <tt>ActiveSupport::OrderedHash</tt>.
        def model_fields
          ActiveSupport::OrderedHash.new.tap do |hash|
            columns.map { |u| hash[u.name.to_sym] = u.type.to_sym }
          end
        end

        # Model relationships as an <tt>ActiveSupport::OrderedHash</tt>.
        def model_relationships
          ActiveSupport::OrderedHash.new.tap do |hash|
            reflect_on_all_associations.map { |i| hash[i.name] = i.macro }
          end
        end

        def typus_fields_for(filter)
          ActiveSupport::OrderedHash.new.tap do |fields_with_type|
            get_typus_fields_for(filter).each do |field|
              [:virtual, :custom, :association, :selector, :dragonfly, :paperclip].each do |attribute|
                if (value = send("#{attribute}_attribute?", field))
                  fields_with_type[field.to_s] = value
                end
              end
              fields_with_type[field.to_s] ||= model_fields[field]
            end
          end
        end

        def get_typus_fields_for(filter)
          data = read_model_config['fields']
          fields = case filter.to_sym
                   when :index                  then data['index'] || data['list']
                   when :new, :create           then data['new'] || data['form']
                   when :edit, :update, :toggle then data['edit'] || data['form']
                   else
                     data[filter.to_s]
                   end

          fields ||= data['default'] || typus_default_fields_for(filter)
          fields = fields.extract_settings if fields.is_a?(String)
          fields.map(&:to_sym)
        end

        def typus_default_fields_for(filter)
          filter.to_sym.eql?(:index) ? ['id'] : model_fields.keys
        end

        def virtual_fields
          instance_methods.map(&:to_s) - model_fields.keys.map(&:to_s)
        end

        def virtual_attribute?(field)
          :virtual if virtual_fields.include?(field.to_s)
        end

        def dragonfly_attribute?(field)
          if respond_to?(:dragonfly_attachment_classes) && dragonfly_attachment_classes.map(&:attribute).include?(field)
            :dragonfly
          end
        end

        def paperclip_attribute?(field)
          if respond_to?(:attachment_definitions) && attachment_definitions.try(:has_key?, field)
            :paperclip
          end
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

        def typus_order_by(order_by = nil, sort_order = nil)
          if order_by.nil? || sort_order.nil?
            order_string = typus_defaults_for(:order_by).map do |field|
              field.include?('-') ? "#{field.delete('-')} DESC" : "#{field} ASC"
            end.join(', ')
          else
            order_string = "#{order_by} #{sort_order}"
          end

          self.order(order_string)
        end

        def get_typus_filters
          data = read_model_config['filters'] || ""
          data.extract_settings.map(&:to_sym)
        end

        def typus_user_id?
          columns.map(&:name).include?(Typus.user_foreign_key)
        end

      end
    end
  end
end
