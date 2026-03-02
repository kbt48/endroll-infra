# --- Cost Management Budget ---
resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "budget-${azurerm_resource_group.rg.name}"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = 100000
  time_grain = "Monthly"

  time_period {
    start_date = "2026-03-01T00:00:00Z" # Start date set to current month (March 2026)
  }

  notification {
    enabled        = true
    threshold      = 30 # 30,000 / 100,000 = 30%
    operator       = "GreaterThan"
    contact_emails = var.alert_emails
  }

  notification {
    enabled        = true
    threshold      = 50 # 50,000 / 100,000 = 50%
    operator       = "GreaterThan"
    contact_emails = var.alert_emails
  }

  notification {
    enabled        = true
    threshold      = 100 # 100,000 / 100,000 = 100%
    operator       = "GreaterThan"
    contact_emails = var.alert_emails
  }
}
