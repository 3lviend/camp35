class WorkChartSelectorInput < SimpleForm::Inputs::Base
  def input
    template = <<-eos
      <div class="row collapse complex-input">
        <div class="eight mobile-three columns">
          #{@builder.text_field("#{attribute_name}".to_sym, input_html_options)}
        </div>
        <div class="four mobile-three columns">
          <div href="#" class="small button dropdown">
            Quick pick
            <ul>
              #{render_quicks(options[:quicks])}
            </ul>
          </div>
        </div>
      </div>
    eos
    template.html_safe
  end

  def render_quicks(quicks)
    quicks.map { |q| render_quick(q) }.join
  end

  def render_quick(quick)
    "<li><a href=\"#\" class=\"quick-pick\" data-id=\"#{quick.id}\">#{quick.labels[1..-1].join(" / ")}</a></li>"
  end
end
