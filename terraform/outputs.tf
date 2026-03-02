output "public_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}

output "public_ip_fqdn" {
  value = azurerm_public_ip.pip.fqdn
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  value     = random_password.admin_password.result
  sensitive = true
}

output "storage_account_name" {
  value     = azurerm_storage_account.sa.name
  sensitive = true
}

output "smb_path" {
  value     = "\\\\${azurerm_storage_account.sa.name}.file.core.windows.net\\${azurerm_storage_share.share.name}"
  sensitive = false
}

output "storage_primary_access_key" {
  value     = azurerm_storage_account.sa.primary_access_key
  sensitive = true
}

# Generate Ansible Inventory dynamically
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yml"
  content = templatefile("${path.module}/inventory.tftpl", {
    fqdn                 = azurerm_public_ip.pip.fqdn
    admin_username       = var.admin_username
    admin_password       = random_password.admin_password.result
    storage_account_name = azurerm_storage_account.sa.name
    storage_key          = azurerm_storage_account.sa.primary_access_key
  })
}
