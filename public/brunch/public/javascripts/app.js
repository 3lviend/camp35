(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle) {
    for (var key in bundle) {
      if (has(bundle, key)) {
        modules[key] = bundle[key];
      }
    }
  }

  globals.require = require;
  globals.require.define = define;
  globals.require.brunch = true;
})();

window.require.define({"application": function(exports, require, module) {
  var Application, CalendarView, EntryEditView, EntryNewView, LogInView, Modal, ReportsView, Role, RolesCollection, Router, SwitchRoleView, TopBarView, WorkDayView, initSpinner, startSpinner, stopSpinner;

  Router = require('routers/router');

  Role = require('models/role');

  RolesCollection = require('collections/roles');

  TopBarView = require('views/navigation/top_bar');

  SwitchRoleView = require('views/admin/switch_role');

  ReportsView = require('views/reports');

  LogInView = require('views/auth/login');

  CalendarView = require('views/calendar');

  EntryNewView = require('views/entries/new');

  EntryEditView = require('views/entries/edit');

  WorkDayView = require('views/work_day');

  Modal = require('lib/modal_window.js');

  module.exports = Application = (function() {

    function Application() {
      var _this = this;
      $(function() {
        _this.initialize();
        return Backbone.history.start({
          pushState: true
        });
      });
    }

    Application.prototype.initialize = function() {
      this.current_role = new Role;
      this.current_role.url = "/roles/current.json";
      this.current_role.fetch();
      this.rolesToSwitch = new RolesCollection;
      this.rolesToSwitch.url = "/roles/others.json";
      this.rolesToReport = new RolesCollection;
      this.rolesToReport.url = "/roles/reportable.json";
      this.router = new Router;
      this.topBarView = new TopBarView({
        role: this.current_role
      });
      this.switchRoleView = new SwitchRoleView({
        other_roles: this.rolesToSwitch
      });
      this.reportsView = new ReportsView({
        roles: this.rolesToReport
      });
      this.loginView = new LogInView;
      this.modal = new Modal("#modal");
      return $(document).foundationTopBar();
    };

    return Application;

  })();

  window.app = new Application;

  initSpinner = function() {
    if (!window.spin) {
      return window.spin = new Spinner({
        lines: 13,
        length: 7,
        width: 4,
        radius: 10,
        corners: 1,
        rotate: 0,
        color: '#fff',
        speed: 1,
        trail: 58,
        shadow: true,
        hwaccel: false,
        className: 'spinner',
        zIndex: 2e9,
        top: 'auto',
        left: 'auto'
      });
    }
  };

  startSpinner = function() {
    if (!window.spin) {
      initSpinner();
    }
    $("li.name a").css("visibility", "hidden");
    return window.spin.spin($("li.name")[0]);
  };

  stopSpinner = function() {
    $("li.name a").css("visibility", "visible");
    return window.spin.stop();
  };

  $.ajaxSetup({
    beforeSend: startSpinner,
    complete: stopSpinner,
    statusCode: {
      401: function() {
        $("#today, #new_entry, #logout, #this_month").hide();
        return window.app.router.navigate("/#login", {
          trigger: true
        });
      },
      403: function() {
        window.app.router.navigate("/#denied", {
          trigger: true
        });
        return $("#today, #new_entry, #logout, #this_month").hide();
      }
    }
  });

  $(document).ajaxStop(stopSpinner);

  $(document).ajaxStart(function() {
    return startSpinner();
  });

  $(document).oneTime(200, function() {
    return humane.timeout = 1000;
  });
  
}});

window.require.define({"collections/duration_kinds": function(exports, require, module) {
  var DurationKind, DurationKindsCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DurationKind = require("models/duration_kind");

  module.exports = DurationKindsCollection = (function(_super) {

    __extends(DurationKindsCollection, _super);

    function DurationKindsCollection() {
      return DurationKindsCollection.__super__.constructor.apply(this, arguments);
    }

    DurationKindsCollection.prototype.model = DurationKind;

    DurationKindsCollection.prototype.url = "/work_charts//duration_kinds.json";

    return DurationKindsCollection;

  })(Backbone.Collection);
  
}});

window.require.define({"collections/roles": function(exports, require, module) {
  var Role, RolesCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Role = require('../models/role');

  module.exports = RolesCollection = (function(_super) {

    __extends(RolesCollection, _super);

    function RolesCollection() {
      return RolesCollection.__super__.constructor.apply(this, arguments);
    }

    RolesCollection.prototype.model = Role;

    return RolesCollection;

  })(Backbone.Collection);
  
}});

window.require.define({"collections/work_charts": function(exports, require, module) {
  var WorkChart, WorkChartsCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkChart = require("models/work_chart");

  module.exports = WorkChartsCollection = (function(_super) {

    __extends(WorkChartsCollection, _super);

    function WorkChartsCollection() {
      return WorkChartsCollection.__super__.constructor.apply(this, arguments);
    }

    WorkChartsCollection.prototype.model = WorkChart;

    WorkChartsCollection.prototype.url = "/work_charts";

    return WorkChartsCollection;

  })(Backbone.Collection);
  
}});

window.require.define({"collections/work_days": function(exports, require, module) {
  var WorkDay, WorkDaysCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkDay = require("../models/work_day");

  module.exports = WorkDaysCollection = (function(_super) {

    __extends(WorkDaysCollection, _super);

    function WorkDaysCollection() {
      return WorkDaysCollection.__super__.constructor.apply(this, arguments);
    }

    WorkDaysCollection.prototype.model = WorkDay;

    WorkDaysCollection.prototype.url = "/work_days/0";

    return WorkDaysCollection;

  })(Backbone.Collection);
  
}});

window.require.define({"collections/work_entries": function(exports, require, module) {
  var WorkEntriesCollection, WorkEntry,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkEntry = require("../models/work_entry");

  module.exports = WorkEntriesCollection = (function(_super) {

    __extends(WorkEntriesCollection, _super);

    function WorkEntriesCollection() {
      return WorkEntriesCollection.__super__.constructor.apply(this, arguments);
    }

    WorkEntriesCollection.prototype.model = WorkEntry;

    WorkEntriesCollection.prototype.url = "/work_entries";

    return WorkEntriesCollection;

  })(Backbone.Collection);
  
}});

window.require.define({"collections/work_months": function(exports, require, module) {
  var WorkMonth, WorkMonthsCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkMonth = require("../models/work_month");

  module.exports = WorkMonthsCollection = (function(_super) {

    __extends(WorkMonthsCollection, _super);

    function WorkMonthsCollection() {
      return WorkMonthsCollection.__super__.constructor.apply(this, arguments);
    }

    WorkMonthsCollection.prototype.model = WorkMonth;

    WorkMonthsCollection.prototype.url = "/work_months";

    return WorkMonthsCollection;

  })(Backbone.Collection);
  
}});

window.require.define({"lib/backbone_extensions.js": function(exports, require, module) {
  
  Backbone.History.prototype.refresh = function() {
    Backbone.history.fragment = null;
    return Backbone.history.navigate(document.location.hash, true);
  };
  
}});

window.require.define({"lib/font_helper.js": function(exports, require, module) {
  
  TimesheetApp.Helpers.FontHelper = (function() {

    function FontHelper() {}

    FontHelper.get_string_width = function(context_element, string) {
      var el, width;
      el = $("<span>" + string + "</span>");
      $(context_element).append(el);
      width = el[0].offsetWidth;
      el.remove();
      return width;
    };

    return FontHelper;

  })();
  
}});

window.require.define({"lib/modal_window.js": function(exports, require, module) {
  var Modal,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  require("lib/window_extensions.js");

  module.exports = Modal = (function() {

    function Modal(selector) {
      this.show = __bind(this.show, this);
      this.selector = selector;
    }

    Modal.prototype.show = function(config) {
      if (config == null) {
        config = {};
      }
      if (config.content) {
        $(this.selector).html(config.content);
      }
      $(this.selector).reveal({
        closed: config.closed
      });
      window.scroll_top();
      return $('body').off('keyup.reveal');
    };

    return Modal;

  })();
  
}});

window.require.define({"lib/number_extensions.js": function(exports, require, module) {
  
  Number.prototype.format_money = function() {
    var fractionals, integers;
    integers = Math.floor(this);
    fractionals = this * 100 % 100;
    return "$" + integers + "." + (fractionals.toString().pad(2));
  };
  
}});

window.require.define({"lib/string_extensions.js": function(exports, require, module) {
  var TimeInterval;

  TimeInterval = require("lib/time_interval.js");

  String.prototype.format_interval = function() {
    return this.to_interval().to_s('decimal');
  };

  String.prototype.to_interval = function() {
    var hours, minutes, split_on, _ref;
    split_on = (function() {
      if (/^\d{1,9}:\d{1,2}(:\d{1,2}){0,1}$/.test(this)) {
        return ":";
      } else if (/^\d{1,9}h\s\d{1,2}m$/.test(this)) {
        return " ";
      } else {
        throw "Unsupported time interval string: " + this;
      }
    }).call(this);
    _ref = this.split(split_on), hours = _ref[0], minutes = _ref[1];
    return new TimeInterval(parseInt(hours, 10), parseInt(minutes, 10));
  };

  String.prototype.pad = function(num) {
    var n, to_slice;
    n = parseInt(this, 10);
    to_slice = this.length > num ? this.length : num;
    return String(Array(num).join("0") + n).slice(-1 * to_slice);
  };

  String.prototype.pagedown = function() {
    var converter;
    converter = Markdown.getSanitizingConverter();
    return converter.makeHtml(this);
  };
  
}});

window.require.define({"lib/table_helper.js": function(exports, require, module) {
  
  TimesheetApp.Helpers.TableHelper = (function() {

    function TableHelper() {}

    TableHelper.align_interval = function(cell) {
      return this.align_interval_to(cell, cell);
    };

    TableHelper.align_interval_to = function(reference_cell, cell) {
      var current_padding, s_hours, s_minutes, width, _ref;
      if ($(cell).attr("data-aligned") === "true") {
        return;
      }
      _ref = $(cell).text().split("."), s_hours = _ref[0], s_minutes = _ref[1];
      if (s_minutes.length === 2) {
        return;
      }
      width = TimesheetApp.Helpers.FontHelper.get_string_width(reference_cell, "0");
      current_padding = parseInt($(cell).css("padding-right"), 10);
      $(cell).css("padding-right", current_padding + width);
      return $(cell).attr("data-aligned", true);
    };

    return TableHelper;

  })();
  
}});

window.require.define({"lib/time_interval.js": function(exports, require, module) {
  var TimeInterval;

  module.exports = TimeInterval = (function() {

    function TimeInterval(hours, minutes) {
      this.hours = hours;
      this.minutes = minutes;
    }

    TimeInterval.prototype.to_s = function(format) {
      var minutes_padded;
      switch (format) {
        case "decimal":
          minutes_padded = ("" + (this.minutes * 100 / 60)).pad(2);
          return "" + this.hours + "." + minutes_padded;
        default:
          throw "Unrecognized format: " + format;
      }
    };

    return TimeInterval;

  })();
  
}});

window.require.define({"lib/window_extensions.js": function(exports, require, module) {
  
  Window.prototype.scroll_top = function() {
    return $("html, body").animate({
      scrollTop: 0
    }, "slow");
  };
  
}});

window.require.define({"models/collection": function(exports, require, module) {
  var Collection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = Collection = (function(_super) {

    __extends(Collection, _super);

    function Collection() {
      return Collection.__super__.constructor.apply(this, arguments);
    }

    Collection.prototype.model = require('./model');

    return Collection;

  })(Backbone.Collection);
  
}});

window.require.define({"models/duration_kind": function(exports, require, module) {
  var DurationKind,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = DurationKind = (function(_super) {

    __extends(DurationKind, _super);

    function DurationKind() {
      this.url = __bind(this.url, this);
      return DurationKind.__super__.constructor.apply(this, arguments);
    }

    DurationKind.prototype.url = function() {
      return "/work_charts//duration_kinds.json";
    };

    return DurationKind;

  })(Backbone.Model);
  
}});

window.require.define({"models/model": function(exports, require, module) {
  var Model,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = Model = (function(_super) {

    __extends(Model, _super);

    function Model() {
      return Model.__super__.constructor.apply(this, arguments);
    }

    return Model;

  })(Backbone.Model);
  
}});

window.require.define({"models/role": function(exports, require, module) {
  var Role,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = Role = (function(_super) {

    __extends(Role, _super);

    function Role() {
      this.assume_async = __bind(this.assume_async, this);

      this.assumed_other = __bind(this.assumed_other, this);

      this.as_label = __bind(this.as_label, this);

      this.user_name = __bind(this.user_name, this);
      return Role.__super__.constructor.apply(this, arguments);
    }

    Role.prototype.defaults = {
      can_switch_roles: false
    };

    Role.prototype.user_name = function() {
      return this.get('display_label').split(":")[1];
    };

    Role.prototype.as_label = function() {
      if (this.assumed_other()) {
        return this.get('as').split(":")[1];
      }
    };

    Role.prototype.assumed_other = function() {
      return this.get('as') !== void 0 && this.get('as') !== null;
    };

    Role.prototype.assume_async = function(config) {
      var _this = this;
      return $.ajax({
        url: "/roles/assume.json",
        type: "POST",
        data: {
          email: this.get('email')
        },
        success: function(data) {
          if (config.success) {
            return config.success(data);
          }
        },
        error: function(xhr, status, err) {
          if (config.error) {
            return config.error(err);
          }
        }
      });
    };

    return Role;

  })(Backbone.Model);
  
}});

window.require.define({"models/work_chart": function(exports, require, module) {
  var WorkChart,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = WorkChart = (function(_super) {

    __extends(WorkChart, _super);

    function WorkChart() {
      this.url = __bind(this.url, this);
      return WorkChart.__super__.constructor.apply(this, arguments);
    }

    WorkChart.prototype.url = function() {
      return "/work_charts/" + this.id + ".json";
    };

    return WorkChart;

  })(Backbone.Model);
  
}});

window.require.define({"models/work_day": function(exports, require, module) {
  var WorkDay,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = WorkDay = (function(_super) {

    __extends(WorkDay, _super);

    function WorkDay() {
      this.href = __bind(this.href, this);

      this.week_of_date = __bind(this.week_of_date, this);

      this.date_class = __bind(this.date_class, this);

      this.status_class = __bind(this.status_class, this);

      this.day = __bind(this.day, this);

      this.nonbillable_time_string = __bind(this.nonbillable_time_string, this);

      this.billable_time_string = __bind(this.billable_time_string, this);

      this.time_string = __bind(this.time_string, this);

      this.in_future = __bind(this.in_future, this);

      this.date_string = __bind(this.date_string, this);

      this.data_url = __bind(this.data_url, this);
      return WorkDay.__super__.constructor.apply(this, arguments);
    }

    WorkDay.prototype.data_url = function() {
      var date;
      date = moment.utc(new Date(this.get("date")));
      return "#entries/" + (date.year()) + "/" + (date.month() + 1) + "/" + (date.date());
    };

    WorkDay.prototype.date_string = function() {
      var date;
      date = moment.utc(new Date(this.get("date")));
      return "" + (date.format('YYYY-MM-DD, dddd'));
    };

    WorkDay.prototype.in_future = function() {
      var date, now;
      date = moment(this.get("date"));
      now = moment(new Date());
      if (date.year() > now.year()) {
        return true;
      } else {
        if (date.year() < now.year()) {
          return false;
        } else {
          if (date.month() > now.month()) {
            return true;
          } else {
            if (date.month() < now.month()) {
              return false;
            } else {
              if (date.date() > now.date()) {
                return true;
              } else {
                return false;
              }
            }
          }
        }
      }
    };

    WorkDay.prototype.time_string = function() {
      var date;
      if (this.get("time")) {
        return this.get("time").format_interval();
      } else {
        date = moment.utc(this.get("date"));
        if (date.day() === 0 || date.day() === 6) {
          return "";
        } else {
          return "0h 0m".format_interval();
        }
      }
    };

    WorkDay.prototype.billable_time_string = function() {
      var date;
      if (this.get("billable_time")) {
        return this.get("billable_time").format_interval();
      } else {
        date = moment.utc(this.get("date"));
        if (date.day() === 0 || date.day() === 6) {
          return "";
        } else {
          return "0h 0m".format_interval();
        }
      }
    };

    WorkDay.prototype.nonbillable_time_string = function() {
      var date;
      if (this.get("nonbillable_time")) {
        return this.get("nonbillable_time").format_interval();
      } else {
        date = moment.utc(this.get("date"));
        if (date.day() === 0 || date.day() === 6) {
          return "";
        } else {
          return "0h 0m".format_interval();
        }
      }
    };

    WorkDay.prototype.day_name = function(day) {
      switch (day) {
        case 0:
          return "Sunday";
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thursday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
      }
    };

    WorkDay.prototype.day = function() {
      return moment(this.get("date")).date();
    };

    WorkDay.prototype.status_class = function() {
      var date, today;
      if (this.get("has_zero")) {
        return "status-has-zero";
      }
      date = moment(this.get("date"));
      today = moment(new Date());
      if (date.year() === today.year() && date.month() === today.month() && date.date() === today.date()) {
        return "status-today";
      } else {
        if (date.diff(moment(new Date())) > 0 || date.day() === 6 || date.day() === 0) {
          if (parseInt(this.get("time").split(":")[0], 10) > 0) {
            return "status-ok";
          } else {
            return "status-notyet";
          }
        } else {
          if (parseInt(this.get("time").split(":")[0], 10) < 8) {
            return "status-little";
          } else {
            return "status-ok";
          }
        }
      }
    };

    WorkDay.prototype.date_class = function(year, month) {
      var date, today;
      date = moment(this.get("date"));
      today = moment(new Date());
      return "day-" + (date.day()) + " week-" + (this.week_of_date(date, year, month)) + " " + (date.year() === today.year() && date.month() === today.month() && date.date() === today.date() ? 'today' : void 0) + " " + (date.day() === 0 || date.day() === 6 ? 'weekend' : void 0) + " " + (date.month() + 1 !== month ? 'out-of-month' : void 0) + " " + (this.status_class());
    };

    WorkDay.prototype.week_of_date = function(date, year, month) {
      var m, y, _date;
      m = parseInt(month);
      y = parseInt(year);
      if ((date.month() + 1 < m && date.year() === y) || date.year() < y) {
        return 1;
      } else {
        if (date.month() + 1 > m || year < date.year()) {
          _date = moment([date.year(), date.month(), 1]);
          _date.subtract('months', 1);
          _date.endOf('month');
          return Math.ceil((_date.date() + moment(_date).date(1).day()) / 7);
        } else {
          return Math.ceil((date.date() + moment(date).date(1).day()) / 7);
        }
      }
    };

    WorkDay.prototype.href = function() {
      var date;
      date = moment.utc(this.get("date"));
      return "/#entries/" + (date.year()) + "/" + (date.month() + 1) + "/" + (date.date());
    };

    return WorkDay;

  })(Backbone.Model);
  
}});

window.require.define({"models/work_entry": function(exports, require, module) {
  var WorkEntry,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  require("lib/number_extensions.js");

  module.exports = WorkEntry = (function(_super) {

    __extends(WorkEntry, _super);

    function WorkEntry() {
      this.delete_async = __bind(this.delete_async, this);

      this.front_url = __bind(this.front_url, this);

      this.fee_not_empty = __bind(this.fee_not_empty, this);

      this.fee_total_string = __bind(this.fee_total_string, this);

      this.time_string = __bind(this.time_string, this);

      this.nonbillable_minutes = __bind(this.nonbillable_minutes, this);

      this.nonbillable_hours = __bind(this.nonbillable_hours, this);

      this.billable_minutes = __bind(this.billable_minutes, this);

      this.billable_hours = __bind(this.billable_hours, this);

      this.minutes = __bind(this.minutes, this);

      this.hours = __bind(this.hours, this);

      this.middle_labels = __bind(this.middle_labels, this);

      this.last_label = __bind(this.last_label, this);

      this.chart_has_many_labels = __bind(this.chart_has_many_labels, this);

      this.top_label = __bind(this.top_label, this);

      this.url = __bind(this.url, this);
      return WorkEntry.__super__.constructor.apply(this, arguments);
    }

    WorkEntry.prototype.defaults = {
      work_chart_id: -1,
      work_entry_fees: [],
      description: "",
      work_entry_durations: [
        {
          duration: "00:00:00"
        }
      ]
    };

    WorkEntry.prototype.url = function() {
      return "/work_entries/" + this.id + ".json";
    };

    WorkEntry.prototype.top_label = function() {
      return _.first(_.rest(this.get("work_chart_label_parts")));
    };

    WorkEntry.prototype.chart_has_many_labels = function() {
      return this.get("work_chart_label_parts").length > 2;
    };

    WorkEntry.prototype.last_label = function() {
      return _.last(this.get("work_chart_label_parts"));
    };

    WorkEntry.prototype.middle_labels = function() {
      return _.rest(_.rest(_.initial(this.get("work_chart_label_parts"))));
    };

    WorkEntry.prototype.hours = function() {
      return this.get("total_duration").split(":")[0];
    };

    WorkEntry.prototype.minutes = function() {
      return this.get("total_duration").split(":")[1];
    };

    WorkEntry.prototype.billable_hours = function() {
      return parseInt(this.get("total_billable").split(":")[0], 10);
    };

    WorkEntry.prototype.billable_minutes = function() {
      return parseInt(this.get("total_billable").split(":")[1], 10);
    };

    WorkEntry.prototype.nonbillable_hours = function() {
      return parseInt(this.get("total_nonbillable").split(":")[0], 10);
    };

    WorkEntry.prototype.nonbillable_minutes = function() {
      return parseInt(this.get("total_nonbillable").split(":")[1], 10);
    };

    WorkEntry.prototype.time_string = function() {
      return this.get("total_duration").format_interval();
    };

    WorkEntry.prototype.fee_total_string = function() {
      return this.get("fee_total").format_money();
    };

    WorkEntry.prototype.fee_not_empty = function() {
      return this.get("fee_total") > 0;
    };

    WorkEntry.prototype.front_url = function() {
      return "/#entry/" + (this.get("id"));
    };

    WorkEntry.prototype.delete_async = function(config) {
      var date;
      if (config == null) {
        config = {};
      }
      date = moment(this.get('date_performed'));
      return $.ajax({
        url: "/work_day_entries/" + (date.year()) + "/" + (date.month() + 1) + "/" + (date.date()) + "/work_entries/" + (this.get('id')),
        type: "DELETE",
        success: config.success,
        error: function(xhr, status, err) {
          return config.error(err);
        }
      });
    };

    return WorkEntry;

  })(Backbone.Model);
  
}});

window.require.define({"models/work_month": function(exports, require, module) {
  var WorkMonth,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = WorkMonth = (function(_super) {

    __extends(WorkMonth, _super);

    function WorkMonth() {
      this.month_class = __bind(this.month_class, this);

      this.front_url = __bind(this.front_url, this);

      this.month_year_string = __bind(this.month_year_string, this);

      this.nonbillable_string = __bind(this.nonbillable_string, this);

      this.billable_string = __bind(this.billable_string, this);

      this.total_string = __bind(this.total_string, this);

      this.available_string = __bind(this.available_string, this);
      return WorkMonth.__super__.constructor.apply(this, arguments);
    }

    WorkMonth.prototype.defaults = {
      year: 2012,
      month: 11,
      available: 160,
      billable_total: "80h 0m",
      nonbillable_total: "80h 0m",
      total: "160h 0m"
    };

    WorkMonth.prototype.available_string = function() {
      return ("" + (this.get('available')) + "h 0m").format_interval();
    };

    WorkMonth.prototype.total_string = function() {
      return this.get('total').format_interval();
    };

    WorkMonth.prototype.billable_string = function() {
      return this.get('billable_total').format_interval();
    };

    WorkMonth.prototype.nonbillable_string = function() {
      return this.get('nonbillable_total').format_interval();
    };

    WorkMonth.prototype.month_year_string = function() {
      return moment.utc([this.get('year'), this.get('month') - 1, 1]).format("MMMM YYYY");
    };

    WorkMonth.prototype.front_url = function() {
      return "/#calendar/" + (this.get('year')) + "/" + (this.get('month'));
    };

    WorkMonth.prototype.month_class = function() {
      var date, total_hours;
      date = moment();
      if (this.get('month') > date.month() + 1) {
        return 'month-notyet';
      } else {
        if (this.get('month') === date.month() + 1) {
          return 'month-current';
        } else {
          total_hours = parseInt(this.get('total').split(" ")[0]);
          if (total_hours >= this.get('available')) {
            return 'month-ok';
          } else {
            return 'month-little';
          }
        }
      }
    };

    return WorkMonth;

  })(Backbone.Model);
  
}});

window.require.define({"routers/router": function(exports, require, module) {
  var CalendarView, EntryEditView, EntryNewView, Router, WorkDayView, WorkDaysCollection, WorkEntriesCollection, WorkEntry, WorkMonthsCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkMonthsCollection = require('collections/work_months');

  WorkDaysCollection = require('collections/work_days');

  WorkEntriesCollection = require("collections/work_entries");

  WorkEntry = require("models/work_entry");

  CalendarView = require("views/calendar");

  EntryNewView = require("views/entries/new");

  EntryEditView = require("views/entries/edit");

  WorkDayView = require("views/work_day");

  module.exports = Router = (function(_super) {
    var _this = this;

    __extends(Router, _super);

    function Router() {
      return Router.__super__.constructor.apply(this, arguments);
    }

    Router.prototype.routes = {
      '': 'root',
      'login': 'login',
      'calendar/:year/:month': 'home',
      'entry/:id': 'edit_entry',
      'entries/:year/:month/:day/new': 'new_entry',
      'work_days/:weeks_from_now': 'work_days',
      'entries/:year/:month/:day': 'work_day',
      'reports': 'reports'
    };

    Router.prototype.redirect = function() {
      return this.navigate('');
    };

    Router.prototype.initialize = function() {
      var _this = this;
      this.on("admin:assume-other", function() {
        _this.current_role = app.current_role;
        _this.current_role.fetch();
        return app.rolesToSwitch.fetch();
      });
      this.modal = app.modal;
      return this.navigate('/#', {
        trigger: true
      });
    };

    Router.prototype.before = {
      '^((?!login).)*$': function() {
        this.render_navigation();
        return app.current_role.fetch();
      },
      'login': function() {
        return $(".top-bar").html("");
      }
    };

    Router.prototype.render_navigation = function() {
      return app.topBarView.render();
    };

    Router.prototype.reports = function() {
      var _this = this;
      app.rolesToReport.fetch();
      return $(window).oneTime(100, function() {
        return app.reportsView.render();
      });
    };

    Router.prototype.login = function() {
      var _this = this;
      return $(window).oneTime(100, function() {
        return app.loginView.render();
      });
    };

    Router.prototype.root = function() {
      var date;
      if (window.location.pathname !== "/users/sign_in") {
        date = moment(new Date());
        return this.navigate("/#calendar/" + (date.year()) + "/" + (date.month() + 1), {
          trigger: true
        });
      }
    };

    Router.prototype.home = function(year, month) {
      var before, days, months, now, view;
      months = new WorkMonthsCollection();
      days = new WorkDaysCollection();
      days.url = "/work_days/calendar/" + year + "/" + month + ".json";
      now = moment.utc([parseInt(year, 10), parseInt(month, 10) - 1, 1]);
      before = moment.utc(now).subtract('months', 5);
      months.url = "/work_months/" + (before.format('YYYY-MM-01')) + "/" + (now.format('YYYY-MM-01')) + ".json";
      view = new CalendarView({
        collection: days,
        year: year,
        month: month,
        months: months
      });
      days.fetch();
      return months.fetch();
    };

    Router.prototype.new_entry = function(year, month, day) {
      var entry, view,
        _this = this;
      day = moment.utc([year, month - 1, day]).format("YYYY-MM-DD");
      entry = new WorkEntry({
        date_performed: day
      });
      entry.set("work_entry_durations", [
        {
          duration: "00:00:00"
        }
      ]);
      view = new EntryNewView({
        model: entry
      });
      return $(window).oneTime(100, function() {
        return view.render();
      });
    };

    Router.prototype.edit_entry = function(id) {
      var entry, view;
      entry = new WorkEntry({
        id: id
      });
      view = new EntryEditView({
        model: entry,
        charts: this.work_charts
      });
      return entry.fetch();
    };

    Router.prototype.work_days = function(weeks_from_now) {
      var days, view;
      days = new TimesheetApp.Collections.WorkDaysCollection();
      view = new TimesheetApp.Views.WorkDays.IndexView({
        collection: days,
        weeks_from_now: weeks_from_now
      });
      days.url = "/work_days/" + weeks_from_now + ".json";
      return days.fetch();
    };

    Router.prototype.work_day = function(year, month, day) {
      var entries, view;
      console.info("Work day");
      entries = new WorkEntriesCollection();
      view = new WorkDayView({
        collection: entries,
        year: year,
        month: month,
        day: day
      });
      entries.url = "/work_day_entries/" + year + "/" + month + "/" + day + ".json";
      return entries.fetch();
    };

    return Router;

  }).call(this, Backbone.Router);
  
}});

window.require.define({"views/admin/switch_role": function(exports, require, module) {
  var SwitchRoleView, SwitchRoleViewModel,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = SwitchRoleView = (function(_super) {

    __extends(SwitchRoleView, _super);

    function SwitchRoleView() {
      return SwitchRoleView.__super__.constructor.apply(this, arguments);
    }

    SwitchRoleView.prototype.template = require("../templates/admin/switch_role");

    SwitchRoleView.prototype.initialize = function() {
      var _this = this;
      this.other_roles = this.options.other_roles;
      this.other_roles.on("reset", function() {
        return _this.render();
      });
      this.view = new SwitchRoleViewModel;
      return this.other_roles.on("reset", function() {
        return _this.view.roles(_this.other_roles.models);
      });
    };

    SwitchRoleView.prototype.render = function() {
      $("#modal").html(this.template()).reveal({
        closed: function() {
          return $("#modal").html("");
        }
      });
      $("#modal .close-reveal-modal").click(function() {
        return $('#modal').trigger('reveal:close');
      });
      ko.applyBindings(this.view, $("#modal")[0]);
      return false;
    };

    return SwitchRoleView;

  })(Backbone.View);

  SwitchRoleViewModel = (function() {

    function SwitchRoleViewModel() {
      var _this = this;
      this.roles = ko.observableArray([]);
      this.assume_role = function(role) {
        console.info("Assuming role of " + (role.user_name()));
        return role.assume_async({
          success: function(data) {
            Backbone.history.fragment = null;
            Backbone.history.navigate(document.location.hash, true);
            window.app.router.current_role.fetch();
            return $("#modal").trigger('reveal:close');
          },
          error: function(data) {
            return console.info("implement me");
          }
        });
      };
    }

    return SwitchRoleViewModel;

  })();
  
}});

window.require.define({"views/auth/login": function(exports, require, module) {
  var LogInView,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = LogInView = (function(_super) {

    __extends(LogInView, _super);

    function LogInView() {
      this.login = __bind(this.login, this);

      this.render = __bind(this.render, this);
      return LogInView.__super__.constructor.apply(this, arguments);
    }

    LogInView.prototype.template = require("../templates/auth/login");

    LogInView.prototype.render = function() {
      var _this = this;
      $("#main").html(this.template());
      $("header.row").html("<h1>Log in</h1><h4>Fill in the form and come aboard!</h4>");
      $("#logout, #today, #new_entry, #admin, #this_month").hide();
      $("#side").html("");
      $(".button.login").click(this.login);
      $("#user_email").focus();
      return $("#new_user input").keypress(function(e) {
        if (e.keyCode === 13 && !e.shiftKey) {
          _this.login();
          return false;
        }
      });
    };

    LogInView.prototype.login = function() {
      var _this = this;
      return $.ajax({
        url: "/users/sign_in.json",
        type: "POST",
        data: {
          user: {
            email: $("#user_email").val(),
            password: $("#user_password").val(),
            remember_me: 1
          }
        },
        success: function(data) {
          if (data.success) {
            humane.log("Welcome aboard!");
            return $(window).oneTime(500, function() {
              return Backbone.history.navigate("/#", true);
            });
          } else {
            return humane.log(data.errors);
          }
        },
        error: function(xhr, status, err) {
          return humane.log(err);
        }
      });
    };

    return LogInView;

  })(Backbone.View);
  
}});

window.require.define({"views/calendar": function(exports, require, module) {
  var CalendarView, CalendarViewModel,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  require("../lib/string_extensions.js");

  module.exports = CalendarView = (function(_super) {

    __extends(CalendarView, _super);

    function CalendarView() {
      return CalendarView.__super__.constructor.apply(this, arguments);
    }

    CalendarView.prototype.template = require("./templates/calendar/index");

    CalendarView.prototype.top_tpl = require("./templates/calendar/top");

    CalendarView.prototype.initialize = function() {
      var _this = this;
      this.view = new CalendarViewModel(this.options.year, this.options.month);
      this.collection = this.options.collection;
      this.collection.on("reset", function() {
        _this.render();
        return _this.view.days(_this.collection.models);
      });
      this.months = this.options.months;
      return this.months.on("reset", function() {
        return _this.view.work_months(_this.months.models);
      });
    };

    CalendarView.prototype.render = function() {
      $(this.el).html(this.template());
      $("#side").html("");
      $("header.row").html(this.top_tpl());
      $("#main").html(this.el);
      ko.applyBindings(this.view, $("#main")[0]);
      return ko.applyBindings(this.view, $("header.row")[0]);
    };

    return CalendarView;

  })(Backbone.View);

  CalendarViewModel = (function() {

    function CalendarViewModel(year, month) {
      var date, days, max_year, _i, _ref, _results,
        _this = this;
      date = moment("2012-11-01");
      days = [];
      this.days = ko.observableArray(days);
      this.work_months = ko.observableArray([]);
      this.week_totals = ko.computed(function() {
        var grouped, reduceTime;
        grouped = _.groupBy(_this.days(), function(day) {
          var week;
          date = moment.utc(day.get("date"));
          week = day.week_of_date(date, parseInt(year, 10), parseInt(month, 10));
          return week;
        });
        reduceTime = function(memo, time) {
          var hours, mh, minutes, mm, nh, nm, _ref, _ref1;
          _ref = _.map(memo.split(" "), function(i) {
            return parseInt(i, 10);
          }), mh = _ref[0], mm = _ref[1];
          _ref1 = _.map(time.split(":"), function(i) {
            return parseInt(i, 10);
          }), hours = _ref1[0], minutes = _ref1[1];
          nm = mm + minutes;
          nh = mh + hours;
          if (nm >= 60) {
            nh = nh + 1;
            nm = nm - 60;
          }
          return "" + nh + "h " + nm + "m";
        };
        return _.map(_.values(grouped), function(days) {
          return {
            total: (_.reduce(_.map(days, function(day) {
              return day.get("time");
            }), reduceTime, "0h 0m")).format_interval(),
            billable_total: (_.reduce(_.map(days, function(day) {
              return day.get("billable_time");
            }), reduceTime, "0h 0m")).format_interval(),
            nonbillable_total: (_.reduce(_.map(days, function(day) {
              return day.get("nonbillable_time");
            }), reduceTime, "0h 0m")).format_interval(),
            total_class: function() {
              var hours, minutes, total, _ref;
              date = moment(days[0].get("date"));
              if (date > moment.utc()) {
                return 'total-notyet';
              } else if (moment.utc(_.last(days).get("date")) > moment.utc() && date < moment.utc()) {
                return 'total-thisweek';
              } else {
                total = _.reduce(_.map(days, function(day) {
                  return day.get("time");
                }), reduceTime, "0h 0m");
                _ref = total.split(" "), hours = _ref[0], minutes = _ref[1];
                if (parseInt(hours, 10) >= 40) {
                  return 'total-ok';
                } else {
                  return 'total-little';
                }
              }
            }
          };
        });
      });
      this.year = ko.observable(year);
      this.month = ko.observable(month);
      max_year = moment(new Date()).year();
      this.years = ko.observableArray((function() {
        _results = [];
        for (var _i = 2002, _ref = Math.max(max_year, parseInt(year)); 2002 <= _ref ? _i <= _ref : _i >= _ref; 2002 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).reverse());
      this.months = ko.observableArray($.map(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], function(el, i) {
        return {
          name: el,
          value: i + 1
        };
      }));
      this.goto = function(e) {
        return Backbone.history.navigate(e.href(), true);
      };
      this.year.subscribe(function(y) {
        if (y.toString() !== year) {
          return Backbone.history.navigate("/#calendar/" + y + "/" + month, true);
        }
      });
      this.month.subscribe(function(m) {
        if (m.toString() !== month) {
          return Backbone.history.navigate("/#calendar/" + year + "/" + m, true);
        }
      });
      this.redirect_to_month = function(month) {
        return window.app.router.navigate(month.front_url(), {
          trigger: true
        });
      };
      this.backMonth = function() {
        date = moment();
        date.year(year);
        date.month(parseInt(month) - 1);
        date.subtract('months', 1);
        return Backbone.history.navigate("/#calendar/" + (date.year()) + "/" + (date.month() + 1), true);
      };
      this.nextMonth = function() {
        date = moment();
        date.year(year);
        date.month(parseInt(month) - 1);
        date.add('months', 1);
        return Backbone.history.navigate("/#calendar/" + (date.year()) + "/" + (date.month() + 1), true);
      };
    }

    return CalendarViewModel;

  })();
  
}});

window.require.define({"views/entries/edit": function(exports, require, module) {
  var DurationKindsCollection, EntryEditView, WorkChart, WorkChartsCollection,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkChart = require("models/work_chart");

  WorkChartsCollection = require("collections/work_charts");

  DurationKindsCollection = require("collections/duration_kinds");

  module.exports = EntryEditView = (function(_super) {

    __extends(EntryEditView, _super);

    function EntryEditView() {
      this.render = __bind(this.render, this);

      this.set_search = __bind(this.set_search, this);

      this.render_charts = __bind(this.render_charts, this);

      this.rebuild_charts_array_for = __bind(this.rebuild_charts_array_for, this);

      this.handle_quick_pick_option = __bind(this.handle_quick_pick_option, this);

      this.render_durations = __bind(this.render_durations, this);

      this.render_recents = __bind(this.render_recents, this);

      this.render_frequents = __bind(this.render_frequents, this);

      this.render_searches = __bind(this.render_searches, this);

      this.set_duration_minutes = __bind(this.set_duration_minutes, this);

      this.set_duration_hour = __bind(this.set_duration_hour, this);

      this.persist = __bind(this.persist, this);

      this.back = __bind(this.back, this);

      this["delete"] = __bind(this["delete"], this);
      return EntryEditView.__super__.constructor.apply(this, arguments);
    }

    EntryEditView.prototype.template = require("../templates/entries/form");

    EntryEditView.prototype.selects_template = require("../templates/entries/selects");

    EntryEditView.prototype.durations_template = require("../templates/entries/durations");

    EntryEditView.prototype["delete"] = function() {
      var date,
        _this = this;
      if (confirm("Are you sure you want to delete this entry?")) {
        date = moment.utc(this.model.get("date_performed"));
        $.ajax({
          url: "/work_entries/" + (this.model.get('id')),
          type: "DELETE",
          success: function(data) {
            if (data.status === 'OK') {
              humane.log("Entry deleted");
              return _this.back();
            } else {
              return humane.log(data.errors);
            }
          },
          error: function(xhr, status, err) {
            return humane.log(err);
          }
        });
      }
      return false;
    };

    EntryEditView.prototype.back = function() {
      var date, format, performed;
      performed = this.model.get("date_performed");
      format = performed.length > 10 ? "ddd, YYYY-MM-DD" : "YYYY-MM-DD";
      date = moment.utc(performed, format);
      Backbone.history.navigate("entries/" + (date.year()) + "/" + (date.month() + 1) + "/" + (date.date()), true);
      return $("#modal").trigger('reveal:close');
    };

    EntryEditView.prototype.persist = function() {
      var data, date, durations, fees, s_fee,
        _this = this;
      this.model.set("work_chart_id", this.selected_chart.get("id"), {
        silent: true
      });
      this.model.set("date_performed", $("#work_entry_date_performed").val(), {
        silent: true
      });
      this.model.set("description", $("#work_entry_description").val(), {
        silent: true
      });
      durations = $(".single-duration").map(function(i, s) {
        return {
          kind_code: $(".kind_code_select", s).val(),
          duration_hours: $(".hour-select", s).val(),
          duration_minutes: $(".minutes-select", s).val(),
          created_by: _this.model.get('work_entry_durations')[0].created_by,
          modified_by: _this.model.get('work_entry_durations')[0].created_by,
          id: _this.model.get('work_entry_durations')[i].id
        };
      });
      this.model.set("work_entry_durations", durations.toArray(), {
        silent: true
      });
      s_fee = $("#work_entry_work_entry_fees_attributes_0_fee").val();
      if (_.isNaN(parseFloat(s_fee, 10))) {
        s_fee = "0";
      }
      fees = [
        {
          fee: parseFloat(s_fee, 10)
        }
      ];
      this.model.set("work_entry_fees", fees, {
        silent: true
      });
      date = moment.utc(this.model.get("date_performed"));
      data = this.model.toJSON();
      data.work_entry_durations_attributes = data.work_entry_durations;
      delete data.work_entry_durations;
      data.work_entry_fees_attributes = data.work_entry_fees;
      delete data.work_entry_fees;
      $.ajax({
        url: "/work_entries/" + (this.model.get('id')),
        type: "PUT",
        data: {
          work_entry: data
        },
        success: function() {
          humane.log("Entry saved");
          return _this.back();
        },
        error: function(xhr, status, err) {
          return humane.log(err);
        }
      });
      return false;
    };

    EntryEditView.prototype.initialize = function() {
      var _this = this;
      this.model.bind("change", this.render);
      this.charts = [];
      this.charts[0] = new WorkChartsCollection();
      this.charts[0].on("reset", this.render_charts);
      this.show_inactive = false;
      this.frequents = new WorkChartsCollection();
      this.frequents.url = "/work_charts/frequent.json";
      this.frequents.on("reset", this.render_frequents);
      this.recents = new WorkChartsCollection();
      this.recents.url = "/work_charts/recent.json";
      this.recents.on("reset", this.render_recents);
      this.searches = new WorkChartsCollection();
      this.duration_kinds = new DurationKindsCollection();
      this.duration_kinds.on("reset", function() {
        var durations, hours, hours_to_add, kinds, minutes, minutes_to_add, new_hours, new_minutes, to_wipe, _ref;
        _this.render_durations();
        durations = _this.model.get("work_entry_durations");
        kinds = _this.duration_kinds.pluck("code");
        if (_this.duration_kinds.size() < durations.length) {
          to_wipe = _.filter(durations, function(d) {
            return !_.contains(kinds, d.kind_code);
          });
          durations = _.difference(durations, to_wipe);
          _ref = durations[0].duration.split(";"), hours = _ref[0], minutes = _ref[1];
          hours_to_add = _.map(to_wipe, function(d) {
            return parseInt(d.duration.split(":")[0], 10);
          });
          minutes_to_add = _.map(to_wipe, function(d) {
            return parseInt(d.duration.split(":")[1], 10);
          });
          new_hours = (parseInt(hours, 10)) + _.reduce(hours_to_add, (function(s, i) {
            return s + i;
          }), 0);
          new_minutes = (parseInt(minutes, 10)) + _.reduce(minutes_to_add, (function(s, i) {
            return s + i;
          }), 0);
          durations[0].duration = "" + new_hours + ":" + new_minutes + ":00";
          durations[0].kind_code = _.first(_this.duration_kinds.models).get('code');
          _this.model.set("work_entry_durations", durations, {
            silent: true
          });
          return _this.render_durations();
        }
      });
      this.selected_chart = new WorkChart();
      return this.selected_chart.on("change", function() {
        _this.rebuild_charts_array_for(_this.selected_chart);
        _this.duration_kinds.url = "/work_charts/" + (_this.selected_chart.get('id')) + "/duration_kinds.json";
        return _this.duration_kinds.fetch();
      });
    };

    EntryEditView.prototype.set_duration_hour = function(index, hour) {
      var d, durations, minute, _hour, _ref;
      durations = this.model.get("work_entry_durations");
      d = durations[index].duration;
      _ref = d.split(":"), _hour = _ref[0], minute = _ref[1];
      durations[index].duration = "" + hour + ":" + minute + ":00";
      return this.model.set("work_entry_durations", durations, {
        silent: true
      });
    };

    EntryEditView.prototype.set_duration_minutes = function(index, minute) {
      var d, durations, hour, _minute, _ref;
      durations = this.model.get("work_entry_durations");
      d = durations[index].duration;
      _ref = d.split(":"), hour = _ref[0], _minute = _ref[1];
      durations[index].duration = "" + hour + ":" + minute + ":00";
      return this.model.set("work_entry_durations", durations, {
        silent: true
      });
    };

    EntryEditView.prototype.render_searches = function() {
      var lis;
      lis = this.searches.map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(1, 11).join(' / ')) + "</li>";
      });
      $(".search-results ul").html(lis.join("\n"));
      return $(".search-results ul li").click(this.handle_quick_pick_option);
    };

    EntryEditView.prototype.render_frequents = function() {
      var clients, clis, olis, others;
      clients = this.frequents.filter(function(chart) {
        return chart.get('labels').length > 3 && chart.get('labels')[1] === "Clients";
      });
      others = this.frequents.filter(function(chart) {
        return chart.get('labels').length < 3 || chart.get('labels')[1] !== "Clients";
      });
      clis = _.sortBy(clients, function(c) {
        return c.get("labels")[2];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(2, 11).join(' / ')) + "</li>";
      });
      olis = _.sortBy(others, function(c) {
        return c.get("labels")[1];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(1, 11).join(' / ')) + "</li>";
      });
      $(".frequent ul.clients").html(clis.join("\n"));
      $(".frequent ul.other").html(olis.join("\n"));
      return $(".frequent ul li").click(this.handle_quick_pick_option);
    };

    EntryEditView.prototype.render_recents = function() {
      var clients, clis, olis, others;
      clients = this.recents.filter(function(chart) {
        return chart.get('labels').length > 3 && chart.get('labels')[1] === "Clients";
      });
      others = this.recents.filter(function(chart) {
        return chart.get('labels').length < 3 || chart.get('labels')[1] !== "Clients";
      });
      clis = _.sortBy(clients, function(c) {
        return c.get("labels")[2];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(2, 11).join(' / ')) + "</li>";
      });
      olis = _.sortBy(others, function(c) {
        return c.get("labels")[1];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(1, 11).join(' / ')) + "</li>";
      });
      $(".recent ul.clients").html(clis.join("\n"));
      $(".recent ul.other").html(olis.join("\n"));
      return $(".recent ul li").click(this.handle_quick_pick_option);
    };

    EntryEditView.prototype.render_durations = function() {
      var data,
        _this = this;
      data = {
        work_entry: this.model.toJSON(),
        duration_kinds: this.duration_kinds.toJSON()
      };
      $(".durations").html(this.durations_template(data));
      $(".durations .hour-button").click(function(e) {
        var btn, div, hour, index;
        btn = $(e.currentTarget);
        div = $(e.currentTarget).parents(".single-duration");
        hour = btn.attr("data-hour");
        $(" .hour-button", div).removeClass("selected");
        btn.addClass("selected");
        $(" .hour-select option", div).attr("selected", "");
        $(" .hour-select option[value=" + hour + "]", div).attr("selected", "selected");
        index = parseInt($(e.currentTarget).attr("data-index"), 10);
        _this.set_duration_hour(index, hour);
        return false;
      });
      $(" .hour-select").change(function(e) {
        var div, hour, index;
        hour = $(e.currentTarget).val();
        div = $(e.currentTarget).parents(".single-duration");
        $(" .hour-button", div).removeClass("selected");
        $(" .hour-button[data-hour=" + hour + "]", div).addClass("selected");
        index = parseInt($(e.currentTarget).attr("data-index"), 10);
        _this.set_duration_hour(index, hour);
        return false;
      });
      $(" .minutes-select").change(function(e) {
        var div, index, minutes;
        minutes = $(e.currentTarget).val();
        div = $(e.currentTarget).parents(".single-duration");
        $(" .minute-button", div).removeClass("selected");
        $(" .minute-button[data-minute=" + minutes + "]", div).addClass("selected");
        index = parseInt($(e.currentTarget).attr("data-index"), 10);
        return _this.set_duration_minutes(index, minutes);
      });
      $(" .minute-button").click(function(e) {
        var btn, div, index, minutes;
        btn = $(e.currentTarget);
        div = $(e.currentTarget).parents(".single-duration");
        minutes = btn.attr("data-minute");
        $(" .minute-button", div).removeClass("selected");
        btn.addClass("selected");
        $(" .minutes-select option", div).attr("selected", "");
        $(" .minutes-select option[value=" + minutes + "]", div).attr("selected", "selected");
        index = parseInt($(e.currentTarget).attr("data-index"), 10);
        _this.set_duration_minutes(index, minutes);
        return false;
      });
      $(" .button.add:not(.disabled)").click(function() {
        var durations, last_duration, new_duration;
        durations = _this.model.get("work_entry_durations");
        last_duration = _.last(durations);
        new_duration = last_duration.constructor();
        new_duration.duration = "00:00:00";
        new_duration.modified_by = last_duration.modified_by;
        new_duration.kind_code = _.first(_this.duration_kinds.filter(function(k) {
          return !_.include(_.pluck(durations, "kind_code"), k.get("code"));
        })).get("code");
        durations.push(new_duration);
        _this.model.set("work_entry_durations", durations, {
          silent: true
        });
        _this.render_durations();
        return false;
      });
      $(".durations .button.remove:not(:disabled)").click(function(e) {
        var code, durations;
        durations = _this.model.get("work_entry_durations");
        code = $(e.currentTarget).parents(".single-duration").find(".kind_code_select").val();
        durations = _.filter(durations, function(d) {
          return d.kind_code !== code;
        });
        _this.model.set("work_entry_durations", durations, {
          silent: true
        });
        _this.render_durations();
        return false;
      });
      return $(".durations .kind_code_select").change(function(e) {
        var durations, index;
        durations = _this.model.get("work_entry_durations");
        index = parseInt($(e.currentTarget).attr("data-index"), 10);
        durations[index].kind_code = $(e.currentTarget).val();
        _this.model.set("work_entry_durations", durations, {
          silent: true
        });
        _this.render_durations();
        return false;
      });
    };

    EntryEditView.prototype.handle_quick_pick_option = function(e) {
      var chart, chart_id,
        _this = this;
      chart_id = $(e.currentTarget).attr("data-id");
      chart = new WorkChart({
        id: chart_id
      });
      chart.bind("change", function() {
        return _this.rebuild_charts_array_for(chart);
      });
      return chart.fetch();
    };

    EntryEditView.prototype.rebuild_charts_array_for = function(chart) {
      var _rebuild_array,
        _this = this;
      _rebuild_array = function(chart) {
        var new_collection;
        if (chart.get("parent_id") === 1) {
          _this.render_charts();
          return;
        }
        new_collection = new WorkChartsCollection();
        _this.charts.unshift(new_collection);
        new_collection.on("reset", function() {
          var c, parent;
          c = new_collection.get(chart.get("id"));
          if (c) {
            c.set("selected", true);
          }
          parent = new WorkChart({
            id: chart.get("parent_id")
          });
          parent.bind("change", function() {
            return _rebuild_array(parent);
          });
          return parent.fetch();
        });
        return new_collection.fetch({
          data: $.param({
            parent_id: chart.get("parent_id"),
            include_inactive: true
          })
        });
      };
      this.charts = [];
      return _rebuild_array(chart);
    };

    EntryEditView.prototype.render_charts = function() {
      var data, last_selected,
        _this = this;
      last_selected = _.last(_.filter(this.charts, function(arr) {
        return arr.length > 0;
      })).find(function(chart) {
        return chart.get("selected") === true;
      });
      if (last_selected) {
        this.selected_chart.set("id", last_selected.get("id"), {
          silent: true
        });
        this.selected_chart.fetch();
      }
      data = {
        charts: this.charts.map(function(charts) {
          if (_this.show_inactive) {
            return charts.toJSON();
          } else {
            return _.map(charts.where({
              status: "active"
            }), function(c) {
              return c.toJSON();
            });
          }
        }),
        entry: this.model.toJSON()
      };
      $(".chart-selects", this.el).html(this.selects_template(data));
      return $(".chart-selects select").change(function(e) {
        var chart, level, num, val;
        val = parseInt($(e.currentTarget).val(), 10);
        level = parseInt($(e.currentTarget).attr("data-level"), 10);
        num = level + 1;
        _this.charts = _this.charts.slice(0, level + 1 || 9e9);
        chart = _this.charts[level].get(val);
        _this.charts[level].each(function(c) {
          return c.set("selected", false);
        });
        chart.set("selected", true);
        _this.charts[num] = new WorkChartsCollection();
        _this.charts[num].on("reset", _this.render_charts);
        return _this.charts[num].fetch({
          data: $.param({
            parent_id: val
          })
        });
      });
    };

    EntryEditView.prototype.set_search = function() {
      var _this = this;
      return $(".charts-search").autocomplete({
        source: "/work_charts/search" + (this.show_inactive ? '_all' : ''),
        minLength: 2,
        select: function(e, ul) {
          _this.selected_chart.set("id", ul.item.id, {
            silent: true
          });
          _this.selected_chart.fetch();
          return $(window).oneTime(10, function() {
            return $(".charts-search").val("");
          });
        }
      });
    };

    EntryEditView.prototype.render = function() {
      var _this = this;
      $(this.el).html(this.template(this.model.toJSON()));
      $("textarea", this.el).autoGrow();
      $(".calendar", this.el).datepicker({
        dateFormat: "DD, yy-mm-dd"
      });
      $(".calendar", this.el).datepicker("setDate", moment.utc(this.model.get('date_performed')).format("dddd, YYYY-MM-DD"));
      window.app.modal.show({
        content: this.el,
        closed: function() {
          return _this.back();
        }
      });
      ko.applyBindings(this.view, $("#modal")[0]);
      false;
      $(".charts-search").autocomplete({
        source: "/work_charts/search",
        minLength: 2,
        select: function(e, ul) {
          _this.selected_chart.set("id", ul.item.id, {
            silent: true
          });
          _this.selected_chart.fetch();
          return $(window).oneTime(10, function() {
            return $(".charts-search").val("");
          });
        }
      });
      this.charts[0].fetch({
        data: $.param({
          parent_id: 2
        })
      });
      $(".dropdown", this.el).click(function(e) {
        $("html").click(function() {
          return $(".no-hover", _this.el).removeClass("shown");
        });
        $(".no-hover", _this.el).toggleClass("shown");
        return e.stopPropagation();
      });
      $(".toggle_charts_filter").click(function(e) {
        var src;
        _this.show_inactive = !_this.show_inactive;
        _this.render_charts();
        _this.set_search();
        src = _this.show_inactive ? '/show-inactive.png' : '/hide-inactive.png';
        $('#chart_toggle').attr('src', src);
        return false;
      });
      this.frequents.fetch();
      this.recents.fetch();
      $("input.charts-search", this.el).focus(function(e) {
        return $(".search-results", _this.el).show();
      });
      $("input.charts-search", this.el).blur(function() {
        return $(".search-results", _this.el).hide();
      });
      $("input.charts-search", this.el).keyup(function(e) {
        $("input.charts-search", _this.el).stopTime("search");
        return $("input.charts-search", _this.el).oneTime(500, "search", function() {
          return _this.searches.fetch({
            data: $.param({
              phrase: $("input.charts-search", _this.el).val()
            })
          });
        });
      });
      this.render_durations();
      this.selected_chart.set("id", this.model.get("work_chart_id"), {
        silent: true
      });
      this.selected_chart.fetch();
      $("a.alert", this.el).click(function(e) {
        _this.back();
        return false;
      });
      $("button[type=submit]", this.el).click(function(e) {
        _this.persist();
        return e.preventDefault();
      });
      return this;
    };

    return EntryEditView;

  })(Backbone.View);
  
}});

window.require.define({"views/entries/new": function(exports, require, module) {
  var DurationKindsCollection, EntryNewView, WorkChart, WorkChartsCollection,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkChart = require("models/work_chart");

  WorkChartsCollection = require("collections/work_charts");

  DurationKindsCollection = require("collections/duration_kinds");

  module.exports = EntryNewView = (function(_super) {

    __extends(EntryNewView, _super);

    function EntryNewView() {
      this.render = __bind(this.render, this);

      this.set_search = __bind(this.set_search, this);

      this.render_charts = __bind(this.render_charts, this);

      this.rebuild_charts_array_for = __bind(this.rebuild_charts_array_for, this);

      this.handle_quick_pick_option = __bind(this.handle_quick_pick_option, this);

      this.render_durations = __bind(this.render_durations, this);

      this.render_recents = __bind(this.render_recents, this);

      this.render_frequents = __bind(this.render_frequents, this);

      this.render_searches = __bind(this.render_searches, this);

      this.set_duration_minutes = __bind(this.set_duration_minutes, this);

      this.set_duration_hour = __bind(this.set_duration_hour, this);

      this.initialize = __bind(this.initialize, this);

      this.back = __bind(this.back, this);

      this.persist = __bind(this.persist, this);
      return EntryNewView.__super__.constructor.apply(this, arguments);
    }

    EntryNewView.prototype.template = require("../templates/entries/form");

    EntryNewView.prototype.selects_template = require("../templates/entries/selects");

    EntryNewView.prototype.durations_template = require("../templates/entries/durations");

    EntryNewView.prototype.persist = function() {
      var data, date, durations, fees, s_fee,
        _this = this;
      this.model.set("work_chart_id", this.selected_chart.get("id"), {
        silent: true
      });
      this.model.set("date_performed", $("#work_entry_date_performed").val(), {
        silent: true
      });
      this.model.set("description", $("#work_entry_description").val(), {
        silent: true
      });
      durations = $(".single-duration").map(function(i, s) {
        return {
          kind_code: $(".kind_code_select", s).val(),
          duration_hours: $(".hour-select", s).val(),
          duration_minutes: $(".minutes-select", s).val()
        };
      });
      this.model.set("work_entry_durations", durations.toArray(), {
        silent: true
      });
      s_fee = $("#work_entry_work_entry_fees_attributes_0_fee").val();
      if (_.isNaN(parseFloat(s_fee, 10))) {
        s_fee = "0";
      }
      fees = [
        {
          fee: parseFloat(s_fee, 10)
        }
      ];
      this.model.set("work_entry_fees", fees, {
        silent: true
      });
      date = moment.utc(this.model.get("date_performed"));
      data = this.model.toJSON();
      data.work_entry_durations_attributes = data.work_entry_durations;
      delete data.work_entry_durations;
      data.work_entry_fees_attributes = data.work_entry_fees;
      delete data.work_entry_fees;
      $.ajax({
        url: "/work_entries",
        type: "POST",
        data: {
          work_entry: data
        },
        success: function(data) {
          if (data.status === 'OK') {
            humane.log("Entry saved");
            return _this.back();
          } else {
            return humane.log(data.errors);
          }
        },
        error: function(xhr, status, err) {
          return humane.log(err);
        }
      });
      return false;
    };

    EntryNewView.prototype.back = function() {
      Backbone.history.navigate(Backbone.history.fragment.replace("/new", ""), true);
      return $("#modal").trigger('reveal:close');
    };

    EntryNewView.prototype.initialize = function() {
      var _this = this;
      this.charts = [];
      this.charts[0] = new WorkChartsCollection();
      this.charts[0].on("reset", this.render_charts);
      this.show_inactive = false;
      this.frequents = new WorkChartsCollection();
      this.frequents.url = "/work_charts/frequent.json";
      this.frequents.on("reset", this.render_frequents);
      this.recents = new WorkChartsCollection();
      this.recents.url = "/work_charts/recent.json";
      this.recents.on("reset", this.render_recents);
      this.searches = new WorkChartsCollection();
      this.duration_kinds = new DurationKindsCollection();
      this.duration_kinds.on("reset", function() {
        var durations, hours, hours_to_add, kinds, minutes, minutes_to_add, new_hours, new_minutes, to_wipe, _ref;
        _this.render_durations();
        durations = _this.model.get("work_entry_durations");
        kinds = _this.duration_kinds.pluck("code");
        if (_this.duration_kinds.size() < durations.length) {
          to_wipe = _.filter(durations, function(d) {
            return !_.contains(kinds, d.kind_code);
          });
          durations = _.difference(durations, to_wipe);
          _ref = durations[0].duration.split(";"), hours = _ref[0], minutes = _ref[1];
          hours_to_add = _.map(to_wipe, function(d) {
            return parseInt(d.duration.split(":")[0]);
          });
          minutes_to_add = _.map(to_wipe, function(d) {
            return parseInt(d.duration.split(":")[1]);
          });
          new_hours = (parseInt(hours)) + _.reduce(hours_to_add, (function(s, i) {
            return s + i;
          }), 0);
          new_minutes = (parseInt(minutes)) + _.reduce(minutes_to_add, (function(s, i) {
            return s + i;
          }), 0);
          durations[0].duration = "" + new_hours + ":" + new_minutes + ":00";
          durations[0].kind_code = _.first(_this.duration_kinds.models).get('code');
          _this.model.set("work_entry_durations", durations, {
            silent: true
          });
          return _this.render_durations();
        }
      });
      this.selected_chart = new WorkChart();
      return this.selected_chart.on("change", function() {
        _this.rebuild_charts_array_for(_this.selected_chart);
        _this.duration_kinds.url = "/work_charts/" + (_this.selected_chart.get('id')) + "/duration_kinds.json";
        return _this.duration_kinds.fetch();
      });
    };

    EntryNewView.prototype.set_duration_hour = function(index, hour) {
      var d, durations, minute, _hour, _ref;
      durations = this.model.get("work_entry_durations");
      d = durations[index].duration;
      if (d) {
        _ref = d.split(":"), _hour = _ref[0], minute = _ref[1];
        durations[index].duration = "" + hour + ":" + minute + ":00";
        return this.model.set("work_entry_durations", durations, {
          silent: true
        });
      }
    };

    EntryNewView.prototype.set_duration_minutes = function(index, minute) {
      var d, durations, hour, _minute, _ref;
      durations = this.model.get("work_entry_durations");
      d = durations[index].duration;
      if (d) {
        _ref = d.split(":"), hour = _ref[0], _minute = _ref[1];
        durations[index].duration = "" + hour + ":" + minute + ":00";
        return this.model.set("work_entry_durations", durations, {
          silent: true
        });
      }
    };

    EntryNewView.prototype.render_searches = function() {
      var lis;
      lis = this.searches.map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(1, 11).join(' / ')) + "</li>";
      });
      $(".search-results ul").html(lis.join("\n"));
      return $(".search-results ul li").click(this.handle_quick_pick_option);
    };

    EntryNewView.prototype.render_frequents = function() {
      var clients, clis, olis, others;
      clients = this.frequents.filter(function(chart) {
        return chart.get('labels').length > 2 && chart.get('labels')[0] === "Clients";
      });
      others = this.frequents.filter(function(chart) {
        return chart.get('labels').length < 2 || chart.get('labels')[0] !== "Clients";
      });
      clis = _.sortBy(clients, function(c) {
        return c.get("labels")[1];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(1, 11).join(' / ')) + "</li>";
      });
      olis = _.sortBy(others, function(c) {
        return c.get("labels")[0];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(0, 11).join(' / ')) + "</li>";
      });
      $(".frequent ul.clients").html(clis.join("\n"));
      $(".frequent ul.other").html(olis.join("\n"));
      return $(".frequent ul li").click(this.handle_quick_pick_option);
    };

    EntryNewView.prototype.render_recents = function() {
      var clients, clis, olis, others;
      clients = this.recents.filter(function(chart) {
        return chart.get('labels').length > 2 && chart.get('labels')[0] === "Clients";
      });
      others = this.recents.filter(function(chart) {
        return chart.get('labels').length < 2 || chart.get('labels')[0] !== "Clients";
      });
      clis = _.sortBy(clients, function(c) {
        return c.get("labels")[1];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(1, 11).join(' / ')) + "</li>";
      });
      olis = _.sortBy(others, function(c) {
        return c.get("labels")[0];
      }).map(function(chart) {
        return "<li data-id='" + (chart.get('id')) + "'>" + (chart.get('labels').slice(0, 11).join(' / ')) + "</li>";
      });
      $(".recent ul.clients").html(clis.join("\n"));
      $(".recent ul.other").html(olis.join("\n"));
      return $(".recent ul li").click(this.handle_quick_pick_option);
    };

    EntryNewView.prototype.render_durations = function() {
      var data,
        _this = this;
      data = {
        work_entry: this.model.toJSON(),
        duration_kinds: this.duration_kinds.toJSON()
      };
      $(".durations").html(this.durations_template(data));
      $(".durations .hour-button").click(function(e) {
        var btn, div, hour, index;
        btn = $(e.currentTarget);
        div = $(e.currentTarget).parents(".single-duration");
        hour = btn.attr("data-hour");
        $(" .hour-button", div).removeClass("selected");
        btn.addClass("selected");
        $(" .hour-select option", div).attr("selected", "");
        $(" .hour-select option[value=" + hour + "]", div).attr("selected", "selected");
        index = parseInt($(e.currentTarget).attr("data-index"));
        _this.set_duration_hour(index, hour);
        return false;
      });
      $(" .hour-select").change(function(e) {
        var div, hour, index;
        hour = $(e.currentTarget).val();
        div = $(e.currentTarget).parents(".single-duration");
        $(" .hour-button", div).removeClass("selected");
        $(" .hour-button[data-hour=" + hour + "]", div).addClass("selected");
        index = parseInt($(e.currentTarget).attr("data-index"));
        _this.set_duration_hour(index, hour);
        return false;
      });
      $(" .minutes-select").change(function(e) {
        var div, index, minutes;
        minutes = $(e.currentTarget).val();
        div = $(e.currentTarget).parents(".single-duration");
        $(" .minute-button", div).removeClass("selected");
        $(" .minute-button[data-minute=" + minutes + "]", div).addClass("selected");
        index = parseInt($(e.currentTarget).attr("data-index"));
        return _this.set_duration_minutes(index, minutes);
      });
      $(" .minute-button").click(function(e) {
        var btn, div, index, minutes;
        btn = $(e.currentTarget);
        div = $(e.currentTarget).parents(".single-duration");
        minutes = btn.attr("data-minute");
        $(" .minute-button", div).removeClass("selected");
        btn.addClass("selected");
        $(" .minutes-select option", div).attr("selected", "");
        $(" .minutes-select option[value=" + minutes + "]", div).attr("selected", "selected");
        index = parseInt($(e.currentTarget).attr("data-index"));
        _this.set_duration_minutes(index, minutes);
        return false;
      });
      $(" .button.add:not(.disabled)").click(function() {
        var durations, last_duration, new_duration;
        durations = _this.model.get("work_entry_durations");
        last_duration = _.last(durations);
        new_duration = last_duration.constructor();
        new_duration.duration = "00:00:00";
        new_duration.modified_by = last_duration.modified_by;
        new_duration.kind_code = _.first(_this.duration_kinds.filter(function(k) {
          return !_.include(_.pluck(durations, "kind_code"), k.get("code"));
        })).get("code");
        durations.push(new_duration);
        _this.model.set("work_entry_durations", durations, {
          silent: true
        });
        _this.render_durations();
        return false;
      });
      $(".durations .button.remove:not(:disabled)").click(function(e) {
        var code, durations;
        durations = _this.model.get("work_entry_durations");
        code = $(e.currentTarget).parents(".single-duration").find(".kind_code_select").val();
        durations = _.filter(durations, function(d) {
          return d.kind_code !== code;
        });
        _this.model.set("work_entry_durations", durations, {
          silent: true
        });
        _this.render_durations();
        return false;
      });
      return $(".durations .kind_code_select").change(function(e) {
        var durations, index;
        durations = _this.model.get("work_entry_durations");
        index = parseInt($(e.currentTarget).attr("data-index"));
        durations[index].kind_code = $(e.currentTarget).val();
        _this.model.set("work_entry_durations", durations, {
          silent: true
        });
        _this.render_durations();
        return false;
      });
    };

    EntryNewView.prototype.handle_quick_pick_option = function(e) {
      var chart, chart_id,
        _this = this;
      chart_id = $(e.currentTarget).attr("data-id");
      chart = new WorkChart({
        id: chart_id
      });
      chart.bind("change", function() {
        return _this.rebuild_charts_array_for(chart);
      });
      return chart.fetch();
    };

    EntryNewView.prototype.rebuild_charts_array_for = function(chart) {
      var _rebuild_array,
        _this = this;
      _rebuild_array = function(chart) {
        var new_collection;
        if (chart.get("parent_id") === 1) {
          _this.render_charts();
          return;
        }
        new_collection = new WorkChartsCollection();
        _this.charts.unshift(new_collection);
        new_collection.on("reset", function() {
          var c, parent;
          c = new_collection.get(chart.get("id"));
          if (c) {
            c.set("selected", true);
          }
          parent = new WorkChart({
            id: chart.get("parent_id")
          });
          parent.bind("change", function() {
            return _rebuild_array(parent);
          });
          return parent.fetch();
        });
        return new_collection.fetch({
          data: $.param({
            parent_id: chart.get("parent_id"),
            include_inactive: true
          })
        });
      };
      this.charts = [];
      return _rebuild_array(chart);
    };

    EntryNewView.prototype.render_charts = function() {
      var data, last_selected,
        _this = this;
      last_selected = _.last(_.filter(this.charts, function(arr) {
        return arr.length > 0;
      })).find(function(chart) {
        return chart.get("selected") === true;
      });
      if (last_selected) {
        this.selected_chart.set("id", last_selected.get("id"), {
          silent: true
        });
        this.selected_chart.fetch();
      }
      data = {
        charts: this.charts.map(function(charts) {
          if (_this.show_inactive) {
            return charts.toJSON();
          } else {
            return _.map(charts.where({
              status: "active"
            }), function(c) {
              return c.toJSON();
            });
          }
        }),
        entry: this.model.toJSON()
      };
      $(".chart-selects", this.el).html(this.selects_template(data));
      return $(".chart-selects select").change(function(e) {
        var chart, level, num, val;
        val = parseInt($(e.currentTarget).val());
        level = parseInt($(e.currentTarget).attr("data-level"));
        num = level + 1;
        _this.charts = _this.charts.slice(0, level + 1 || 9e9);
        chart = _this.charts[level].get(val);
        _this.charts[level].each(function(c) {
          return c.set("selected", false);
        });
        chart.set("selected", true);
        _this.charts[num] = new WorkChartsCollection();
        _this.charts[num].on("reset", _this.render_charts);
        return _this.charts[num].fetch({
          data: $.param({
            parent_id: val,
            include_inactive: true
          })
        });
      });
    };

    EntryNewView.prototype.set_search = function() {
      var _this = this;
      return $(".charts-search").autocomplete({
        source: "/work_charts/search" + (this.show_inactive ? '_all' : ''),
        minLength: 2,
        select: function(e, ul) {
          _this.selected_chart.set("id", ul.item.id, {
            silent: true
          });
          _this.selected_chart.fetch();
          return $(window).oneTime(10, function() {
            return $(".charts-search").val("");
          });
        }
      });
    };

    EntryNewView.prototype.render = function() {
      var _this = this;
      $(this.el).html(this.template(this.model.toJSON()));
      window.app.modal.show({
        content: this.el,
        closed: function() {
          return _this.back();
        }
      });
      $("textarea", this.el).autoGrow();
      $(".calendar", this.el).datepicker({
        dateFormat: "DD, yy-mm-dd"
      });
      $(".calendar", this.el).datepicker("setDate", moment.utc(this.model.get('date_performed')).format("dddd, YYYY-MM-DD"));
      $(".charts-search").autocomplete({
        source: "/work_charts/search",
        minLength: 2,
        select: function(e, ul) {
          _this.selected_chart.set("id", ul.item.id, {
            silent: true
          });
          _this.selected_chart.fetch();
          return $(window).oneTime(10, function() {
            return $(".charts-search").val("");
          });
        }
      });
      this.charts[0].fetch({
        data: $.param({
          parent_id: 2,
          include_inactive: true
        })
      });
      $(".dropdown", this.el).click(function(e) {
        $("html").click(function() {
          return $(".no-hover", _this.el).removeClass("shown");
        });
        $(".no-hover", _this.el).toggleClass("shown");
        return e.stopPropagation();
      });
      this.frequents.fetch();
      this.recents.fetch();
      $(".toggle_charts_filter").click(function(e) {
        var src;
        _this.show_inactive = !_this.show_inactive;
        _this.render_charts();
        _this.set_search();
        src = _this.show_inactive ? '/show-inactive.png' : '/hide-inactive.png';
        $('#chart_toggle').attr('src', src);
        return false;
      });
      $("input.charts-search", this.el).focus(function(e) {
        return $(".search-results", _this.el).show();
      });
      $("input.charts-search", this.el).blur(function() {
        return $(".search-results", _this.el).hide();
      });
      $("input.charts-search", this.el).keyup(function(e) {
        $("input.charts-search", _this.el).stopTime("search");
        return $("input.charts-search", _this.el).oneTime(500, "search", function() {
          return _this.searches.fetch({
            data: $.param({
              phrase: $("input.charts-search", _this.el).val()
            })
          });
        });
      });
      this.render_durations();
      this.selected_chart.set("id", this.model.get("work_chart_id"), {
        silent: true
      });
      $("a.alert", this.el).click(function(e) {
        _this.back();
        return false;
      });
      $("button[type=submit]", this.el).click(function(e) {
        _this.persist();
        return e.preventDefault();
      });
      return this;
    };

    return EntryNewView;

  })(Backbone.View);
  
}});

window.require.define({"views/hello_view": function(exports, require, module) {
  var HelloView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = HelloView = (function(_super) {

    __extends(HelloView, _super);

    function HelloView() {
      return HelloView.__super__.constructor.apply(this, arguments);
    }

    HelloView.prototype.className = 'hello';

    HelloView.prototype.template = require('./templates/hello');

    HelloView.prototype.render = function() {
      this.$el.html(this.template);
      return this;
    };

    return HelloView;

  })(Backbone.View);
  
}});

window.require.define({"views/navigation/top_bar": function(exports, require, module) {
  var TopBarView, TopBarViewModel,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = TopBarView = (function(_super) {

    __extends(TopBarView, _super);

    function TopBarView() {
      return TopBarView.__super__.constructor.apply(this, arguments);
    }

    TopBarView.prototype.template = require("../templates/navigation/top_bar");

    TopBarView.prototype.initialize = function() {
      var _this = this;
      this.current_role = this.options.role;
      this.current_role.on("change", function() {
        _this.render();
        return ko.applyBindings(_this.view, $(".top-bar")[0]);
      });
      return this.view = new TopBarViewModel(this.current_role);
    };

    TopBarView.prototype.render = function() {
      if ($(".top-bar").html() === "") {
        $(".top-bar").html(this.template());
        $("#today").click(function() {
          var now;
          now = moment(new Date());
          Backbone.history.navigate("/#entries/" + (now.year()) + "/" + (now.month() + 1) + "/" + (now.date()), true);
          return false;
        });
        $("#this_month").click(function() {
          var now;
          now = moment(new Date());
          Backbone.history.navigate("/#calendar/" + (now.year()) + "/" + (now.month() + 1), true);
          return false;
        });
        $("#new_entry").click(function() {
          var now;
          now = moment(new Date());
          Backbone.history.navigate("/#entries/" + (now.year()) + "/" + (now.month() + 1) + "/" + (now.date()) + "/new", true);
          return false;
        });
        return $("#logout").click(function() {
          var _this = this;
          $.ajax({
            url: "/users/sign_out",
            type: "DELETE",
            success: function() {
              humane.log("Goodbye");
              $("#logout").hide();
              window.router.current_role.clear();
              return Backbone.history.navigate("/#", true);
            },
            error: function() {
              humane.log("Goodbye");
              window.app.current_role.clear();
              $("#logout").hide();
              return Backbone.history.navigate("/#", true);
            }
          });
          return false;
        });
      }
    };

    return TopBarView;

  })(Backbone.View);

  TopBarViewModel = (function() {

    function TopBarViewModel(role) {
      this.current_role = ko.observable(role);
      this.assume_other = function() {
        window.app.router.trigger("admin:assume-other");
        return false;
      };
      this.redirect_to_admin = function() {
        window.open("/admin", "_blank");
        return false;
      };
      this.reset_role = function() {
        var _this = this;
        return window.app.current_role.assume_async({
          success: function(data) {
            Backbone.history.fragment = null;
            Backbone.history.navigate(document.location.hash, true);
            return window.router.current_role.fetch();
          },
          error: function(data) {
            return console.info("implement me");
          }
        });
      };
      this.redirect_to_reports = function() {
        Backbone.history.navigate("/#reports", true);
        return false;
      };
    }

    return TopBarViewModel;

  })();
  
}});

window.require.define({"views/reports": function(exports, require, module) {
  var ReportsView, ReportsViewModel, WorkChartsCollection,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WorkChartsCollection = require("collections/work_charts");

  module.exports = ReportsView = (function(_super) {

    __extends(ReportsView, _super);

    function ReportsView() {
      this.initialize = __bind(this.initialize, this);
      return ReportsView.__super__.constructor.apply(this, arguments);
    }

    ReportsView.prototype.template = require("./templates/reports/show");

    ReportsView.prototype.controls_template = require("./templates/reports/controls");

    ReportsView.prototype.initialize = function() {
      return this.view = new ReportsViewModel(this.options.roles);
    };

    ReportsView.prototype.render = function() {
      $(this.el).html(this.template());
      $("#main").html(this.el);
      $("header").html(this.controls_template());
      $('.daterange').daterangepicker({
        ranges: {
          "Today": ["today", "today"],
          "Yesterday": ["yesterday", "yesterday"],
          "Last 7 Days": [
            Date.today().add({
              days: -6
            }), 'today'
          ],
          'Last 30 Days': [
            Date.today().add({
              days: -29
            }), 'today'
          ],
          'This Month': [Date.today().moveToFirstDayOfMonth(), Date.today().moveToLastDayOfMonth()],
          'Last Month': [
            Date.today().moveToFirstDayOfMonth().add({
              months: -1
            }), Date.today().moveToFirstDayOfMonth().add({
              days: -1
            })
          ]
        }
      });
      ko.applyBindings(this.view, $("header")[0]);
      return ko.applyBindings(this.view, $("#main")[0]);
    };

    return ReportsView;

  })(Backbone.View);

  ReportsViewModel = (function() {

    function ReportsViewModel(roles) {
      var first_level,
        _this = this;
      this.report_types = ko.observableArray([
        {
          value: "break",
          label: "Break",
          active: true
        }
      ]);
      this.select_type = function(item) {
        var types;
        types = _.map(_this.report_types(), function(i) {
          i.active = i.value === item.value;
          return i;
        });
        _this.report_types([]);
        return _this.report_types(types);
      };
      this.selected_type = ko.computed(function() {
        if (_this.report_types().length === 0) {
          return "break";
        } else {
          return _.find(_this.report_types(), function(t) {
            return t.active;
          });
        }
      });
      this.chart_levels = ko.observableArray([]);
      first_level = new WorkChartsCollection;
      first_level.on("reset", function() {
        return _this.chart_levels.push(first_level.models);
      });
      first_level.url = "/work_charts.json?parent_id=2";
      first_level.fetch();
      this.display_full = ko.observable(false);
      this.printable = ko.observable(false);
      this.open_in_new = ko.observable(false);
      this.roles = ko.observableArray([]);
      roles.on("reset", function() {
        _this.roles(roles.models);
        return $(window).oneTime(50, function() {
          return $(".roles select").chosen();
        });
      });
      this.date_range_string = ko.observable("");
      this.generate_report = function() {
        return $.ajax({
          url: "/reports/" + (_this.selected_type().value) + ".json",
          data: {
            start: _this.date_start().toDate(),
            end: _this.date_end().toDate(),
            roles: _this.selected_roles()
          },
          success: function(items) {
            return _this.report_items(items);
          }
        });
      };
      this.selected_roles = ko.observableArray([]);
      this.date_range = ko.computed(function() {
        return _this.date_range_string().split(" - ");
      });
      this.date_start = ko.computed(function() {
        if (_this.date_range().length === 2) {
          return moment(_this.date_range()[0]);
        } else {
          return null;
        }
      });
      this.date_end = ko.computed(function() {
        if (_this.date_range().length === 2) {
          return moment(_this.date_range()[1]);
        } else {
          return null;
        }
      });
      this.report_items = ko.observable();
      this.ready_to_generate = ko.computed(function() {
        return _this.date_range_string().trim() !== "" && _this.selected_roles().length > 0;
      });
      this.generate_status_class = ko.computed(function() {
        if (_this.ready_to_generate()) {
          return "button";
        } else {
          return "button disabled";
        }
      });
    }

    return ReportsViewModel;

  })();
  
}});

window.require.define({"views/templates/admin/switch_role": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('\n<h4>Assume role of other user</h4>\n<ul class="assume-users-list " data-bind="template: {foreach: roles, name: \'role-template\'}">\n</ul>\n<a class="close-reveal-modal">&#215;</a>\n\n<script type="text/html" id="role-template">\n  <li data-bind="text: user_name(), click: $root.assume_role"></li>\n</script>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/auth/login": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<form accept-charset="UTF-8" class="new_user" id="new_user" method="post">\n    <div><label for="user_email">Email</label><br>\n    <input id="user_email" name="user[email]" size="30" type="email" value=""></div>\n\n    <div><label for="user_password">Password</label><br>\n    <input id="user_password" name="user[password]" size="30" type="password"></div>\n\n    <div><a href="#" class="button login">Sign in</a></div>\n</form>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/calendar/index": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<ul id="calendar" data-bind="template: {foreach: days(), name: \'day-template\'}">\n</ul>\n\n<ul id="calendar-week-totals" data-bind="template: {foreach: week_totals(), name: \'week-total-template\'}">\n</ul>\n\n<table cellpadding="0" cellspacing="0" id="calendar-month-totals">\n  <thead>\n    <tr>\n      <th></th>\n      <th>Available</th>\n      <th>Billable </th>\n      <th>Nonbillable </th>\n      <th>Total</th>\n    </tr>\n  </thead>\n  <tbody data-bind="template: {foreach: work_months(), name: \'month-template\'}"></tbody>\n</table>\n\n<script type="text/html" id="day-template">\n  <li data-bind="attr: {class: date_class($root.year(), $root.month()), \'data-href\': href()}, click: $root.goto">\n    <div data-bind="text: day()"></div>\n    <div class="day-totals" data-bind="visible: !(in_future() && get(\'time\') == \'00:00:00\' ) ">\n      <div data-bind="text: time_string()" class="total-all"></div>\n      <div data-bind="text: billable_time_string()" class="sub"></div>\n      <div data-bind="text: nonbillable_time_string()" class="sub nonbillable"></div></div>\n  </li>\n</script>\n\n<script id="week-total-template" type="text/html">\n  <li data-bind="attr: {class: total_class()}">\n    <div class="day-totals">\n      <div data-bind="text: total" class="total-all"></div>\n      <div data-bind="text: billable_total" class="sub"></div>\n      <div data-bind="text: nonbillable_total" class="sub nonbillable"></div>\n    </div>\n  </li>\n</script>\n\n<script type="text/html" id="month-template">\n  <tr >\n    <td><a data-bind="text: month_year_string(), click: $root.redirect_to_month" href="#"></a></td>\n    <td data-bind="text: available_string()"></td>\n    <td data-bind="text: billable_string()"></td>\n    <td data-bind="text: nonbillable_string()"></td>\n    <td data-bind="text: total_string(), attr: {class: month_class()}"></td>\n  </tr>\n</script>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/calendar/top": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div id="calendar-controls">\n  <a href="#" class="left" data-bind="click: backMonth">&lt;</a>\n  <select id="years" data-bind="template: {name: \'year-option\', foreach: years()}, value: year"></select>\n  <select id="months" data-bind="template: {name: \'month-option\', foreach: months()}, value: month"></select>\n  <a href="#" class="right" data-bind="click: nextMonth">&gt;</a>\n</div>\n\n<script type="text/html" id="year-option">\n  <option data-bind="text: $data, value: $data"></option>\n</script>\n\n<script type="text/html" id="month-option">\n  <option data-bind="text: $data.name, value: $data.value"></option>\n</script>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/entries/durations": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var duration, hours, i, j, kind, kinds, minutes, thisEl, _i, _j, _k, _l, _len, _len1, _m, _n, _ref,
          _this = this;
      
        __out.push('       <div class="actions">\n         <a href="#" class="button add \n');
      
        if (this.duration_kinds.length <= this.work_entry.work_entry_durations.length) {
          __out.push(' \n  disabled  \n');
        }
      
        __out.push(' ">+</a>\n       </div>\n       ');
      
        i = 0;
      
        __out.push('\n       ');
      
        _ref = this.work_entry.work_entry_durations;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          duration = _ref[_i];
          __out.push('\n       <div class="single-duration">\n         <a href="#" class="button alert remove ');
          __out.push(__sanitize(i === 0 ? "disabled" : ""));
          __out.push(' ">-</a>\n       ');
          hours = duration.duration ? parseInt(duration.duration.split(":")[0], 10) : 0;
          __out.push('\n       ');
          minutes = duration.duration ? parseInt(duration.duration.split(":")[1], 10) : 0;
          __out.push('\n       <div class="input interval optional">\n           <label class="interval optional control-label" \n                  for="work_entry_work_entry_durations_attributes_0_duration">Duration</label>      \n         <div class="row collapse complex-input single-select">\n           <div class="five mobile-three columns">\n             <select data-index="');
          __out.push(__sanitize(i));
          __out.push('" class="hour-select" name="durations[0][hours]">\n               ');
          for (j = _j = 1; _j <= 25; j = ++_j) {
            __out.push('\n                 <option ');
            if (j === hours) {
              __out.push(' ');
              __out.push(__sanitize("selected='selected'"));
              __out.push(' ');
            }
            __out.push(' value="');
            __out.push(__sanitize(j));
            __out.push('">');
            __out.push(__sanitize(j));
            __out.push('</option>\n               ');
          }
          __out.push('\n             </select>\n           </div>\n           <div class="one mobile-one columns">\n             <span class="postfix">h</span>\n           </div>\n           <div class="five mobile-three columns single-select">\n             <select data-index="');
          __out.push(__sanitize(i));
          __out.push('" class="minutes-select" name="durations[0][minutes]">\n               ');
          for (j = _k = 1; _k <= 4; j = ++_k) {
            __out.push('\n                 <option \n                   ');
            if (15 * j === minutes) {
              __out.push(' \n                     ');
              __out.push(__sanitize("selected='selected'"));
              __out.push(' \n                   ');
            }
            __out.push(' \n                  value="');
            __out.push(__sanitize(j * 15));
            __out.push('">');
            __out.push(__sanitize((j * 15).toString().pad(2)));
            __out.push('</option>\n               ');
          }
          __out.push('\n             </select>\n           </div>\n           <div class="one mobile-one columns">\n             <span class="postfix">m</span>\n           </div>\n         </div>\n         <div class="row collapse hours-minutes">\n           ');
          for (j = _l = 1; _l <= 9; j = ++_l) {
            __out.push('\n             <a href="#" data-index="');
            __out.push(__sanitize(i));
            __out.push('" data-hour="');
            __out.push(__sanitize(j));
            __out.push('" \n                class="button hour-button ');
            if (j === hours) {
              __out.push(' ');
              __out.push(__sanitize("selected"));
              __out.push(' ');
            }
            __out.push('">\n                ');
            __out.push(__sanitize(j));
            __out.push('\n            </a>\n           ');
          }
          __out.push('\n           <span>&nbsp;</span>         \n           ');
          for (j = _m = 1; _m <= 4; j = ++_m) {
            __out.push('\n             <a href="#" data-index="');
            __out.push(__sanitize(i));
            __out.push('" data-minute="');
            __out.push(__sanitize(j * 15));
            __out.push('" \n                class="button minute-button ');
            if (j * 15 === minutes) {
              __out.push(' ');
              __out.push(__sanitize("selected"));
              __out.push(' ');
            }
            __out.push('">\n                ');
            __out.push(__sanitize((j * 15).toString().pad(2)));
            __out.push('\n            </a>\n           ');
          }
          __out.push('\n         </div>\n       </div>\n       <div class="input select optional">\n         <select class="select optional kind_code_select" data-index="');
          __out.push(__sanitize(i));
          __out.push('" data-placeholder="Select kind" \n            id="work_entry_work_entry_durations_attributes_0_kind_code" \n            name="work_entry[work_entry_durations_attributes][0][kind_code]">\n            ');
          kinds = _.reject(this.duration_kinds, function(d) {
            return _.contains(_.pluck(_this.work_entry.work_entry_durations, 'kind_code'), d.code);
          });
          __out.push('\n            ');
          thisEl = _.find(this.duration_kinds, function(d) {
            return d.code === duration.kind_code;
          });
          __out.push('\n            ');
          if (thisEl) {
            kinds.push(thisEl);
          }
          __out.push('\n            ');
          for (_n = 0, _len1 = kinds.length; _n < _len1; _n++) {
            kind = kinds[_n];
            __out.push('\n              <option ');
            if (kind.code === duration.kind_code) {
              __out.push(' selected=\'selected\' ');
            }
            __out.push(' value="');
            __out.push(__sanitize(kind.code));
            __out.push('">');
            __out.push(__sanitize(kind.display_label));
            __out.push('</option>\n            ');
          }
          __out.push('\n         </select>\n       </div>\n       </div>\n');
          i += 1;
          __out.push('\n     ');
        }
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/entries/form": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<form accept-charset="UTF-8" action="" class="simple_form edit_work_entry" method="post">\n  <div class="input work_chart_selector optional">\n    <label class="work_chart_selector optional control-label" for="work_entry_work_chart_id">\n      Chart\n      (  )\n    </label>      \n    <div class="row collapse complex-input">\n      <div class="nine mobile-four columns" >\n         <input class="charts-search" type="text" placeholder="Type to search through work charts">\n      </div>\n      <div class="three mobile-three columns qp-block">\n        <div class="small button dropdown">\n          Quick pick\n          <div class="no-hover" style="top: 31px; ">\n            <div class="frequent">\n              <span>Frequent</span>\n              <h4>Clients:</h4>\n              <ul class="clients">\n              </ul>\n              <h4>Other:</h4>\n              <ul class="other"></ul>\n            </div>\n            <div class="recent">\n              <span>Recent</span>\n              <h4>Clients:</h4>\n              <ul class="clients">\n              </ul>\n              <h4>Other:</h4>\n              <ul class="other"></ul>\n            </div>\n          </div>\n        </div>\n      </div>\n    <div class="row collapse complex-input">\n\n      <div class="chart-selects nine mobile-three columns">\n         <input type="hidden" name="work_entry[work_chart_id]" value="');
      
        __out.push(__sanitize(this.work_chart_id));
      
        __out.push('" >\n         <select name="work_entry[work_chart_id]_" >\n         </select>\n      </div>\n\n      <div class="three columns">\n\t <a href="#" class="toggle_charts_filter" ><img id=\'chart_toggle\' src="/images/hide-inactive.png" /></a>\n\t  </div>\n\n    </div>\n    <div class="row collapse complex-input">\n     <div class="input string optional five columns">\n      <label class="string optional control-label" for="work_entry_date_performed">Date performed</label>\n      <input class="string optional calendar" id="work_entry_date_performed" \n             name="work_entry[date_performed]" size="50" type="text" \n             value="');
      
        __out.push(__sanitize(this.date_performed));
      
        __out.push('">\n     </div>\n     <div class="currency optional five columns">\n      <label class="currency optional control-label"\n             for="work_entry_work_entry_fees_attributes_0_fee">\n             Fee\n      </label>\n      <div class="row collapse complex-input fees-input">\n        <div class="two mobile-one columns">\n          <span class="prefix">$</span>\n        </div>\n        <div class="ten mobile-one columns">\n          <input class="currency optional" id="work_entry_work_entry_fees_attributes_0_fee"\n                 name="work_entry[work_entry_fees_attributes][0][fee]" size="30"\n                 type="text" value="');
      
        if (this.work_entry_fees.length > 0) {
          __out.push(__sanitize(this.work_entry_fees[0].fee));
        }
      
        __out.push('" >\n        </div>\n      </div>\n\n     </div>\n     <div class="two columns">\n        <div class="six columns">\n\t\t  <div class="small-buttons">\n\t\t\t<a href="/#');
      
        __out.push(__sanitize(Backbone.history.fragment.replace("/new", "")));
      
        __out.push('" class="button alert" ><img src="/delete-vivid.png" /></a>\n\t\t  </div>\n\t\t</div>\n        <div class="six columns">\n\t\t  <div class="small-buttons">\n\t\t\t<button class="button" type="submit"><img src="/images/tick-vivid.png" /></button>\n\t\t  </div>\n\t\t</div>\n     </div>\n\n    </div>\n\n\n\n\n    <div class="input">\n     <fieldset class="durations">\n     \n     </fieldset>\n\n     <div class="input text optional">\n       <label class="text optional control-label" for="work_entry_description">Description</label>\n       <textarea class="text optional" cols="40" id="work_entry_description" \n                 name="work_entry[description]" rows="3" >');
      
        __out.push(__sanitize(this.description));
      
        __out.push('</textarea>\n     </div>\n\n\n     <div class="panel input">\n       <div class="four columns">\n\t <a href="/#');
      
        __out.push(__sanitize(Backbone.history.fragment.replace("/new", "")));
      
        __out.push('" class="button alert" ><img src="/images/delete-vivid.png" />Cancel</a>\n       </div>\n       <div class="one columns">\n       </div>\n       <div class="seven columns">\n\t <button class="button" type="submit"><img src="/images/tick-vivid.png" />Save</button>\n       </div>\n       <div class="clearfix"></div>\n     </div>\n</div>\n\n</form>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/entries/selects": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var chart, i, j, _charts, _i, _j, _len, _len1, _ref;
      
        __out.push('<input type="hidden" name="work_entry[work_chart_id]" value="');
      
        __out.push(__sanitize(this.entry.work_chart_id));
      
        __out.push('" >\n\n');
      
        i = 0;
      
        __out.push('\n');
      
        _ref = this.charts;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          _charts = _ref[_i];
          __out.push('\n\n  ');
          if (_charts.length > 0) {
            __out.push('\n    <select data-level="');
            __out.push(__sanitize(i));
            __out.push('" name="work_entry[work_chart_id]_" >\n      <option></option>\n      ');
            j = 0;
            __out.push('\n      ');
            for (_j = 0, _len1 = _charts.length; _j < _len1; _j++) {
              chart = _charts[_j];
              __out.push('\n        <option ');
              if (chart.selected === true) {
                __out.push('selected=\'selected\'');
              }
              __out.push(' value="');
              __out.push(__sanitize(chart.id));
              __out.push('">');
              __out.push(__sanitize(chart.display_label));
              __out.push('</option>\n      ');
            }
            __out.push('\n    </select>\n    ');
            j += 1;
            __out.push('\n  ');
          }
          __out.push('\n  ');
          i += 1;
          __out.push('\n');
        }
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/hello": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push(__sanitize("Hello!!"));
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/navigation/top_bar": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<ul>\n  <li class="name">\n  <a href="/#" style="visibility: visible;"><b>End Point&nbsp;</b><span>App</span>\n  </a>\n  </li>\n  <li class="divider"></li>\n  <li>\n    <a href="#" id="this_month">\n      <img src="/images/calendar-white.png" />\n      Calendar\n    </a>\n  </li>\n  <li class="divider"></li>\n  <li>\n  <a href="#" id="today"><img src="/images/notes-white.png" />Today</a>\n  </li>\n  <li class="divider"></li>\n  <li>\n  <a href="#" id="new_entry"><img src="/images/compose-white.png" />New entry</a>\n  </li>\n  <li class="toggle-topbar"><a href="#"></a></li>\n</ul>\n<section>\n  <ul class="left"></ul>\n  <ul class="right">\n    <li class="divider" ></li>\n    <li class="has-dropdown"  >\n    <a href="#">Settings</a>\n      <ul class="dropdown">\n        <li><a data-bind="click: redirect_to_reports" href="#">Reports</a></li>\n        <li data-bind="if: current_role().get(\'can_switch_roles\')">\n        <a id="assume-other" data-bind="click: assume_other" href="#"><img src="/images/swap-white.png" />Switch role</a>\n        </li>\n        <li data-bind="if: current_role().get(\'is_admin\')">\n        <a href="#" data-bind="click: redirect_to_admin" ><img src="/images/settings-white.png" />Admin</a>\n        </li>\n      </ul>\n    </li>\n    <li class="divider"></li>\n    <li>\n      <span data-bind="text: current_role().get(\'email\')"></span>\n      <i data-bind="visible: current_role().assumed_other()">as</i>\n      <i data-bind="text: current_role().as_label()"></i>\n      <a href="#" data-bind="visible: current_role().assumed_other(), click: reset_role" class="button">[x]</a>\n    </li>\n    <li>\n    <a href="#" id="logout">Logout</a>\n    </li>\n  </ul>\n</section>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/reports/controls": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<dl class="sub-nav reports">\n  <dt>Report type:</dt>\n  <!-- ko foreach: report_types -->\n    <dd data-bind="attr: {class: active ? \'active\' : \'\'}">\n      <a href="#" data-bind="text: label, click: $root.select_type"></a>\n    </dd>\n  <!-- /ko -->\n</dl>\n<form action="#" class="custom report-controls">\n  <a href="#" data-bind="click: generate_report, attr: {class: generate_status_class}">Generate</a>\n  <div class="charts" data-bind="foreach: chart_levels">\n    <select class="chosen" data-bind="foreach: $data">\n      <option data-bind="value: get(\'id\'), text: get(\'display_label\')"></option>\n    </select>\n  </div>\n  <input type="text" placeholder="Pick date range" data-bind="value: date_range_string, valueUpdate: \'blur\'" class="daterange reports" />\n  <label class="roles">\n    <select data-bind="foreach: roles, selectedOptions: selected_roles" data-customforms="disabled" \n            class="chosen" data-placeholder="Choose roles" multiple>\n      <option data-bind="value: get(\'email\'), text: user_name()"></option>\n    </select>\n  </label>\n<!--  <div class="report-options">\n    <label>\n      <input type="checkbox" data-bind="checked: display_full" style="display: none;">\n      <span class="custom checkbox"></span> Display full descriptions\n    </label>\n    <label>\n      <input type="checkbox" data-bind="checked: printable" style="display: none;">\n      <span class="custom checkbox"></span> Printable\n    </label>\n    <label>\n      <input type="checkbox" data-bind="checked: open_in_new" style="display: none">\n      <span class="custom checkbox"></span> Open in new window\n    </label>\n  </div> -->\n</form>\n\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/reports/show": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div class="report_content" data-bind="template: {name: $root.selected_type().value}"></div>\n\n<script id="break" type="text/html">\n  <ul data-bind="template: {name: \'report_item\', foreach: report_items}"></ul>\n</script>\n\n<script id="user" type="text/html"></script>\n\n<script id="category" type="text/html"></script>\n\n<script id="report_item" type="text/html">\n  <li>\n    <span class="name" data-bind="text: name"></span>\n    <span class="total" data-bind="text: total"></span> \n    <ul data-bind="template: {name: \'report_item\', foreach: children}"></ul>\n  </li>\n</script>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/work_day/show": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<table cellspacing="0" class="work_day_table">\n  <col><col><col><col>\n  <tbody data-bind="template: {name: \'entry_template\', foreach: collection}">\n  </tbody>\n</table>\n<div class="actions">\n  <a data-bind="click: redirect_to_new" class="button"><img src="/images/compose-vivid.png" />New entry</a>\n</div>\n\n<script id="middle_label_template" type="text/x-jquery-tmpl">\n<br>\n    <span data-bind="text: $data"></span>\n</script>\n\n<script id="entry_template" type="text/x-jquery-tmpl">\n<tr>\n    <td>\n      <span data-bind="text: top_label(), visible: chart_has_many_labels()"></span>\n      <span data-bind="template: {name: \'middle_label_template\', foreach: middle_labels()}, visible: chart_has_many_labels()">\n      </span>\n      <br data-bind="visible: chart_has_many_labels()">\n      \n      <b data-bind="text: last_label()"></b>\n    </td>\n    <td>\n      <div data-bind="text: time_string()"></div>\n      <div class="entry_fee" data-bind="text: fee_total_string(), visible: fee_not_empty()"></div>\n    </td>\n    <td class="entry-description" data-bind="html: get(\'description\')"></td>\n    <td>\n      <a data-bind="click: $root.redirect_to_entry" href="#">Edit</a>\n      <ul class="nav-bar">\n        <li class="has-flyout">\n          <a href="#" data-bind="click: $root.entry_settings"><img src="/images/settings-darkgray.png" /></a>\n          <a href="#" class="flyout-toggle"><span></span></a>\n          <ul class="flyout right">\n            <li><img src="/images/delete-darkgray.png" /><a data-bind="click: $root.delete_entry" href="#">Delete</a></li>\n          </ul>\n        </li>\n      </ul>\n      <br>\n    </td>\n  </tr>\n</script>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/work_day/top": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div id="calendar-controls">\n  <a href="#" class="left" data-bind="click: backDay">&lt;</a>\n  <select id="years" data-bind="template: {name: \'year-option\', foreach: years()}, value: year"></select>\n  <select id="months" data-bind="template: {name: \'month-option\', foreach: months()}, value: month"></select>\n  <select id="days" data-bind="template: {name: \'day-option\', foreach: days()}, value: day"></select>\n  <a href="#" class="right" data-bind="click: nextDay">&gt;</a>\n</div>\n\n<script type="text/html" id="year-option">\n  <option data-bind="text: $data, value: $data"></option>\n</script>\n\n<script type="text/html" id="month-option">\n  <option data-bind="text: $data.name, value: $data.value"></option>\n</script>\n\n<script type="text/html" id="day-option">\n  <option data-bind="text: $data, value: $data"></option>\n</script>\n\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/templates/work_day/totals": function(exports, require, module) {
  module.exports = function (__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div class="">\n  <table class="day_totals">\n    <tr>\n      <td>Billable:</td>\n      <td data-bind="text: billable"></td>\n    </tr>\n    <tr>\n      <td>Non-billable:</td>\n      <td data-bind="text: nonbillable"></td>\n    </tr>\n    <tr>\n      <td><b>Total:</b></td>\n      <td><b data-bind="text: total"></b></td>\n    </tr>\n  </table>\n</div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  }
}});

window.require.define({"views/work_day": function(exports, require, module) {
  var WorkDayView, WorkDayViewModel,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  require("lib/backbone_extensions.js");

  module.exports = WorkDayView = (function(_super) {

    __extends(WorkDayView, _super);

    function WorkDayView() {
      this.render = __bind(this.render, this);
      return WorkDayView.__super__.constructor.apply(this, arguments);
    }

    WorkDayView.prototype.top_tpl = require("./templates/work_day/top");

    WorkDayView.prototype.template = require("./templates/work_day/show");

    WorkDayView.prototype.totals_tpl = require("./templates/work_day/totals");

    WorkDayView.prototype.initialize = function() {
      var _this = this;
      this.view = new WorkDayViewModel(this.options.year, this.options.month, this.options.day);
      this.collection = this.options.collection;
      return this.collection.on("reset", function() {
        _this.render();
        _this.collection.each(function(entry) {
          return _this.view.collection.push(entry);
        });
        ko.applyBindings(_this.view, $("#main")[0]);
        ko.applyBindings(_this.view, $("#side")[0]);
        return ko.applyBindings(_this.view, $("header.row")[0]);
      });
    };

    WorkDayView.prototype.render = function() {
      $("#main").html(this.template());
      $("header.row").html(this.top_tpl());
      $("#side").html(this.totals_tpl());
      return $(window).oneTime(100, function() {
        return $(document).foundationNavigation();
      });
    };

    return WorkDayView;

  })(Backbone.View);

  WorkDayViewModel = (function() {

    function WorkDayViewModel(year, month, day) {
      this.new_url = __bind(this.new_url, this);

      this.redirect_to_new = __bind(this.redirect_to_new, this);

      var last_day, max_year, _i, _j, _ref, _results, _results1,
        _this = this;
      this.collection = ko.observableArray();
      last_day = new Date(year, month, 0).getDate();
      this.day = ko.observable(day);
      this.days = ko.observableArray((function() {
        _results = [];
        for (var _i = 1; 1 <= last_day ? _i <= last_day : _i >= last_day; 1 <= last_day ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this));
      this.year = ko.observable(year);
      this.month = ko.observable(month);
      max_year = moment(new Date()).year();
      this.years = ko.observableArray((function() {
        _results1 = [];
        for (var _j = 2002, _ref = Math.max(max_year, parseInt(year)); 2002 <= _ref ? _j <= _ref : _j >= _ref; 2002 <= _ref ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this).reverse());
      this.months = ko.observableArray($.map(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], function(el, i) {
        return {
          name: el,
          value: i + 1
        };
      }));
      this.backDay = function() {
        var date;
        date = moment();
        date.year(year);
        date.date(day);
        date.month(parseInt(month) - 1);
        date.subtract('days', 1);
        return Backbone.history.navigate("/#entries/" + (date.year()) + "/" + (date.month() + 1) + "/" + (date.date()), true);
      };
      this.nextDay = function() {
        var date;
        date = moment();
        date.year(year);
        date.date(day);
        date.add('days', 1);
        date.month(parseInt(month) - 1);
        return Backbone.history.navigate("/#entries/" + (date.year()) + "/" + (date.month() + 1) + "/" + (date.date()), true);
      };
      this.year.subscribe(function(y) {
        if (y.toString() !== year) {
          return Backbone.history.navigate("/#entries/" + y + "/" + month + "/" + day, true);
        }
      });
      this.month.subscribe(function(m) {
        var date, jump_day;
        if (m.toString() !== month) {
          date = moment();
          date.year(year);
          date.month(parseInt(m) - 1);
          date.date(day);
          jump_day = day;
          if (date.month() !== (parseInt(m) - 1)) {
            jump_day = new Date(year, parseInt(m), 0).getDate();
          }
          return Backbone.history.navigate("/#entries/" + year + "/" + m + "/" + jump_day, true);
        }
      });
      this.day.subscribe(function(d) {
        if (d.toString() !== day) {
          return Backbone.history.navigate("/#entries/" + year + "/" + month + "/" + d, true);
        }
      });
      this.billable = ko.computed(function() {
        var hours, minutes;
        hours = _.reduce(_this.collection(), (function(memo, e) {
          return memo + e.billable_hours();
        }), 0);
        minutes = _.reduce(_this.collection(), (function(memo, e) {
          return memo + e.billable_minutes();
        }), 0);
        return moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm").format_interval();
      });
      this.nonbillable = ko.computed(function() {
        var hours, minutes;
        hours = _.reduce(_this.collection(), (function(memo, e) {
          return memo + e.nonbillable_hours();
        }), 0);
        minutes = _.reduce(_this.collection(), (function(memo, e) {
          return memo + e.nonbillable_minutes();
        }), 0);
        return moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm").format_interval();
      });
      this.total = ko.computed(function() {
        var hours, minutes;
        hours = _.reduce(_this.collection(), (function(memo, e) {
          return memo + parseInt(e.hours(), 10);
        }), 0);
        minutes = _.reduce(_this.collection(), (function(memo, e) {
          return memo + parseInt(e.minutes(), 10);
        }), 0);
        return moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm").format_interval();
      });
      this.new_day = moment.utc([year, month - 1, day]);
      this.collection.removeAll();
      this.redirect_to_entry = function(entry) {
        window.app.router.navigate(entry.front_url(), {
          trigger: true
        });
        return false;
      };
      this.delete_entry = function(entry) {
        if (confirm("Do you really want to remove work entry?")) {
          return entry.delete_async({
            success: function() {
              humane.log("Work entry successfully deleted");
              return Backbone.history.refresh();
            },
            error: function(err) {
              return humane.error("Error: " + err);
            }
          });
        }
      };
      this.entry_settings = function(entry) {
        return false;
      };
      this;

    }

    WorkDayViewModel.prototype.redirect_to_new = function() {
      return window.app.router.navigate(this.new_url(), {
        trigger: true
      });
    };

    WorkDayViewModel.prototype.new_url = function() {
      return "/#entries/" + (this.new_day.year()) + "/" + (this.new_day.month() + 1) + "/" + (this.new_day.date()) + "/new";
    };

    return WorkDayViewModel;

  })();
  
}});

