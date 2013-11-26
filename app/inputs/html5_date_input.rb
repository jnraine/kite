class Html5DateInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:type] = "date"
    input_html_options[:value] = value
    @builder.text_field(attribute_name, input_html_options).html_safe
  end

  def value
    attribute_value = object.send(attribute_name)
    attribute_value.to_time.strftime("%Y-%m-%d") if attribute_value
  end
end