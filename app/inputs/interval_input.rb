class IntervalInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:class] << "interval"
    template = <<-eos
        #{@builder.text_field("#{attribute_name}".to_sym, input_html_options)}
    eos
    template.html_safe
  end
end
