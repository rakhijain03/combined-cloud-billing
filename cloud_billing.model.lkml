connection: "elevate_admin"

# include all the views
include: "/views/**/*.view"


datagroup: gcp_datagroup {
  sql_trigger: SELECT MAX(date(export_time)) from @{gcp_billing_table} ;;
  max_cache_age: "1 hour"
}

datagroup: aws_datagroup {
  sql_trigger: SELECT MAX(date(line_item_usage_start_date)) from @{aws_billing_table} ;;
  max_cache_age: "1 hour"
}

# datagroup: azure_datagroup {}

# datagroup: daily {
#   #sql_trigger:  ;; # to define based on ingestion process for different cloud billing datasets
# }

access_grant: admin {
  user_attribute: admin
  allowed_values: ["Yes"]
}


### Combined ###

# explore: cloud_billing_combined {
#   label: "Combined Cloud Billing"
#   view_label: "Combined Cloud Billing"
#   hidden: no
#   join: standardized_category {
#     view_label: "Combined Cloud Billing"
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${cloud_billing_combined.service} = ${standardized_category.product_code}
#           and
#             ${cloud_billing_combined.sku_category} = ${standardized_category.sku_category}
#         ;;
#   }
#   required_access_grants: [admin]
# }


### GCP ###


# Main GCP Explore
explore: gcp_billing {
  join: gcp_billing_total { ## monthly totals for calculations of % of total reallocations
    sql_on: ${gcp_billing.invoice_month} = ${gcp_billing.invoice_month} ;;
    relationship: many_to_one
  }
  required_access_grants: [admin]
}


## Raw based explore, no summary ##
explore: gcp_billing_export {
  label: "Billing"
  hidden: yes
  join: gcp_billing_export__labels {
    sql: ,UNNEST(${gcp_billing_export.labels}) as gcp_billing_export__labels ;;
    relationship: one_to_one
  }

  join: gcp_billing_export__credits {
    sql: ,UNNEST(${gcp_billing_export.credits}) as gcp_billing_export__credits ;;
    relationship: one_to_many
  }

  join: gcp_billing_export__system_labels {
    sql: ,UNNEST(${gcp_billing_export.system_labels}) as gcp_billing_export__system_labels ;;
    relationship: one_to_many
  }

  join: gcp_billing_export__project__labels {
    sql: ,UNNEST(${gcp_billing_export.project__labels}) as gcp_billing_export__project__labels ;;
    relationship: one_to_many
  }

  join: pricing {
    relationship: one_to_one
    sql_on: ${pricing.sku__id} = ${gcp_billing_export.sku__id} ;;
  }

  required_access_grants: [admin]
}


## Pricing Only Information ##
explore: cloud_pricing_export {
  label: "Pricing Taxonomy"
  hidden: yes
  # right now only supporting BigQuery, Compute Engine and Cloud Storage for product specific analysis
  sql_always_where: ${service__description} IN (
        'Compute Engine',
        'Cloud Storage',
        'BigQuery',
        'BigQuery Reservation API',
        'BigQuery Storage API') ;;

    join: cloud_pricing_export__product_taxonomy {
      view_label: "Cloud Pricing Export: Product Taxonomy"
      sql: ,UNNEST(${cloud_pricing_export.product_taxonomy}) as cloud_pricing_export__product_taxonomy ;;
      relationship: one_to_many
    }

    join: cloud_pricing_export__geo_taxonomy__regions {
      view_label: "Cloud Pricing Export: Geo Taxonomy Regions"
      sql: ,UNNEST(${cloud_pricing_export.geo_taxonomy__regions}) as cloud_pricing_export__geo_taxonomy__regions ;;
      relationship: one_to_many
    }

    join: cloud_pricing_export__list_price__tiered_rates {
      view_label: "Cloud Pricing Export: List Price Tiered Rates"
      sql: ,UNNEST(${cloud_pricing_export.list_price__tiered_rates}) as cloud_pricing_export__list_price__tiered_rates ;;
      relationship: one_to_many
    }

    join: cloud_pricing_export__sku__destination_migration_mappings {
      view_label: "Cloud Pricing Export: Sku Destination Migration Mappings"
      sql: ,UNNEST(${cloud_pricing_export.sku__destination_migration_mappings}) as cloud_pricing_export__sku__destination_migration_mappings ;;
      relationship: one_to_many
    }

    join: cloud_pricing_export__billing_account_price__tiered_rates {
      view_label: "Cloud Pricing Export: Billing Account Price Tiered Rates"
      sql: ,UNNEST(${cloud_pricing_export.billing_account_price__tiered_rates}) as cloud_pricing_export__billing_account_price__tiered_rates ;;
      relationship: one_to_many
    }
}


### AWS ###

# explore: aws_billing_table {
#   from: aws_billing_table
#   required_access_grants: [admin]
#   label: "AWS Cost & Usage - Raw"
#   join: aws_reservation_total {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${aws_billing_table.ri_reservation_id} = ${aws_reservation_total.ri_reservation_id}
#       and ${aws_billing_table.bill_invoiceid} = ${aws_reservation_total.bill_invoiceid};;
#   }
#   join: aws_total_costs {
#     relationship: one_to_one
#     type:left_outer
#     sql_on: ${aws_billing_table.billing_period_start_raw} = ${aws_total_costs.billing_period_start_raw}  ;;
#   }
#   join: aws_savings_plan_total {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${aws_billing_table.savings_plan_savings_plan_a_r_n} = ${aws_savings_plan_total.savings_plan_savings_plan_a_r_n}
#       and ${aws_billing_table.month_select} = ${aws_savings_plan_total.month_select};;
#   }
# }

# explore: aws_billing_aggregate_table {
#   label: "AWS Cost & Usage"
#   hidden: yes
#   sql_always_where:-- filter to hit date partition and reduce scan
#   {% if aws_billing_aggregate_table.invoice_month_filter._is_filtered %}
#   {% condition aws_billing_aggregate_table.invoice_month_filter %}
#   ${aws_billing_aggregate_table.billing_period_start_date}
#   {% endcondition %}
#   {% else %}
#   1=1
#   {% endif %};;
# }


### Azure ###
