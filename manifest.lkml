constant: gcp_billing_table {
  value: "billing.gcp_billing_export"
  export: override_optional
}

# constant: gcp_recommendations_table {}

constant: gcp_pricing_table {
  value: "billing.cloud_pricing_export"
  export: override_optional
}

constant: aws_billing_table {
  value: ""
  export: override_optional
}

# constant: azure_billing_table {
#   value: ""
#   export: override_optional
# }
