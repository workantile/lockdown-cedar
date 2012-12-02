module ApplicationHelper
  def build_control(f, object, help_object, attribute, control_type, options = nil)
    content_tag(:div, :class => "control-group") do
      build_label(f, object, attribute, options) + 
      content_tag(:div, :class => "controls") do
        build_specific_control(f, object, attribute, control_type, options).html_safe +
        content_tag(:div, object.errors[attribute.to_sym].join(","), :class => "field_with_errors")
      end
    end
  end
  
   def build_label(f, object, attribute, options = nil)
    if options && options[:label]
      f.label(attribute, options[:label], :class => 'control-label')
    else
      f.label(attribute, :class => 'control-label')
    end
  end

  def build_specific_control(f, object, attribute, control_type, options = nil)
    case control_type
    when 'text'
      build_text_field(f, object, attribute, options)
    when 'text_area'
      build_text_area(f, object, attribute, options)
    when 'password'
      f.password_field(attribute)
    when 'select'
      build_select_box(f, attribute, options[:select_list])
    when 'check_box'
      f.check_box(attribute)
    when 'radio_buttons'
      build_radio_buttons(f, attribute, options)
    end
  end
  
  def build_text_field(f, object, attribute, options = nil)
    if options && options[:precision]
      f.text_field(attribute, :value => number_with_precision(f.object[attribute.to_sym], 
        :precision => options[:precision], :delimiter => ','))
    else
      f.text_field(attribute)
    end
  end
  
  def build_text_area(f, object, attribute, options = nil)
    if options && options[:rows]
      f.text_area(attribute, :rows => options[:rows])
    else
      f.text_area(attribute, :rows => '3')
    end
  end
  
  def build_select_box(f, attribute, select_list)
    if select_list.is_a?(Mongoid::Criteria)
      f.select(attribute, select_list.collect {|item| [item.full_name, item.id]}, {:include_blank => true})
    else
      f.select(attribute, select_list.collect {|item| [item, item]})
    end    
  end
  
  def build_radio_buttons(f, attribute, options)
    options[:values_list].inject("") do |control, value|
      control << content_tag(:label, f.radio_button(attribute, value) + " #{user_friendly_value(value)}", :class => "radio")
      control
    end
  end
end
