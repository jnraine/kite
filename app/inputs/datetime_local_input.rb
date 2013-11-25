class DatetimeLocalInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:type] = "datetime-local"
    input_html_options[:step] = 15
    @builder.text_field(attribute_name, input_html_options).html_safe
  end
end