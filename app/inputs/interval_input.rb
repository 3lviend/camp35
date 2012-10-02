class IntervalInput < SimpleForm::Inputs::Base
  def input
    # TODO: refactor!
    input_html_options[:class] << "spinner"
    input_html_hours = Marshal.load(Marshal.dump(input_html_options))
    input_html_minutes = Marshal.load(Marshal.dump(input_html_options))
    input_html_hours[:class] << "hours"
    input_html_minutes[:class] << "minutes"
    template = <<-eos
      <div class="row collapse complex-input">
        <div class="four mobile-three columns">
          #{@builder.text_field("#{attribute_name}_hours".to_sym, input_html_hours)}
        </div>
        <div class="two mobile-one columns">
          <span class="postfix">h</span>
        </div>
        <div class="four mobile-three columns">
          #{@builder.text_field("#{attribute_name}_minutes".to_sym, input_html_minutes)}
        </div>
        <div class="two mobile-one columns">
          <span class="postfix">m</span>
        </div>
      </div>
    eos
    template.html_safe
  end
end
