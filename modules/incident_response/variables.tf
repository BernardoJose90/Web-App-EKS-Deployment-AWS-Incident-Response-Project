variable "alert_email" { 
    type = string 
    description = "Email address to receive incident alerts"
}

variable "tags" { 
    type = map(string) 
    description = "A map of tags to assign to resources"
    default = {}
}   
