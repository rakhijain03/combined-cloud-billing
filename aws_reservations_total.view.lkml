view: aws_reservation_total {
  derived_table: {
    datagroup_trigger: daily
    explore_source: aws_billing_table {
      column: ri_reservation_id {}
      column: reservation_arn {}
      column: total_reserved_usage_amount_temp {}
      column: max_reservation_rate {}
      column: max_reserved_units {}
      column: month_select {}
      column: bill_invoiceid {}
      filters: {
        field: aws_billing_table.ri_line_item
        value: "Yes"
      }
      filters: {
        field: aws_billing_table.type
        value: "-Tax"
      }
      filters: {
        field: aws_billing_table.reservation_arn
        value: "-NULL,-EMPTY"
      }
      bind_all_filters: no
    }
    # sql_trigger_value: select max(usage_start_raw) ;;
  }
  dimension: month_select {}
  dimension: bill_invoiceid {}
  dimension: ri_reservation_id {
    label: "Reserved Units Reservation Identifier"
  }
  dimension: reservation_arn {
    label: "Reserved Units Reservation Arn"
    primary_key: yes
    description: "When an RI benefit discount is applied to a matching line item of usage, the ARN value in the reservation/ReservationARN column for the initial upfront fees and recurring monthly charges matches the ARN value in the discounted usage line items."
  }
  dimension: total_reserved_usage_amount_temp {
    label: "Total Reserved Usage Amount"
    description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
    value_format: "#,##0"
    type: number
  }
  dimension: max_reservation_rate {
    label: "Reserved Units Max Reservation Rate"
    type: number
  }
  dimension: max_reserved_units {
    label: "Reserved Units Max Reserved Units"
    type: number
  }
  dimension: total_unused_usage_amount {
    label: "Total Unused Usage Amount"
    type: number
    sql: safe_cast(${max_reserved_units} as numeric) - safe_cast(${total_reserved_usage_amount_temp} as numeric);;
    value_format_name: decimal_1
  }
  measure: reservation_rate {
    type: average
    value_format_name: usd
    sql: safe_cast(${max_reservation_rate} as numeric) ;;
    hidden: yes
  }
}

view: aws_reservation_total_cross_join {
  derived_table: {
    explore_source: aws_billing_table {
      column: ri_reservation_id {}
      column: reservation_arn {}
      column: total_reserved_usage_amount_temp {}
      column: max_reservation_rate {}
      column: max_reserved_units {}
      column: month_select {}
      column: bill_invoiceid {}
      filters: {
        field: aws_billing_table.ri_line_item
        value: "Yes"
      }
      filters: {
        field: aws_billing_table.type
        value: "-Tax"
      }
      filters: {
        field: aws_billing_table.reservation_arn
        value: "-NULL,-EMPTY"
      }
      bind_all_filters: no
      bind_filters: {
        from_field: aws_billing_table.invoice_month_filter
        to_field: aws_billing_table.invoice_month_filter
      }
    }
  }
  dimension: month_select {}
  dimension: bill_invoiceid {}
  dimension: ri_reservation_id {
    label: "Reserved Units Reservation Identifier"
  }
  dimension: reservation_arn {
    label: "Reserved Units Reservation Arn"
    primary_key: yes
    description: "When an RI benefit discount is applied to a matching line item of usage, the ARN value in the reservation/ReservationARN column for the initial upfront fees and recurring monthly charges matches the ARN value in the discounted usage line items."
  }
  dimension: total_reserved_usage_amount_temp {
    label: "Total Reserved Usage Amount"
    description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
    value_format: "#,##0"
    type: number
  }
  dimension: max_reservation_rate {
    label: "Reserved Units Max Reservation Rate"
    type: number
  }
  dimension: max_reserved_units {
    label: "Reserved Units Max Reserved Units"
    type: number
  }
  dimension: total_unused_usage_amount {
    label: "Total Unused Usage Amount"
    type: number
    sql: safe_cast(${max_reserved_units} as numeric) - safe_cast(${total_reserved_usage_amount_temp} as numeric);;
    value_format_name: decimal_1
  }
  measure: reservation_rate {
    type: average
    value_format_name: usd
    sql: safe_cast(${max_reservation_rate} as numeric) ;;
    hidden: yes
  }
}
