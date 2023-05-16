view: aws_savings_plan_total {
  derived_table: {
    explore_source: aws_billing_table {
      column: savings_plan_savings_plan_a_r_n {}
      column: total_unblended_cost_raw {}
      column: total_unused_savings_plan_amount {}
      column: total_savings_plan_effective_cost {}
      column: total_edp_discount_amt {}
      column: total_savings_plan_net_cost {}
      column: month_select {}
      column: total_usage_savings_plan_edp_discount {}
      column: total_unused_savings_plan_edp_discount {}
      column: total_savings_plan_recurring_fee_rows {}
      column: total_unused_savings_plan_amount_per_row {}
      column: total_unused_edp_discount_per_row {}
      filters: {
        field: aws_billing_table.savings_plan_savings_plan_a_r_n
        value: "-EMPTY,-NULL"
      }
    }
  }
  dimension: savings_plan_savings_plan_a_r_n {
    label: "Savings Plans Savings Plan Savings Plan A R N"
    hidden: yes
  }
  dimension: total_unblended_cost_raw {
    label: "Line Items (Individual Charges) Total Unblended Cost Raw"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed, where RIs are in main cost center and not allocated to used resources"
    value_format: "$#,##0.00"
    hidden: yes
    type: number
  }
  dimension: total_unused_savings_plan_amount {
    label: "Savings Plans Total Unused Savings Plan Amount"
    value_format: "$#,##0"
    hidden: no
    type: number
  }
  dimension: total_savings_plan_effective_cost {
    label: "Savings Plans Total Savings Plan Effective Cost"
    description: "Total Savings Plan Effective Cost - Prior to EDP Discount"
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  dimension: total_edp_discount_amt {
    label: "Savings Plans Total EDP Discount"
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  dimension: total_savings_plan_recurring_fee_rows {
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  dimension: total_unused_savings_plan_amount_per_row {
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  dimension: month_select {
    hidden: yes
  }
  dimension: bill_invoiceid {
    hidden: yes
  }
  dimension: total_usage_savings_plan_edp_discount {
    label: "Savings Plans Total Usage Savings Plan Edp Discount"
    description: "Difference between total savings plan effective costs and total net costs"
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  dimension: total_unused_savings_plan_edp_discount {
    label: "Savings Plans Total Unused Savings Plan Edp Discount"
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  dimension: total_unused_edp_discount_per_row {
    value_format: "$#,##0"
    hidden: yes
    type: number
  }
  measure: unused_savings_plan_amt {
    type: max
    hidden: yes
    sql: ${total_unused_savings_plan_amount} ;;
  }
  measure: unused_edp_discount_amt {
    type: max
    hidden: yes
    sql: ${total_unused_savings_plan_edp_discount} ;;
  }
}
