
variable "resource_group_location" {
  type        = string
  default     = "polandcentral"
  description = "Location of the resource group"
}

variable "resource_group_name" {
  type        = string
  default     = "devopsschool5"
  description = "RG name"
}

variable "resource_group_name_node_pool" {
  type        = string
  default     = "devopsschool5nodepool"
  description = "RG name for node pool"
}

variable "kluster_name" {
  type        = string
  default     = "devopsschool5aks"
  description = "AKS Name"
}

variable "acr_name" {
  type        = string
  default     = "devopsschool5acr"
  description = "ACR Name"
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool"
  default     = 3
}

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method"
  default     = null
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster"
  default     = "azureadmin"
}