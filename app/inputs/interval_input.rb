class IntervalInput < SimpleForm::Inputs::Base
  def input
    # TODO: refactor!
    input_html_hours = Marshal.load(Marshal.dump(input_html_options))
    input_html_minutes = Marshal.load(Marshal.dump(input_html_options))
    input_html_hours[:class] << "hours"
    input_html_minutes[:class] << "minutes"
    hours = (0..8).to_a.map do |hour|
      t = <<-eos
        <a href="#" data-hour="#{hour}" class="button hour-button">#{hour}</a>
      eos
      t
    end
    minutes = (0..3).to_a.map{|i| i*15}.map do |min|
      t = <<-eos
        <a href="#" data-minute="#{min}" class="button minute-button">#{min}</a>
      eos
      t
    end
    template = <<-eos
      <div class="row collapse complex-input single-select">
        <div class="five mobile-three columns">
          #{@builder.select("#{attribute_name}_hours".to_sym, ((0..24).to_a), input_html_hours)}
        </div>
        <div class="one mobile-one columns">
          <span class="postfix">h</span>
        </div>
        <div class="five mobile-three columns single-select">
          #{@builder.select("#{attribute_name}_minutes".to_sym, ([0,1,2,3].map{|i| i*15}), input_html_minutes)}
        </div>
        <div class="one mobile-one columns">
          <span class="postfix">m</span>
        </div>
      </div>
      <div class="row collapse hours-minutes">
        #{hours.join} <span>&nbsp;</span> #{minutes.join}
      </div>
    eos
    template.html_safe
  end
end
