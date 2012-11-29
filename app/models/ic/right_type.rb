class IC::RightType < ActiveRecord::Base
  set_table_name :ic_right_types

  # At least when you'll misspell typ code in constant
  # you'll se an exception
  SWITCH_USER            = "switch_user"
  SUPERUSER              = "superuser"
  ACCESS_SITE_MANAGEMENT = "access_site_mgmt"
  REPORT                 = "report"
  MANAGE                 = "manage"
  BILL                   = "bill"
  ACCESS_CONTROL         = "access_control"
  NAGGABLE               = "naggable"
  ACCOUNT_OVERVIEW       = "accounts_overview"
  VIEW_ACCOUNT           = "view_account"
  EDIT_ACCOUNT           = "edit_account"
  REPORT                 = "report"
  EXECUTE                = "execute"
end
