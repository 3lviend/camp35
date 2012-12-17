exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
        'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        before: [
          'vendor/scripts/console-helper.js'
          'vendor/scripts/jquery-1.7.2.js'
          'vendor/scripts/jquery.ui.min.js'
          'vendor/scripts/underscore-1.3.3.js'
          'vendor/scripts/backbone-0.9.2.js'
          'vendor/scripts/backbone_filters.js'
          'vendor/scripts/timers.js'
          'vendor/scripts/knockout.js'
          'vendor/scripts/moment.js'
          'vendor/scripts/humane.js'
          'vendor/scripts/spin.js'
          'vendor/scripts/foundation.reveal.js'
          'vendor/scripts/foundation.navigation.js'
          'vendor/scripts/foundation.topbar.js'
          'vendor/scripts/modernizr.js'
          'vendor/scripts/autogrow.js'
          'vendor/scripts/date.js'
          'vendor/scripts/abstract_chosen.js'
          'vendor/scripts/select_parser.js'
          'vendor/scripts/chosen.js'
        ]
    stylesheets:
      defaultExtension: 'scss'
      joinTo: 'stylesheets/app.css'
      order:
        before: ['vendor/styles/normalize.css']
        after: ['vendor/styles/helpers.css']
    templates:
      defaultExtension: 'eco'
      joinTo: 'javascripts/app.js'
  minify: no
