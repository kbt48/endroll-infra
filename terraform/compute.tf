resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&()*+,-./:;<=>?@[]^_{|}~"
}

# --- Virtual Machine ---
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-encoding"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin_password.result

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 256
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-pro"
    version   = "latest"
  }
}

# --- VM Extensions ---



# Configure WinRM and Mount Azure Files via CustomScriptExtension
resource "azurerm_virtual_machine_extension" "post_deploy" {
  name                       = "post-deploy"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://download.microsoft.com/download/dcf4d002-3a53-469d-91af-04bddf57a9d7/573.76_grid_win10_win11_server2019_server2022_server2025_dch_64bit_international_azure_swl.exe' -OutFile 'C:\\grid_driver.exe'; Start-Process -FilePath 'C:\\grid_driver.exe' -ArgumentList '-s' -Wait; Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile ConfigureRemotingForAnsible.ps1; .\\ConfigureRemotingForAnsible.ps1 -ForceNewSSLCert; Restart-Computer -Force\""
    }
SETTINGS

  depends_on = [azurerm_storage_share.share]
}

# --- Auto Shutdown Schedule (23:00 JST -> 14:00 UTC) ---
resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  location           = azurerm_resource_group.rg.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "Tokyo Standard Time"

  notification_settings {
    enabled = false
  }
}
