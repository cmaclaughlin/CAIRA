# ---------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. Licensed under the MIT license.
# ---------------------------------------------------------------------

variable "base_name" {
  type        = string
  description = "Base name used as suffix in the naming module."
  default     = "basic"
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = "swedencentral"
  nullable    = false
}

variable "resource_group_resource_id" {
  type        = string
  description = "The resource group resource id where the module resources will be deployed. If not provided, a new resource group will be created."
  default     = null
}

variable "sku" {
  type        = string
  description = "The SKU for the AI Foundry resource. The default is 'S0'."
  default     = "S0"
}

variable "model_deployments" {
  description = "The list of model deployments to create in AI Foundry."
  type = list(object({
    name    = string
    version = string
    format  = string
    sku = optional(object({
      name     = string
      capacity = number
      }), {
      name     = "GlobalStandard"
      capacity = 50
    })
  }))
  default = [
    {
      format  = "OpenAI"
      name    = "gpt-5-chat"
      version = "2025-10-03"
    },
    {
      format  = "OpenAI"
      name    = "gpt-5-nano"
      version = "2025-08-07"
    },
    {
      format  = "OpenAI"
      name    = "text-embedding-3-large"
      version = "1"
    },
    {
      format  = "OpenAI"
      name    = "gpt-4o-mini"
      version = "2024-07-18"
    }
  ]
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags to be applied to all resources."
}
