variable "project" {
  default = "winged-woods-316316"
}

variable "cron_pattern" {
  default = "0 7 * * *"
}

variable "label_key" {
  default = "instance-scheduler"
}

variable "label_value" {
  default = "enabled"
}

variable "scheduler_function_bucket" {
  default = "test-lisa6"
}

