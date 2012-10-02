class CurrencyInput < SimpleForm::Inputs::Base
  def input
    template = <<-eos
      <div class="row collapse complex-input">
        <div class="two mobile-one columns">
          <span class="prefix">$</span>
        </div>
        <div class="ten mobile-three columns">
          #{@builder.text_field("#{attribute_name}".to_sym, input_html_options)}
        </div>
      </div>
    eos
    template.html_safe
  end
end
