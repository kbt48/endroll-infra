variable "location" {
  description = "Azure region to deploy resources"
  default     = "japaneast"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "rg-video-encoding"
}

variable "vm_size" {
  description = "Size of the VM (requires GPU support)"
  default     = "Standard_NC4as_T4_v3"
}

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "videoadmin"
}

variable "alert_emails" {
  description = "List of email addresses for cost alerts"
  type        = list(string)
  default     = ["admin@example.com"]
}

variable "dns_name" {
  description = "The DNS name label for the Public IP address."
  type        = string
  default     = null
}
