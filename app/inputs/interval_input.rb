class IntervalInput < SimpleForm::Inputs::Base
  def input
    template = <<-eos
      #{@builder.select("#{attribute_name}_hours".to_sym, [""] + (0..24).to_a, input_html_options)}h
      #{@builder.select("#{attribute_name}_minutes".to_sym, [""] + (0..3).map{|i| i*15}, input_html_options)}m
    eos
    template.html_safe
  end
end
