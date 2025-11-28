variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "openai_api_key" {
  type      = string
  sensitive = true
}

variable "google_api_key" {
  type      = string
  sensitive = true
}

variable "google_cx_id" {
  type      = string
  sensitive = true
}
