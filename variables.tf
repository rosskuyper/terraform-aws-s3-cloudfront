# https://www.terraform.io/docs/configuration/variables.html

variable "name" {
  description = "DNS compatible identifier for the cluster. Used within the S3 bucket name and Cloudfront description."
  type        = string
}

variable "domain_names" {
  description = "List of domains to attach to the CDN."
  type        = list(string)
}

variable "zone_id" {
  description = "Route 53 zone ID for DNS records."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to attach to the Cloudfront Distibution. Must exist in us-east-1."
  type        = string
}

variable "versioning_enabled" {
  description = "Whether s3 versioning should be enabled for the bucket."
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Default root object for the Cloudfront distribution."
  type        = string
  default     = "index.html"

  validation {
    condition     = substr(var.default_root_object, 0, 1) != "/"
    error_message = "The default_root_object specified must not start with a slash."
  }
}

variable "minimum_protocol_version" {
  description = "HTTPS / TLS minimum protocol version."
  type        = string
  default     = "TLSv1.2_2018"
}
