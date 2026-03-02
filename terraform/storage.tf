# --- Storage Account for Azure Files ---
resource "azurerm_storage_account" "sa" {
  # Add random suffix to avoid naming collision
  name                     = "savideoencode${substr(md5(azurerm_resource_group.rg.name), 0, 8)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name                 = "encoded-videos"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 50
}
