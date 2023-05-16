view: aws_total_costs {
  derived_table: {
    persist_for: "24 hours"
    explore_source: aws_billing_table {
      column: total_unblended_cost {}
      column: total_tax_qualified_cost {}
      column: total_support_qualified_cost {}
      column: total_shared_support_cost {}
      column: total_shared_tax_cost {}
      column: billing_period_start_raw {}
#       bind_all_filters: no
#       bind_filters: {
#         from_field: aws_billing_table.invoice_month_filter
#         to_field: aws_billing_table.invoice_month_filter
#       }
    }
  }
  dimension_group: billing_period_start {
    type: time
    timeframes: [raw,date]
    hidden: yes
    sql: ${TABLE}.billing_period_start_raw ;;
  }
  dimension: bill_invoiceid {
    hidden: yes
  }
  dimension: total__cost {
    hidden: yes
    type: number
  }
  dimension: total_tax_qualified_cost {
    hidden: yes
    type: number
  }
  dimension: total_support_qualified_cost {
    hidden: yes
    type: number
  }
  dimension: total_shared_support_cost {
    hidden: yes
    type: number
  }
  dimension: total_shared_tax_cost {
    hidden: yes
    type: number
  }
  measure: total_cost {
    type: max
    sql: ${total__cost} ;;
    hidden: yes
  }
  measure: total_tax_qualified {
    type: max
    sql: ${total_tax_qualified_cost} ;;
    hidden: yes
  }
  measure: total_support_qualified {
    type: max
    sql: ${total_support_qualified_cost} ;;
    hidden: yes
  }
  measure: total_tax {
    type: max
    sql: ${total_shared_tax_cost} ;;
    hidden: yes
  }
  measure: total_support {
    type: max
    sql: ${total_shared_support_cost} ;;
    hidden: yes
  }


  ## Custom Measures ##

  measure: tax_allocation_percent {
    type: number
    sql: ${aws_billing_table.total_tax_qualified_cost} / nullif(${total_tax_qualified},0) ;;
    value_format_name: percent_1
    description: "Percent of total tax qualified cost, to be used for realloaction of shared tax spend"
    view_label: "Custom Resource Tagging"
  }

  measure: support_allocation_percent {
    type: number
    sql: ${aws_billing_table.total_support_qualified_cost} / nullif(${total_support_qualified},0) ;;
    value_format_name: percent_1
    description: "Percent of total support qualified cost, to be used for realloaction of shared support spend"
    view_label: "Custom Resource Tagging"
  }

  measure: support_costs {
    type: number
    description: "Redistributed support costs from shared account based on % spend"
    sql: ${support_allocation_percent} * ${total_support} ;;
    value_format_name: usd
    view_label: "Custom Resource Tagging"
  }

  measure: tax_costs {
    type: number
    description: "Redistributed tax costs from shared account based on % of shared spend"
    sql: ${tax_allocation_percent} * ${total_tax} ;;
    value_format_name: usd
    view_label: "Custom Resource Tagging"
  }

  measure: final_costs {
    type: number
    description: "Final Costs after redistribution of Shared Support and Tax Spend"
    sql: ${aws_billing_table.total_non_shared_support_tax_cost} + ${support_costs} + ${tax_costs} ;;
    value_format_name: usd
    view_label: "Custom Resource Tagging"
    drill_fields: [final_cost*]
  }

  set: final_cost {fields: [aws_billing_table.lineitem_usageaccountid, aws_billing_table.project_name, aws_billing_table.apmid, aws_billing_table.product_servicecode, aws_billing_table.application, aws_billing_table.cost_center, aws_billing_table.cost_center_1to1, aws_billing_table.cost_center_raw_2, aws_billing_table.lineitem_resourceid, aws_billing_table.total_unblended_cost, tax_costs, support_costs, final_costs]}

}

view: aws_total_costs_cross_join {
  derived_table: {
    explore_source: aws_billing_table {
      column: total_unblended_cost {}
      column: total_tax_qualified_cost {}
      column: total_support_qualified_cost {}
      column: total_shared_support_cost {}
      column: total_shared_tax_cost {}
      column: month_select {}
      bind_all_filters: no
      bind_filters: {
        from_field: aws_billing_table.invoice_month_filter
        to_field: aws_billing_table.invoice_month_filter
      }
    }
  }
  dimension_group: month_select{
    type: time
    timeframes: [raw,date]
    hidden: yes
    sql: ${TABLE}.billing_period_start_raw ;;
  }
  dimension: bill_invoiceid {
    hidden: yes
  }
  dimension: total__cost {
    hidden: yes
    type: number
  }
  dimension: total_tax_qualified_cost {
    hidden: yes
    type: number
  }
  dimension: total_support_qualified_cost {
    hidden: yes
    type: number
  }
  dimension: total_shared_support_cost {
    hidden: yes
    type: number
  }
  dimension: total_shared_tax_cost {
    hidden: yes
    type: number
  }
  measure: total_cost {
    type: max
    sql: ${total__cost} ;;
    hidden: yes
  }
  measure: total_tax_qualified {
    type: max
    sql: ${total_tax_qualified_cost} ;;
    hidden: yes
  }
  measure: total_support_qualified {
    type: max
    sql: ${total_support_qualified_cost} ;;
    hidden: yes
  }
  measure: total_tax {
    type: max
    sql: ${total_shared_tax_cost} ;;
    hidden: yes
  }
  measure: total_support {
    type: max
    sql: ${total_shared_support_cost} ;;
    hidden: yes
  }


  ## Custom Measures ##

  measure: tax_allocation_percent {
    type: number
    sql: ${aws_billing_table.total_tax_qualified_cost} / nullif(${total_tax_qualified},0) ;;
    value_format_name: percent_1
    description: "Percent of total tax qualified cost, to be used for realloaction of shared tax spend"
    view_label: "Custom Resource Tagging"
  }

  measure: support_allocation_percent {
    type: number
    sql: ${aws_billing_table.total_support_qualified_cost} / nullif(${total_support_qualified},0) ;;
    value_format_name: percent_1
    description: "Percent of total support qualified cost, to be used for realloaction of shared support spend"
    view_label: "Custom Resource Tagging"
  }

  measure: support_costs {
    type: number
    description: "Redistributed support costs from shared account based on % spend"
    sql: ${support_allocation_percent} * ${total_support} ;;
    value_format_name: usd
    view_label: "Custom Resource Tagging"
  }

  measure: tax_costs {
    type: number
    description: "Redistributed tax costs from shared account based on % of shared spend"
    sql: ${tax_allocation_percent} * ${total_tax} ;;
    value_format_name: usd
    view_label: "Custom Resource Tagging"
  }

  measure: final_costs {
    type: number
    description: "Final Costs after redistribution of Shared Support and Tax Spend"
    sql: ${aws_billing_table.total_non_shared_support_tax_cost} + ${support_costs} + ${tax_costs} ;;
    value_format_name: usd
    view_label: "Custom Resource Tagging"
    drill_fields: [final_cost*]
  }

  set: final_cost {fields: [aws_billing_table.lineitem_usageaccountid, aws_billing_table.project_name, aws_billing_table.apmid, aws_billing_table.product_servicecode, aws_billing_table.application, aws_billing_table.cost_center, aws_billing_table.cost_center_1to1, aws_billing_table.cost_center_raw_2, aws_billing_table.lineitem_resourceid, aws_billing_table.total_unblended_cost, tax_costs, support_costs, final_costs]}

}
