# --- Generate Ansible Inventory and Variables ---

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yml"
  content  = <<-EOT
    windows:
      hosts:
        windows_vm:
          ansible_host: ${azurerm_public_ip.pip.fqdn}
          ansible_user: ${var.admin_username}
          ansible_password: "${random_password.admin_password.result}"
          ansible_port: 5986
          ansible_connection: winrm
          ansible_winrm_server_cert_validation: ignore
          
          # Custom Variables for Playbook
          storage_account_name: ${azurerm_storage_account.sa.name}
          storage_key: "${azurerm_storage_account.sa.primary_access_key}"
  EOT
}
