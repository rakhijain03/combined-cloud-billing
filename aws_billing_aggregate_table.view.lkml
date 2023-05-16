view: aws_billing_aggregate_table {
  derived_table: {
    partition_keys: ["billing_period_start_date"]
    cluster_keys: ["cost_center"]
    datagroup_trigger: daily
    explore_source: aws_billing_table {
      column: cost_center {}
      column: cost_center_final {}
      column: environment_clean {}
      column: appid {}
      #column: alias { field: account_mapping.alias }
      #column: common_name { field: account_mapping.common_name }
      column: apmid {}
      column: product_code {}
      column: product_sku {}
      column: project_name {}
      column: productfamily {}
      column: description {}
      column: line_item_usage_date {}
      column: line_item_usage_week {}
      column: line_item_usage_month {}
      column: lineitem_resourceid {}
      column: billing_period_start_date {}
      column: billing_period_start_month {}
      column: type {}
      column: total_cost {}
      column: total_usage_amount {}
      column: total_gross_unblended_cost {}
      column: total_edp_discount_amt {}
      column: total_usage_hours {}
      column: total_unblended_cost {}
      column: total_blended_cost {}
      column: total_support_qualified_cost {}
      column: total_support_qualified { field: aws_total_costs.total_support_qualified }
      column: support_costs { field: aws_total_costs.support_costs }
      column: total_tax_qualified_cost {}
      column: total_tax_qualified { field: aws_total_costs.total_tax_qualified }
      column: tax_costs { field: aws_total_costs.tax_costs }
      column: final_costs { field: aws_total_costs.final_costs }
    }
  }
  dimension: cost_center {
    label: "Cost Center"
  }
  dimension: cost_center_final {
    label: "Cost Center Final"
    description: "Final cost center logic, where detailed shared cost centers are reallocated to 1120000185"
  }
  dimension: environment_clean {
    label: "Environment"
    description: "The environment values standardized. EX: prod and production both become Production"
  }
  dimension: appid {
    label:  "Appid"
  }
  dimension: apmid {
    label: "Apmid"
  }
  # dimension: alias {
  #   label: "Alias"
  # }
  dimension: product_sku {
    label: "Product SKU"
  }
  dimension: description {
    label: "Description"
    description: "A description of the pricing tier covered by this line item"
  }
  dimension: productfamily {
    label: "Family"
  }
  dimension: line_item_usage_date {
    group_label: "Line Item Usage"
    label:"Line Item Usage Date"
    type: date
  }
  dimension: line_item_usage_week {
    group_label: "Line Item Usage"
    label: "Line Item Usage Week"
    type: date_week
  }
  dimension: line_item_usage_month {
    group_label: "Line Item Usage"
    label: "Line Item Usage Month"
    type: date_month
  }
  # dimension: common_name {
  #   label: "Common Name"
  # }
  filter: invoice_month_filter {
    type: string
    suggest_explore: month_selection_filter
    suggest_dimension: month_selection_filter.month_select
  }
  dimension: month_select {
    hidden: yes
    type: string
    sql: cast(${billing_period_start_date} as string) ;;
    suggest_explore: month_selection_filter
    suggest_dimension: month_selection_filter.month_select
  }
  dimension: billing_period_start_date {
    hidden: yes
    label: "Billing Period Start Date"
    type: date
  }
  dimension: billing_period_start_month {
    hidden: yes
    label: "Billing Period Start Month"
    type: date_month
  }
  dimension: type {
    label: "Type"
    description: "Fee is one-time RI expense for all-upfront or partial-upfront. RI Fee is recurring RI expense for partial-upfront and no-upfront RI expenses."
  }
  dimension: product_code {
    description: "The AWS product/service being used"
  }
  dimension: project_name {
    label: "Project Name"
  }
  dimension: lineitem_resourceid {
    #hidden: yes
    label: "Resource ID"
    type: number
  }

#################
###Hidden Measures --> Dimensions  ###
#################

  dimension: aws_billing_total_cost {
    hidden: yes
    label: "Aws Billing Table Total"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.total_cost ;;
  }
  dimension: line_items_total_usage_amount {
    hidden: yes
    label: "Line Items (Individual Charges) Total Usage Amount"
    description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
    value_format: "#,##0"
    type: number
    sql: ${TABLE}.total_usage_amount ;;
  }
  dimension: line_items_total_gross_unblended_cost {
    hidden: yes
    label: "Line Items (Individual Charges) Total Gross Unblended Cost"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed, not including EDP Discount"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.total_gross_unblended_cost ;;
  }
  dimension: savings_plans_total_edp_discount_amt {
    hidden: yes
    label: "Savings Plans Total EDP Discount - Raw"
    value_format: "$#,##0"
    type: number
    sql: ${TABLE}.total_edp_discount_amt ;;
  }
  dimension: line_items_total_unblended_cost {
    hidden: yes
    label: "Line Items (Individual Charges) Total Unblended Cost"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed."
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.total_unblended_cost ;;
  }
  dimension: aws_total_costs_total_support_qualified_cost {
    label: "Custom Resource Tagging Total Support Qualified Cost"
    value_format: "$#,##0.00"
    type: number
    hidden: yes
    sql: ${TABLE}.total_support_qualified_cost ;;
  }
  dimension: aws_total_costs_total_support_qualified {
    hidden: yes
    type: number
    sql: ${TABLE}.total_support_qualified  ;;

  }
  dimension: aws_total_costs_support_costs {
    hidden: yes
    label: "Custom Resource Tagging Support Costs"
    description: "Redistributed support costs from shared account based on % spend"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.support_costs ;;
  }
  dimension: aws_total_costs_total_tax_qualified {
    hidden: yes
    type: number
    sql: ${TABLE}.total_tax_qualified ;;
  }
  dimension: aws_total_costs_total_tax_qualified_cost {
    hidden: yes
    label: "Custom Resource Tagging Total Tax Qualified Cost"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.total_tax_qualified_cost ;;
  }
  dimension: aws_total_costs_tax_costs {
    hidden: yes
    label: "Custom Resource Tagging Tax Costs"
    description: "Redistributed tax costs from shared account based on % of shared spend"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.tax_costs ;;
  }
  dimension: line_items_total_total_usage_hours {
    view_label: "Billing Info"
    type: number
    sql: ${TABLE}.total_usage_hours ;;
    hidden: yes  ## hours do not reflect # of CPUs, use Usage Amount measures instead -- James Sutton 05/05/2020
  }
  dimension: aws_total_costs_final_costs {
    hidden: yes
    label: "Custom Resource Tagging Final Costs"
    description: "Final Costs after redistribution of Shared Support and Tax Spend"
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}.final_costs ;;
  }
  dimension: aws_total_costs_total_blended_cost {
    hidden: yes
    view_label: "Line Items (Individual Charges)"
    description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
    type: number
    sql: ${TABLE}.total_blended_cost  ;;
    value_format: "$#,##0.00"
  }

#################
###Dimensions --> Measures  ###
#################

  measure: reesource_count {
    view_label: "Line Items (Individual Charges)"
    type: count_distinct
    sql: ${lineitem_resourceid} ;;
  }
  measure: count_usage_months {
#     hidden: yes
  type: count_distinct
  sql: ${billing_period_start_month} ;;
  drill_fields: [billing_period_start_month, total_measures*]
}
measure: total_cost {
  group_label: "Costs"
  label: "Total"
  value_format_name: usd
  type: sum
  sql: ${aws_billing_total_cost} ;;
}
measure: total_usage_amount {
  view_label: "Line Items (Individual Charges)"
  description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
  type: sum
  sql: ${line_items_total_usage_amount} ;;
  value_format_name: decimal_0
  drill_fields: [basic_blended_measures*]
}
measure: total_gross_unblended_cost {
  view_label: "Line Items (Individual Charges)"
  description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed, not including EDP Discount"
  type: sum
  sql: ${line_items_total_gross_unblended_cost} ;;
  value_format_name: usd
  drill_fields: [common*,cost_measures*]
}
measure: total_edp_discount_amt {
  type: sum
  view_label: "Savings Plans"
  label: "Total EDP Discount - Raw"
  sql: ${savings_plans_total_edp_discount_amt};;
  value_format_name: usd_0
}
measure: total_unblended_cost {
  view_label: "Line Items (Individual Charges)"
  description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed."
  type: sum
  sql: ${line_items_total_unblended_cost};;
  value_format_name: usd
  drill_fields: [common*,cost_measures*]
}
measure: total_support_qualified_cost {
  type: sum
  sql: ${aws_total_costs_total_support_qualified_cost} ;;
  hidden: yes
}
measure: total_support_qualified {
  type: max
  sql: ${aws_total_costs_total_support_qualified} ;;
  hidden: yes
}
measure: support_allocation_percent {
  type: number
  sql: ${total_support_qualified_cost} / nullif(${total_support_qualified},0) ;;
  value_format_name: percent_1
  description: "Percent of total support qualified cost, to be used for realloaction of shared support spend"
  view_label: "Custom Resource Tagging"
}
measure: total_tax_qualified_cost {
  type: sum
  sql: ${aws_total_costs_total_tax_qualified_cost} ;;
  hidden: yes
}
measure: total_tax_qualified {
  type: max
  sql: ${aws_total_costs_total_tax_qualified} ;;
  hidden: yes
}
measure: tax_allocation_percent {
  type: number
  sql: ${total_tax_qualified_cost} / nullif(${total_tax_qualified},0) ;;
  value_format_name: percent_1
  description: "Percent of total tax qualified cost, to be used for realloaction of shared tax spend"
  view_label: "Custom Resource Tagging"
}
measure: support_costs {
  type: sum
  description: "Redistributed support costs from shared account based on % spend"
  sql: ${aws_total_costs_support_costs} ;;
  value_format_name: usd
  view_label: "Custom Resource Tagging"
}
measure: tax_costs {
  type: sum
  description: "Redistributed tax costs from shared account based on % of shared spend"
  sql: ${aws_total_costs_tax_costs} ;;
  value_format_name: usd
  view_label: "Custom Resource Tagging"
}
measure: final_costs {
  type: sum
  description: "Final Costs after redistribution of Shared Support and Tax Spend"
  sql: ${aws_total_costs_final_costs} ;;
  value_format_name: usd
  view_label: "Custom Resource Tagging"
  drill_fields: [final_cost*]
}
measure: total_blended_cost {
  view_label: "Line Items (Individual Charges)"
  description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
  type: sum
  sql: ${aws_total_costs_total_blended_cost} ;;
  value_format_name: usd
  drill_fields: [common*, total_blended_cost,  total_measures*]
}
measure: average_blended_cost_per_month {
  view_label: "Line Items (Individual Charges)"
  description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
  type: number
  sql: ${total_blended_cost}/NULLIF(${count_usage_months},0) ;;
  value_format_name: usd_0
  link: {
    label: "Explore Total Blended Cost"
    url: "{{total_blended_cost._link}}"
  }
  link: {
    label: "Explore Months"
    url: "{{count_usage_months._link}}"
  }
}
measure: total_usage_hours_per_day {
  view_label: "Billing Info"
  label: "Total Usage"
  type: sum
  sql: ${line_items_total_total_usage_hours} ;;
}

#################
###Sets###
#################

set: common {fields: [lineitem_resourceid,   type, description]}
set: cost_measures {fields: [total_unblended_cost, total_usage_amount]}
set: basic_blended_measures {fields: [average_blended_cost_per_month, total_usage_amount]}
set: final_cost {fields: [project_name, apmid, product_code, environment_clean, cost_center, lineitem_resourceid, total_unblended_cost, tax_costs, support_costs, final_costs]}
set: total_measures {fields: [total_blended_cost, total_unblended_cost]  }




}
