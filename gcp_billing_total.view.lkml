view: gcp_billing_total {
    derived_table: {
      explore_source: gcp_billing {
        column: invoice_month {}
        column: total_credit {}
        column: total_gross_cost {}
        column: total_net_cost {}
        column: total_support {}
        column: total_tax {}
        column: total_net_cost_less_support_tax {}
      }
    }
    dimension: invoice_month {
      hidden: yes
    }
    dimension: total_credit {
      description: "The total amount of all usage credits associated to an SKU, between Start Date and End Date"
      value_format: "$#,##0.00"
      type: number
      hidden: yes
    }
    dimension: total_gross_cost {
      description: "The total cost associated to the SKU, between the Start Date and End Date"
      value_format: "$#,##0.00"
      type: number
      hidden: yes
    }
    dimension: total_net_cost {
      description: "The total cost associated to an SKU, between Start Date and End Date, less credits"
      value_format: "$#,##0.00"
      type: number
      hidden: yes
    }
    dimension: total_support {
      value_format: "$#,##0.00"
      type: number
      hidden: yes
    }
    dimension: total_tax {
      value_format: "$#,##0.00"
      type: number
      hidden: yes
    }
    dimension: total_net_cost_less_support_tax {
      description: "The total net costs after credit, less support and tax"
      value_format: "$#,##0.00"
      hidden: yes
      type: number
    }
    measure: total_cost_less_support_tax {
      type: max
      sql: ${total_net_cost_less_support_tax} ;;
      hidden: yes
    }
    measure: total_tax_costs {
      type: max
      sql: ${total_tax} ;;
      hidden: yes
    }
    measure: total_support_costs {
      type: max
      sql: ${total_support} ;;
      hidden: yes
    }
  }
