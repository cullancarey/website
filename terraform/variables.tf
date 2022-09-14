variable "root_domain_name" {
  type = string
  default = "cullancarey.com"
  description = "The domain name of my website."
}

variable "intake_api_domain" {
  type = string
  default = "form.cullancarey.com"
  description = "The domain name of the api gateway resource that intakes the websites contact form."
}