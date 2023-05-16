view: aws_billing_table {
  derived_table: {
    datagroup_trigger: daily
    partition_keys: ["bill_billing_period_start_date"]
    sql:
      SELECT *, GENERATE_UUID() as pk
      FROM cah_billing.aws_billing_table
      ;;
  }

  dimension: pk {
    sql: ${TABLE}.pk ;;
    primary_key: yes
    hidden: yes
  }

  dimension: month_select {
    type: string
    sql: cast(${billing_period_start_date} as string) ;;
    suggest_explore: month_selection_filter
    suggest_dimension: month_selection_filter.month_select
  }

  dimension: bill_billing_entity {
    view_label: "Billing Info"
    type: string
    hidden: no
    sql: ${TABLE}.bill_billing_entity ;;
  }

  dimension_group: billing_period_end {
    view_label: "Billing Info"
    type: time
    timeframes: [time,date,week,month,year]
    sql: ${TABLE}.bill_billing_period_end_date ;;
  }

  dimension_group: billing_period_start {
    view_label: "Billing Info"
    type: time
    timeframes: [raw,time,date,week,month,month_num,year]
    sql: ${TABLE}.bill_billing_period_start_date ;;
    convert_tz: no
  }

  dimension: billtype {
    label: "Bill Type"
    view_label: "Billing Info"
    type: string
    sql: ${TABLE}.bill_bill_type ;;
  }

  dimension: bill_invoiceid {
    type: string
    hidden: no
    sql: ${TABLE}.bill_invoice_id ;;
  }

  dimension: bill_payeraccountid {
    type: string
    view_label: "Billing Info"
    hidden: no
    sql: ${TABLE}.bill_payer_account_id ;;
  }

  dimension: identity_lineitemid {
    type: string
    hidden: yes
    sql: ${TABLE}.identity_line_item_id ;;
  }

  dimension: identity_timeinterval {
    type: string
    hidden: yes
    sql: ${TABLE}.identity_time_interval ;;
  }

  dimension: lineitem_availabilityzone {
    type: string
    hidden: yes
    sql: ${TABLE}.line_item_availability_zone ;;
  }

  dimension: lineitem_blendedcost {
    hidden: yes
    type: number
    sql: ${TABLE}.line_item_blended_cost ;;
  }

  dimension: blended_rate {
    view_label: "Line Items (Individual Charges)"
    description: "The rate applied to this line item for a consolidated billing account in an organization."
    type: number
    sql: ${TABLE}.line_item_blended_rate ;;
  }

  dimension: lineitem_currencycode {
    label: "Currency Code"
    view_label: "Line Items (Individual Charges)"
    type: string
    sql: ${TABLE}.line_item_currency_code ;;
  }

  dimension: description {
    view_label: "Line Items (Individual Charges)"
    description: "A description of the pricing tier covered by this line item"
    type: string
    sql: ${TABLE}.line_item_line_item_description ;;
  }


#### TYPES OF CHARGES ####

  dimension: type {
    view_label: "Line Items (Individual Charges)"
    description: "Fee is one-time RI expense for all-upfront or partial-upfront. RI Fee is recurring RI expense for partial-upfront and no-upfront RI expenses."
    type: string
    sql: ${TABLE}.line_item_line_item_type ;;
  }

  dimension: type_ri_fee_upfront {
    view_label: "Reserved Units"
    description: "Fee is one-time RI expense for all-upfront or partial-upfront."
    type: string
    sql: CASE WHEN ${type} = 'Fee' THEN 'Fee' ELSE 'Other' END ;;
  }

  dimension: type_ri_fee_on_demand {
    view_label: "Reserved Units"
    description: "RI Fee is recurring RI expense for partial-upfront and no-upfront RI expenses."
    type: string
    sql: CASE WHEN ${type} = 'RIFee' THEN 'RI Fee' ELSE 'Other' END ;;
  }

  dimension: type_discounted_usage {
    view_label: "Reserved Units"
    description: "Describes the instance usage that recieved a matching RI discount benefit. It is added to the bill once a reserved instance experiences usage. Cost will always be zero because it's been accounted for with Fee and RI Fee."
    type: string
    sql: CASE WHEN ${type} = 'DiscountedUsage' THEN 'Discounted Usage' ELSE 'Other' END ;;
  }

  dimension: ri_line_item {
    label: "RI Line Item"
    view_label: "Reserved Units"
    description: "Inlcudes all cost and usage information for Reserved Instances."
    type: yesno
    sql: ${type} = 'DiscountedUsage' or
         ${type} = 'RIFee' or
         ${type} = 'Fee' ;;
  }

  dimension: normalization_factor {
    view_label: "Line Items (Individual Charges)"
    description: "Degree of instance size flexibility provided by RIs"
    type: number
    sql: ${TABLE}.line_item_normalization_factor ;;
  }

  dimension: lineitem_normalizedusageamount {
    hidden: yes
    type: number
    sql: ${TABLE}.line_item_normalized_usage_amount ;;
  }

  dimension: line_item_operation {
    label: "Operation"
    view_label: "Line Items (Individual Charges)"
    type: string
    sql: ${TABLE}.line_item_operation ;;
  }

  dimension: product_code {
    description: "The AWS product/service being used"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.line_item_product_code ;;
  }

  dimension: lineitem_resourceid {
    type: string
    label: "Resource ID"
    hidden: no
    sql: ${TABLE}.line_item_resource_id ;;
    tags: ["aws_resource_id"]
  }


  dimension: lineitem_taxtype {
    label: "Tax Type"
    view_label: "Line Items (Individual Charges)"
    type: string
    sql: ${TABLE}.line_item_tax_type ;;
  }

  dimension: lineitem_unblendedcost {
    type: number
    hidden: yes
    sql: ${TABLE}.line_item_unblended_cost ;;
  }

  dimension: lineitem_netunblendedrate {
    type: number
    hidden: no
    sql: ${TABLE}.line_item_net_unblended_rate ;;
  }

  dimension: lineitem_netunblendedcost {
    type: number
    hidden: no
    sql: ${TABLE}.line_item_net_unblended_cost ;;
  }

  ## Adjusted Cost to accomidate Reservations and Savings Plan usage logic ##

  dimension: adj_unblended_cost {
    type: number
    hidden: no
    sql: case when ${type} in ('EdpDiscount', 'SavingsPlanNegation') then null
              when ${reservation_arn} != '' and ${type} != 'Tax' then ${ri_cost}
              when ${savings_plan_savings_plan_a_r_n} != '' and ${type} not in ('Tax','SavingsPlanRecurringFee') then ${savings_plan_savings_plan_effective_cost}
              when ${savings_plan_savings_plan_a_r_n} != '' and ${type} = 'SavingsPlanRecurringFee' then ${aws_savings_plan_total.total_unused_savings_plan_amount_per_row}
              else ${lineitem_unblendedcost} end;;
  }

  dimension: unblended_rate {
    view_label: "Line Items (Individual Charges)"
    description: "The rate that this line item would have been charged for an unconsolidated account."
    type: number
    sql: ${TABLE}.line_item_unblended_rate ;;
  }

  dimension: lineitem_usageaccountid {
    view_label: "Line Items (Individual Charges)"
    label: "Account ID"
    description: "RIs can span multiple accounts - this dimensions related to usage"
    type: string
    # hidden: yes
    sql: ${TABLE}.line_item_usage_account_id ;;
  }

  dimension: lineitem_usageamount {
    type: number
    hidden: yes
    sql: ${TABLE}.line_item_usage_amount ;;
  }

  dimension: usage_amount_adjusted {
    type: number
    hidden: yes
    description: "Adusted Usage amount to accomidate Reservations"
    sql: case when ${type} = 'RIFee' then ${aws_reservation_total.total_unused_usage_amount} else ${lineitem_usageamount} end ;;
  }

  dimension_group: usage_end {
    view_label: "Line Items (Individual Charges)"
    type: time
    timeframes: [raw, time,time_of_day,hour,date,week,day_of_week,month,month_name,year]
    sql: ${TABLE}.line_item_usage_end_date ;;
  }

  dimension_group: usage_start {
    convert_tz: no
    view_label: "Line Items (Individual Charges)"
    type: time
    timeframes: [raw, time,time_of_day,hour,date,week,day_of_week,day_of_month,month,month_name,year]
    sql: COALESCE(${billing_period_start_raw},${TABLE}.line_item_usage_start_date) ;; # added the above coalesce so that when subtrating RI usage from other accounts it only #applies to the date the RI were purchased
  }

  dimension_group: line_item_usage{
    convert_tz: no
    view_label: "Line Items (Individual Charges)"
    type: time
    timeframes: [raw, time,time_of_day,hour,date,week,day_of_week,day_of_month,month,month_name,year]
    sql: ${TABLE}.line_item_usage_start_date ;;
  }

  dimension: usage_hours {
    view_label: "Line Items (Individual Charges)"
    sql: timestamp_diff(${line_item_usage_raw}, ${usage_start_raw}, HOUR) ;;
    hidden: yes ## hours do not reflect # of CPUs, use Usage Amount measures instead -- James Sutton 05/05/2020
  }

  ## start paste

  dimension: unique {
    hidden: yes
    sql: concat(${lineitem_resourceid},cast(${usage_start_raw} as string),cast(${usage_end_raw} as string)) ;;
  }

  dimension_group: usage {
    timeframes: [hour]
    hidden: yes
    type: duration
    sql_start: ${line_item_usage_raw} ;;
    sql_end: ${usage_end_raw} ;;
  }

  measure: total_uptime_usage {
    group_label: "Uptime"
    type: sum_distinct
    sql: ${hours_usage} ;;
    sql_distinct_key: ${unique} ;;
  }

  measure: max_date {
    hidden: yes
    type: max
    sql: ${usage_end_raw} ;;
  }

  measure: min_date {
    hidden: yes
    type: min
    sql: ${usage_start_raw} ;;
  }

  measure: distinct_resources {
    hidden: yes
    type: count_distinct
    sql: ${lineitem_resourceid} ;;
  }


  measure: available_hours {
    group_label: "Uptime"
    type: number
    sql: TIMESTAMP_DIFF(cast(${max_date} as timestamp),cast(${min_date} as timestamp),HOUR) * ${distinct_resources};;
  }

  measure: uptime {
    group_label: "Uptime"
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${total_uptime_usage} / NULLIF(${available_hours},0) ;;
  }

  ## end paste

  measure: total_usage_hours {
    view_label: "Billing Info"
    type: sum
    sql: ${usage_hours} ;;
    hidden: yes  ## hours do not reflect # of CPUs, use Usage Amount measures instead -- James Sutton 05/05/2020
  }

  measure: total_on_demand_usage_hours {
    view_label: "Billing Info"
    type: sum
    sql: ${usage_hours} ;;
    filters: {
      field: ri_line_item
      value: "No"
    }
    hidden: yes ## hours do not reflect # of CPUs, use Usage Amount measures instead -- James Sutton 05/05/2020
  }

  measure: total_reserved_usage_hours {
    view_label: "Billing Info"
    type: sum
    sql: ${usage_hours} ;;
    filters: {
      field: ri_line_item
      value: "Yes"
    }
    hidden: yes ## hours do not reflect # of CPUs, use Usage Amount measures instead -- James Sutton 05/05/2020
  }

  dimension: lineitem_usagetype {
    label: "Usage Type"
    view_label: "Line Items (Individual Charges)"
    description: "The type of usage covered by this line item. If you paid for a Reserved Instance, the report has one line that shows the monthly committed cost, and multiple lines that show a charge of 0."
    type: string
    sql: ${TABLE}.line_item_usage_type ;;
  }

  dimension: product_accountassistance {
    label: "Account Assistance"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_account_assistance ;;
  }

  dimension: product_architecturalreview {
    label: "Architecture Review"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_architectural_review ;;
  }

  dimension: product_architecturesupport {
    label: "Architecture Support"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_architecture_support ;;
  }

  dimension: product_availability {
    label: "Availability"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_availability ;;
  }

  dimension: product_bestpractices {
    hidden: yes
    type: string
    sql: ${TABLE}.product_best_practices ;;
  }

  dimension: product_cacheengine {
    hidden: yes
    type: string
    sql: ${TABLE}.product_cache_engine ;;
  }

  dimension: product_caseseverityresponsetimes {
    hidden: yes
    type: string
    sql: ${TABLE}.product_case_severity_response_times ;;
  }

  dimension: product_clockspeed {
    hidden: yes
    type: string
    sql: ${TABLE}.product_clock_speed ;;
  }

  dimension: product_currentgeneration {
    hidden: yes
    type: string
    sql: ${TABLE}.product_current_generation ;;
  }

  dimension: product_customerserviceandcommunities {
    hidden: yes
    type: string
    sql: ${TABLE}.product_customer_service_and_communities ;;
  }

  dimension: product_databaseedition {
    label: "Database Edition"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_data_base_edition ;;
  }

  dimension: product_databaseengine {
    label: "Database Engine"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_database_engine ;;
  }

  dimension: product_dedicatedebsthroughput {
    label: "Dedicated EBS Throughput"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_dedicated_ebs_throughput ;;
  }

  dimension: product_deploymentoption {
    view_label: "Product Info"
    hidden: yes
    type: string
    sql: ${TABLE}.product_deployment_option ;;
  }

  dimension: product_description {
    label: "Description"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_description ;;
  }

  dimension: product_durability {
    label: "Durability"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_durability ;;
  }

  dimension: product_ebsoptimized {
    hidden: yes
    type: string
    sql: ${TABLE}.product_ebs_optimized ;;
  }

  dimension: product_ecu {
    hidden: yes
    type: string
    sql: ${TABLE}.product_ecu ;;
  }

  dimension: endpoint_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_endpoint_type ;;
  }

  dimension: engine_code {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_engine_code ;;
  }

  dimension: product_enhancednetworkingsupported {
    view_label: "Product Info"
    hidden: yes
    type: string
    sql: ${TABLE}.product_enhanced_networking_supported ;;
  }

  dimension: execution_frequency {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_execution_frequency ;;
  }

  dimension: execution_location {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_execution_location ;;
  }

  dimension: product_feecode {
    type: string
    hidden: yes
    sql: ${TABLE}.product_fee_code ;;
  }

  dimension: product_feedescription {
    type: string
    hidden: yes
    sql: ${TABLE}.product_fee_description ;;
  }

  dimension: product_freequerytypes {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_free_query_types ;;
  }

  dimension: free_trial {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_free_trial ;;
  }

  dimension: product_frequencymode {
    hidden: yes
    type: string
    sql: ${TABLE}.product_frequency_mode ;;
  }

  dimension: from_location {
    view_label: "Product Info"
    type: string
#     map_layer_name: countries
    sql: ${TABLE}.product_from_location ;;
  }

  dimension: from_location_viz {
    view_label: "Product Info"
    description: "Should ONLY be used for visualization purposes"
    type: location
    sql_latitude: ${from_location_lat} ;;
    sql_longitude: ${from_location_long} ;;
  }

  dimension: to_location_viz {
    view_label: "Product Info"
    description: "Should ONLY be used for visualization purposes"
    type: location
    sql_latitude: ${to_location_lat} ;;
    sql_longitude: ${to_location_long} ;;
  }


  dimension: from_location_lat {
    hidden: yes
    type: string
    sql: CASE
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Mumbai)' THEN '19.075984'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Seoul)' THEN '37.566535'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Singapore)' THEN '1.352083'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Sydney)' THEN '-33.868820'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Tokyo)' THEN '35.689487'
        WHEN ${TABLE}.product_from_location = 'Australia' THEN '-25.274398'
        WHEN ${TABLE}.product_from_location = 'Canada' THEN '56.130366'
        WHEN ${TABLE}.product_from_location = 'Canada (Central)' THEN '56.130366'
        WHEN ${TABLE}.product_from_location = 'EU (Frankfurt)' THEN '50.110922'
        WHEN ${TABLE}.product_from_location = 'EU (Ireland)' THEN '53.142367'
        WHEN ${TABLE}.product_from_location = 'India' THEN '20.593684'
        WHEN ${TABLE}.product_from_location = 'Japan' THEN '36.204824'
        WHEN ${TABLE}.product_from_location = 'South America (Sao Paulo)' THEN '-23.550520'
        WHEN ${TABLE}.product_from_location = 'South America' THEN '-23.550520'
        WHEN ${TABLE}.product_from_location = 'US East (N. Virginia)' THEN '37.431573'
        WHEN ${TABLE}.product_from_location = 'US East (Ohio)' THEN '40.417287'
        WHEN ${TABLE}.product_from_location = 'US West (N. California)' THEN '38.837522'
        WHEN ${TABLE}.product_from_location = 'US WEST (Oregon)' THEN '43.804133'
        ELSE 'Not labeled'
        END
        ;;
  }

  dimension: from_location_long {
    hidden: yes
    type: string
    sql: CASE
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Mumbai)' THEN '72.877656'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Seoul)' THEN '126.977969'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Singapore)' THEN '103.819836'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Sydney)' THEN '151.209296'
        WHEN ${TABLE}.product_from_location = 'Asia Pacific (Tokyo)' THEN '139.691706'
        WHEN ${TABLE}.product_from_location = 'Australia' THEN '133.775136'
        WHEN ${TABLE}.product_from_location = 'Canada' THEN '-106.346771'
        WHEN ${TABLE}.product_from_location = 'Canada (Central)' THEN '-106.346771'
        WHEN ${TABLE}.product_from_location = 'EU (Frankfurt)' THEN '8.682127'
        WHEN ${TABLE}.product_from_location = 'EU (Ireland)' THEN '-7.692054'
        WHEN ${TABLE}.product_from_location = 'India' THEN '78.962880'
        WHEN ${TABLE}.product_from_location = 'Japan' THEN '138.252924'
        WHEN ${TABLE}.product_from_location = 'South America (Sao Paulo)' THEN '-46.633309'
        WHEN ${TABLE}.product_from_location = 'South America' THEN '-46.633309'
        WHEN ${TABLE}.product_from_location = 'US East (N. Virginia)' THEN '-78.656894'
        WHEN ${TABLE}.product_from_location = 'US East (Ohio)' THEN '-82.907123'
        WHEN ${TABLE}.product_from_location = 'US West (N. California)' THEN '-120.895824'
        WHEN ${TABLE}.product_from_location = 'US West (Oregon)' THEN '-120.554201'
        ELSE 'Not labeled'
        END
        ;;
  }


  dimension: to_location_lat {
    hidden: yes
    type: string
    sql: CASE
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Mumbai)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Mumbai)' THEN '19.075984'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Seoul)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Seoul)' THEN '37.566535'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Singapore)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Singapore)' THEN '1.352083'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Sydney)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Sydney)' THEN '-33.868820'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Tokyo)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Tokyo)' THEN '35.689487'
          WHEN ${TABLE}.product_to_location = 'Australia' OR ${TABLE}.product_to_location_type = 'Australia' THEN '-25.274398'
          WHEN ${TABLE}.product_to_location = 'Canada' OR ${TABLE}.product_to_location_type = 'Canada' THEN '56.130366'
          WHEN ${TABLE}.product_to_location = 'Canada (Central)' OR ${TABLE}.product_to_location_type = 'Canada (Central)' THEN '56.130366'
          WHEN ${TABLE}.product_to_location = 'EU (Frankfurt)' OR ${TABLE}.product_to_location_type = 'EU (Frankfurt)' THEN '50.110922'
          WHEN ${TABLE}.product_to_location = 'EU (Ireland)' OR ${TABLE}.product_to_location_type = 'EU (Ireland)' THEN '53.142367'
          WHEN ${TABLE}.product_to_location = 'India' OR ${TABLE}.product_to_location_type = 'India' THEN  '20.593684'
          WHEN ${TABLE}.product_to_location = 'Japan' OR ${TABLE}.product_to_location_type = 'Japan' THEN '36.204824'
          WHEN ${TABLE}.product_to_location = 'South America (Sao Paulo)' OR ${TABLE}.product_to_location_type = 'South America (Sao Paulo)' THEN '-23.550520'
          WHEN ${TABLE}.product_to_location = 'South America' OR ${TABLE}.product_to_location_type = 'South America' THEN  '-23.550520'
          WHEN ${TABLE}.product_to_location = 'US East (N. Virginia)' OR ${TABLE}.product_to_location_type = 'US East (N. Virginia)' THEN '37.431573'
          WHEN ${TABLE}.product_to_location = 'US East (Ohio)' OR ${TABLE}.product_to_location_type = 'US East (Ohio)' THEN '40.417287'
          WHEN ${TABLE}.product_to_location = 'US West (N. California)' OR ${TABLE}.product_to_location_type = 'US West (N. California)' THEN '38.837522'
          WHEN ${TABLE}.product_to_location = 'US WEST (Oregon)' OR ${TABLE}.product_to_location_type = 'US WEST (Oregon)' THEN '43.804133'
          ELSE 'Not labeled'
          END
              ;;
  }

  dimension: to_location_long {
    description: "Should ONLY be used for visualization purposes"
    hidden: yes
    type: string
    sql: CASE
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Mumbai)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Mumbai)' THEN '72.877656'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Seoul)' OR  ${TABLE}.product_to_location_type = 'Asia Pacific (Seoul)' THEN '126.977969'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Singapore)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Singapore)' THEN '103.819836'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Sydney)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Sydney)' THEN '151.209296'
          WHEN ${TABLE}.product_to_location = 'Asia Pacific (Tokyo)' OR ${TABLE}.product_to_location_type = 'Asia Pacific (Tokyo)' THEN '139.691706'
          WHEN ${TABLE}.product_to_location = 'Australia' OR ${TABLE}.product_to_location_type = 'Australia' THEN '133.775136'
          WHEN ${TABLE}.product_to_location = 'Canada' OR ${TABLE}.product_to_location_type  = 'Canada' THEN  '-106.346771'
          WHEN ${TABLE}.product_to_location = 'Canada (Central)' OR ${TABLE}.product_to_location_type = 'Canada (Central)' THEN '-106.346771'
          WHEN ${TABLE}.product_to_location = 'EU (Frankfurt)' OR ${TABLE}.product_to_location_type = 'EU (Frankfurt)' THEN '8.682127'
          WHEN ${TABLE}.product_to_location = 'EU (Ireland)' OR ${TABLE}.product_to_location_type = 'EU (Ireland)' THEN '-7.692054'
          WHEN ${TABLE}.product_to_location = 'India' OR ${TABLE}.product_to_location_type = 'India' THEN '78.962880'
          WHEN ${TABLE}.product_to_location = 'Japan' OR ${TABLE}.product_to_location_type = 'Japan' THEN '138.252924'
          WHEN ${TABLE}.product_to_location = 'South America (Sao Paulo)' OR ${TABLE}.product_to_location_type = 'South America (Sao Paulo)' THEN '-46.633309'
          WHEN ${TABLE}.product_to_location = 'South America' OR ${TABLE}.product_to_location_type = 'South America' THEN '-46.633309'
          WHEN ${TABLE}.product_to_location = 'US East (N. Virginia)' OR ${TABLE}.product_to_location_type = 'US East (N. Virginia)' THEN '-78.656894'
          WHEN ${TABLE}.product_to_location = 'US East (Ohio)' OR ${TABLE}.product_to_location_type = 'US East (Ohio)' THEN '-82.907123'
          WHEN ${TABLE}.product_to_location = 'US West (N. California)' OR ${TABLE}.product_to_location_type = 'US West (N. California)' THEN '-120.895824'
          WHEN ${TABLE}.product_to_location = 'US West (Oregon)' OR ${TABLE}.product_to_location_type = 'US West (Oregon)' THEN '-120.554201'
          ELSE 'Not labeled'
          END
              ;;
  }

  dimension: from_location_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_from_location_type ;;
  }

  dimension: product_group {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_group ;;
  }

  dimension: group_description {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_group_description ;;
  }

  dimension: product_includedservices {
    hidden: yes
    type: string
    sql: ${TABLE}.product_included_services ;;
  }

  dimension: product_instancefamily {
    type: string
    hidden: yes
    sql: ${TABLE}.product_instance_family ;;
  }

  dimension: instance_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_instance_type ;;
  }

  dimension: product_io {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_io ;;
  }

  dimension: product_launchsupport {
    hidden: yes
    type: string
    sql: ${TABLE}.product_launch_support ;;
  }

  dimension: product_licensemodel {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_license_model ;;
  }

  dimension: location {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_location ;;
  }

  dimension: location_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_location_type ;;
  }

  dimension: product_maximumstoragevolume {
    hidden: yes
    type: string
    sql: ${TABLE}.product_maximum_storage_volume ;;
  }

  dimension: product_maxiopsburstperformance {
    hidden: yes
    type: string
    sql: ${TABLE}.product_max_iops_burst_performance ;;
  }

  dimension: product_maxiopsvolume {
    hidden: yes
    type: string
    sql: ${TABLE}.product_max_iops_volume ;;
  }

  dimension: max_throughput_volume {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_max_throughput_volume ;;
  }

  dimension: product_maxvolumesize {
    type: string
    hidden: yes
    sql: ${TABLE}.product_max_volume_size ;;
  }

  dimension: year {
    type: string
    sql: ${TABLE}.year ;;
  }

  dimension: month {
    type: string
    sql: CONCAT(CAST(${billing_period_start_year} as string),CAST(${billing_period_start_month_num} as string)) ;;
  }

  dimension: product_memory {
    type: string
    view_label: "Product Info"
    sql: ${TABLE}.product_memory ;;
  }

  dimension: product_messagedeliveryfrequency {
    type: string
    hidden: yes
    sql: ${TABLE}.product_message_delivery_frequency ;;
  }

  dimension: product_messagedeliveryorder {
    type: string
    hidden: yes
    sql: ${TABLE}.product_message_delivery_order ;;
  }

  dimension: product_minimumstoragevolume {
    type: string
    hidden: yes
    sql: ${TABLE}.product_minimum_storage_volume ;;
  }

  dimension: product_minvolumesize {
    hidden: yes
    type: string
    sql: ${TABLE}.product_min_volume_size ;;
  }

  dimension: network_performance {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_network_performance ;;
  }

  dimension: operating_system {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_operating_system ;;
  }

  dimension: product_operation {
    label: "Operation"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_operation ;;
  }

  dimension: product_operationssupport {
    type: string
    hidden: yes
    sql: ${TABLE}.product_operations_support ;;
  }

  dimension: product_physicalprocessor {
    type: string
    hidden: yes
    sql: ${TABLE}.product_physical_processor ;;
  }

  dimension: product_preinstalledsw {
    type: string
    hidden: yes
    sql: ${TABLE}.product_pre_installed_sw ;;
  }

  dimension: product_proactiveguidance {
    type: string
    hidden: yes
    sql: ${TABLE}.product_proactive_guidance ;;
  }

  dimension: product_processorarchitecture {
    type: string
    hidden: yes
    sql: ${TABLE}.product_processor_architecture ;;
  }

  dimension: product_processor_features {
    type: string
    hidden: yes
    sql: ${TABLE}.product_processor_features ;;
  }

  dimension: productfamily {
    label: "Family"
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_product_family ;;
  }

  dimension: product_name {
    type: string
    description: "Innaccurate labeling on part of AWS - use product code instead"
    view_label: "Product Info"
    sql: ${TABLE}.product_product_name ;; ##### Innaccurate labeling on part of AWS - use product code instead ####
  }

  dimension: product_programmaticcasemanagement {
    hidden: yes
    type: string
    sql: ${TABLE}.product_programmatic_case_management ;;
  }

  dimension: product_provisioned {
    hidden: yes
    type: string
    sql: ${TABLE}.product_provisioned ;;
  }

  dimension: product_queuetype {
    hidden: yes
    type: string
    sql: ${TABLE}.product_queue_type ;;
  }

  dimension: product_requestdescription {
    hidden: yes
    type: string
    sql: ${TABLE}.product_request_description ;;
  }

  dimension: product_requesttype {
    hidden: yes
    type: string
    sql: ${TABLE}.product_request_type ;;
  }

  dimension: product_routingtarget {
    hidden: yes
    type: string
    sql: ${TABLE}.product_routing_target ;;
  }

  dimension: product_routingtype {
    hidden: yes
    type: string
    sql: ${TABLE}.product_routing_type ;;
  }

  dimension: product_servicecode {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_servicecode ;;
  }

  dimension: product_sku {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_sku ;;
  }

  dimension: product_softwaretype {
    hidden: yes
    type: string
    sql: ${TABLE}.product_software_type ;;
  }

  dimension: product_storage {
    hidden: yes
    type: string
    sql: ${TABLE}.product_storage ;;
  }

  dimension: product_storageclass {
    hidden: yes
    type: string
    sql: ${TABLE}.product_storage_class ;;
  }

  dimension: product_storagemedia {
    hidden: yes
    type: string
    sql: ${TABLE}.product_storage_media ;;
  }

  dimension: product_technicalsupport {
    hidden: yes
    type: string
    sql: ${TABLE}.product_technical_support ;;
  }

  dimension: tenancy {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_tenancy ;;
  }

  dimension: product_thirdpartysoftwaresupport {
    hidden: yes
    type: string
    sql: ${TABLE}.product_third_party_software_support ;;
  }

  dimension: to_location {
    view_label: "Product Info"
#     map_layer_name: countries
    type: string
    sql: ${TABLE}.product_to_location ;;
  }

  dimension: to_location_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_to_location_type ;;
  }

  dimension: training {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_training ;;
  }

  dimension: transfer_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_transfer_type ;;
  }

  dimension: usage_family {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_usage_family ;;
  }

  dimension: data_transfer {
    view_label: "Line Items (Individual Charges)"
    type: yesno
    sql: REGEXP_LIKE(${usage_type}, 'DataTransfer')   ;;
  }

  dimension: data_transfer_outbound {
    view_label: "Line Items (Individual Charges)"
    type: yesno
    sql: REGEXP_LIKE(${usage_type}, 'DataTransfer-Out')   ;;
  }

  dimension: data_transfer_inbound {
    view_label: "Line Items (Individual Charges)"
    type: yesno
    sql: REGEXP_LIKE(${usage_type}, 'DataTransfer-In')   ;;
  }

  dimension: usage_type {
    view_label: "Product Info"
    type: string
    sql: ${TABLE}.product_usagetype ;;
  }

  dimension: product_vcpu {
    hidden: yes
    type: string
    sql: ${TABLE}.product_vcpu ;;
  }

  dimension: product_version {
    hidden: yes
    type: string
    sql: ${TABLE}.product_version ;;
  }

  dimension: product_volumetype {
    type: string
    hidden: yes
    sql: ${TABLE}.product_volume_type ;;
  }

  dimension: product_whocanopencases {
    hidden: yes
    type: string
    sql: ${TABLE}.product_who_can_open_cases ;;
  }

  dimension: pricing_leasecontractlength {
    hidden: yes
    type: string
    sql: ${TABLE}.pricing_lease_contract_length ;;
  }

  dimension: pricing_offeringclass {
    hidden: yes
    type: string
    sql: ${TABLE}.product_storage_class ;;
  }

  dimension: pricing_purchaseoption {
    hidden: yes
    type: string
    sql: ${TABLE}.pricing_purchase_option ;;
  }

  dimension: pricing_publicondemandcost {
    view_label: "Added Fields"
    type: string
    sql: ${TABLE}.pricing_public_on_demand_cost ;;
  }

  dimension: pricing_publicondemandrate {
    view_label: "Added Fields"
    type: string
    sql: ${TABLE}.pricing_public_on_demand_rate ;;
  }

  dimension: pricing_term {
    hidden: yes
    type: string
    sql: ${TABLE}.pricing_term ;;
  }

  dimension: pricing_unit {
    hidden: yes
    type: string
    sql: ${TABLE}.pricing_unit ;;
  }





## Reservervations Dimensions and Measures ##


  dimension: reservation_availabilityzone {
    hidden: yes
    type: string
    sql: ${TABLE}.reservation_availability_zone ;;
  }

  dimension: reservation_unitsperreservation {
    type: string
    view_label: "Reserved Units"
    hidden: no
    sql: cast(NULLIF(${TABLE}.reservation_normalized_units_per_reservation,'') as numeric) ;;
  }

  dimension: reservation_numberofreservations {
    type: number
    view_label: "Reserved Units"
    hidden: yes  ## Not sure of source, doesn't seem to be accurate at a by reservation level - James Sutton 05/05/2020
    sql: cast(NULLIF(${TABLE}.reservation_number_of_reservations,'') as numeric) ;;
  }

  dimension: reservation_arn {
    view_label: "Reserved Units"
    description: "When an RI benefit discount is applied to a matching line item of usage, the ARN value in the reservation/ReservationARN column for the initial upfront fees and recurring monthly charges matches the ARN value in the discounted usage line items."
    type: string
    sql: ${TABLE}.reservation_reservation_a_r_n ;;
  }

  dimension: ri_reservation_id {
    type: string
    view_label: "Reserved Units"
    label: "Reservation Identifier"
    sql: substr(substr(${reservation_arn},strpos(${reservation_arn},'instances/')),11) ;;
  }

  dimension: ri_cost {
    type: number
    view_label: "Reserved Units"
    hidden: yes
    sql: safe_cast(${aws_reservation_total.max_reservation_rate} as numeric) * safe_cast(${usage_amount_adjusted} as numeric) ;;
  }

  measure: total_ri_cost {
    value_format_name: usd
    type: number
    sql: ${total_reserved_usage_amount}*${aws_reservation_total.reservation_rate} ;;
    view_label: "Reserved Units"
  }

  dimension: reservation_totalreservednormalizedunits {
    hidden: yes
    type: number
    sql:cast(nullif(${TABLE}.reservation_total_reserved_normalized_units, '') as numeric) ;;
  }

  dimension: reservation_totalreservedunits {
    view_label: "Added Fields"
    description: "The total number of total number of hours across all reserved instances in the subscription."
    type: number
    sql: ${TABLE}.reservation_total_reserved_units ;;
  }

  dimension: reservation_amortizedupfrontcostforusage {
    view_label: "Added Fields"
    description: "The total number of total number of hours across all reserved instances in the subscription."
    type: number
    hidden: no
    sql: ${TABLE}.reservation_amortized_upfront_cost_for_usage ;;
  }

  dimension: reservation_amortizedupfrontfeeforbillingperiod {
    view_label: "Reserved Units"
    description: "The total number of total number of hours across all reserved instances in the subscription."
    type: number
    hidden: no
    sql: ${TABLE}.reservation_amortized_upfront_fee_for_billing_period ;;
  }

  dimension: reservation_effectivecost {
    view_label: "Reserved Units"
    description: "The total number of total number of hours across all reserved instances in the subscription."
    type: number
    hidden: no
    sql: ${TABLE}.reservation_effective_cost ;; ## Why is this not consistant across line items within the same reservation?  James Sutton
  }

  dimension: reservation_recurringfeeforusage {
    view_label: "Reserved Units"
    description: "The total number of total number of hours across all reserved instances in the subscription."
    type: number
    hidden: no
    sql: ${TABLE}.reservation_recurring_fee_for_usage ;;
  }


### RESERVED UNIT AGGREGATIONS ###

  measure: number_of_reservations {
    view_label: "Reserved Units"
    description: "The number of reservations covered by this subscription. For example, one Reserved Instance (RI) subscription may have four associated RI reservations."
    type: count_distinct
    sql: ${reservation_arn} ;; ## Changing to count number of reservation_id to resolve data integrity issue - James Sutton 05/05/2020
    drill_fields: [common*, number_of_reservations, total_measures*]
  }

  measure: max_reservation_rate {  ## Used in aws_reservation_total NDT
    hidden: yes
    sql: ${unblended_rate} ;;
    type: max
    view_label: "Reserved Units"
  }

  measure: max_reserved_units { ## Used in aws_reservation_total NDT
    hidden: yes
    sql: ${reservation_totalreservedunits} ;;
    type: max
    view_label: "Reserved Units"
  }



## EDP & Savings Plan ##

  dimension: discount_edp_discount {
    sql: ${TABLE}.discount_edp_discount ;;
    type: number
    value_format_name: usd
    view_label: "Savings Plans"
    label: "EDP Discount - Raw"
    description: "EDP discount as it appears in the billing file"
  }

  dimension: non_savings_plan_usage_edp_discount {
    sql: case when ${type} = 'SavingsPlanRecurringFee' then ${aws_savings_plan_total.total_unused_edp_discount_per_row}
              when ${savings_plan_savings_plan_a_r_n} = '' then ${discount_edp_discount}
          else null end ;;
    hidden: yes
  }

  dimension: non_sp_edp_discount {
    hidden: yes
    description: "EDP discounts for SKUs other than Savings Plans"
    sql: case when ${savings_plan_savings_plan_a_r_n} = '' then ${discount_edp_discount} else null end ;;
    type: number
  }

  dimension: discount_total_discount {
    sql: ${TABLE}.discount_total_discount ;;
    type: number
    value_format_name: usd
    view_label: "Savings Plans"
  }

  dimension: savings_plan_total_commitment_to_date {
    sql: ${TABLE}.savings_plan_total_commitment_to_date ;;
    type: number
    view_label: "Savings Plans"
  }

  dimension: savings_plan_savings_plan_a_r_n {
    sql: ${TABLE}.savings_plan_savings_plan_a_r_n ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_savings_plan_rate {
    sql: ${TABLE}.savings_plan_savings_plan_rate ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_used_commitment {
    sql: ${TABLE}.savings_plan_used_commitment ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_savings_plan_effective_cost {
    sql: ${TABLE}.savings_plan_savings_plan_effective_cost ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_amortized_upfront_commitment_for_billing_period {
    sql: ${TABLE}.savings_plan_amortized_upfront_commitment_for_billing_period ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_recurring_commitment_for_billing_period {
    sql: ${TABLE}.savings_plan_recurring_commitment_for_billing_period ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_net_savings_plan_effective_cost {
    sql: ${TABLE}.savings_plan_net_savings_plan_effective_cost ;;
    type: number
    view_label: "Savings Plans"
  }

  dimension: savings_plan_net_amortized_upfront_commitment_for_billing_period {
    sql: ${TABLE}.savings_plan_net_amortized_upfront_commitment_for_billing_period ;;
    type: number
    view_label: "Savings Plans"
  }

  dimension: savings_plan_net_recurring_commitment_for_billing_period {
    sql: ${TABLE}.savings_plan_net_recurring_commitment_for_billing_period ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_purchase_term {
    sql: ${TABLE}.savings_plan_purchase_term ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_payment_option {
    sql: ${TABLE}.savings_plan_payment_option ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_offering_type {
    sql: ${TABLE}.savings_plan_offering_type ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_region {
    sql: ${TABLE}.savings_plan_region ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_start_time {
    sql: ${TABLE}.savings_plan_start_time ;;
    type: string
    view_label: "Savings Plans"
  }

  dimension: savings_plan_end_time {
    sql: ${TABLE}.savings_plan_end_time ;;
    type: string
    view_label: "Savings Plans"
  }

  measure: total_edp_discount_amt {
    type: sum
    view_label: "Savings Plans"
    label: "Total EDP Discount - Raw"
    sql: ${discount_edp_discount};;
    value_format_name: usd_0
  }

  measure: total_savings_plan_effective_cost {
    type: sum
    view_label: "Savings Plans"
    sql: ${savings_plan_savings_plan_effective_cost} ;;
    value_format_name: usd_0
    description: "Total Savings Plan Effective Cost - Prior to EDP Discount"
  }

  measure: total_savings_plan_net_cost {
    sql: ${savings_plan_net_savings_plan_effective_cost} ;;
    type: sum
    value_format_name: usd_0
    description: "Total Savings Plan Net Cost - After EDP Discount"
    view_label: "Savings Plans"
  }

  measure: total_unused_savings_plan_amount {
    type: number
    sql: ${total_unblened_cost_raw_no_edp} - ${total_savings_plan_effective_cost}  ;;
    value_format_name: usd_0
    view_label: "Savings Plans"
  }

  measure: total_usage_savings_plan_edp_discount {
    type: number
    sql: (${total_savings_plan_effective_cost} - ${total_savings_plan_net_cost}) * -1 ;;
    description: "Difference between total savings plan effective costs and total net costs"
    value_format_name: usd_0
    view_label: "Savings Plans"
    hidden: yes
  }

  measure: total_unused_savings_plan_edp_discount {
    type: number
    sql: ${total_edp_discount_amt} - ${total_usage_savings_plan_edp_discount} ;;
    value_format_name: usd_0
    view_label: "Savings Plans"
    hidden: yes
  }

  measure: total_savings_plan_recurring_fee_rows {
    hidden: yes
    type: count_distinct
    sql: ${pk} ;;
    filters: [type: "SavingsPlanRecurringFee"]
  }

  measure: total_unused_savings_plan_amount_per_row {
    hidden: yes
    sql: ${total_unused_savings_plan_amount} / nullif(${total_savings_plan_recurring_fee_rows},0) ;;
    view_label: "Savings Plans"
  }

  measure: total_unused_edp_discount_per_row {
    hidden: yes
    sql: ${total_unused_savings_plan_edp_discount} / nullif(${total_savings_plan_recurring_fee_rows},0) ;;
    view_label: "Savings Plans"
  }


  ### ENABLE FOR CUSTOM TAGS ###

  dimension: user_name {
    view_label: "Custom Resource Tagging"
    type: string
    sql: ${TABLE}.resource_tags_user_name ;;
  }

  dimension: cost_center_raw {
    view_label: "Custom Resource Tagging"
    hidden: yes
    type: string
    sql:
    CASE  WHEN UPPER(${description}) like 'TAX FOR PRODUCT CODE%' THEN 'Sales Tax Allocation'
    WHEN ${product_code} = 'OCBPremiumSupport' THEN 'Support Allocation'
    WHEN UPPER(${product_name}) = 'CORNERSTONE MFT SERVER - CLOUD EDITION' THEN '1120000208'
    WHEN UPPER(${product_name}) ='CLOUD MANAGER - DEPLOY & MANAGE NETAPP CLOUD DATA SERVICES' THEN '1120000174'
    WHEN UPPER(${product_name}) = 'TREND MICRO DEEP SECURITY AS A SERVICE' THEN 'shared-security'
    WHEN UPPER(${product_name}) = 'CLOUD VOLUMES FOR AWS 1TB - STANDARD PERFORMANCE TIER - MONTHLY' AND UPPER(${description}) = 'AWS MARKETPLACE CONTRACT RENEWAL' THEN 'shared-cloud infrastructure'
    WHEN substr(${TABLE}.resource_tags_user_costcenter,1,10) = '112000163' THEN '1120000163'
    WHEN substr(${TABLE}.resource_tags_user_costcenter,1,10) = '112000206' THEN '1120000206'
    ELSE if(trim(${TABLE}.resource_tags_user_costcenter) = '',null,substr(${TABLE}.resource_tags_user_costcenter,1,10)) END
    ;;
  }

  dimension: cost_center_raw_2 {
    type: string
    sql: ${TABLE}.resource_tags_user_costcenter ;;
    hidden: no
    view_label: "Custom Resource Tagging"
    description: "Cost Center tagged in raw data (no normalization), retagging, or logic changes."
  }

  dimension: cost_center {
    view_label: "Custom Resource Tagging"
    type: string
    sql: COALESCE(${account_mapping.cost_center},
                  ${cost_center_raw},
                  ${costcenter_lkup.costcenter},
                  IF(${lineitem_usageaccountid} in ('043694018499','593708024695','969667464637','167977214020','420689522072'), 'shared-cloud infrastructure',null),
                  'shared-cloud infrastructure')
                  ;;
  }

  dimension: cost_center_final {
    view_label: "Custom Resource Tagging"
    type: string
    description: "Final cost center logic, where detailed shared cost centers are reallocated to 1120000185"
    sql: case when ${cost_center} in ('Sales Tax Allocation','Shared-Clo','Support Allocation','shared-clo','shared-cloud infrastructure','shared-sec','shared-security') then '1120000185' else ${cost_center} end;;
  }

  dimension: cost_center_1to1 {
    type: yesno
    sql: ${account_mapping.cost_center} is not null ;;
    view_label: "Custom Resource Tagging"
    description: "Cost Center has a 1 to one relationship with Account ID and Name -- Using Cost Center associated with Account Mapping Table"
  }

  dimension: cost_center_tax_spread_qualifier {
    type: string
    # sql: case when (define what cost centers qualify to spread out costs
    view_label: "Custom Resource Tagging"
    description: "Identifies if costs are considered in the % distribution of tax costs"
  }

  dimension: cost_center_support_spread_qualifier {
    type: string
    # sql: case when (define what cost centers qualify to spread out costs
    view_label: "Custom Resource Tagging"
    description: "Identifies if costs are considered in the % distribution of support costs"
  }

  measure: total_tax_qualified_cost {
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: [cost_center_tax_spread_qualifier: "Yes"]
    view_label: "Custom Resource Tagging"
    value_format_name: usd
    hidden: yes
  }

  measure: total_support_qualified_cost {
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: [cost_center_support_spread_qualifier: "Yes"]
    view_label: "Custom Resource Tagging"
    value_format_name: usd
    hidden: yes
  }

  measure: total_shared_support_cost {
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: [product_code: "OCBPremiumSupport"]
    view_label: "Custom Resource Tagging"
    value_format_name: usd
    hidden: yes
  }

  measure: total_shared_tax_cost {
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: [cost_center: "Sales Tax Allocation"]
    view_label: "Custom Resource Tagging"
    value_format_name: usd
    hidden: yes
  }

  measure: total_non_shared_support_tax_cost {
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: [cost_center: "-Sales Tax Allocation", product_code: "-OCBPremiumSupport"]
    view_label: "Custom Resource Tagging"
    value_format_name: usd
    hidden: yes
  }

  dimension: apmid {
    view_label: "Custom Resource Tagging"
    type: string
    sql: ${TABLE}.resource_tags_user_apmid ;;
  }

  dimension: application {
    view_label: "Custom Resource Tagging"
    type: string
    sql: ${TABLE}.resource_tags_user_application ;;
  }

  dimension: appid {
    view_label: "Custom Resource Tagging"
    type: string
    sql: ${TABLE}.resource_tags_user_appid ;;
  }

  dimension: environment_raw {
    view_label: "Custom Resource Tagging"
    type: string
    sql: ${TABLE}.resource_tags_user_environment ;;
  }

  dimension: environment_clean {
    description: "The environment values standardized. EX: prod and production both become Production"
    label: "Environment"
    case: {
      when: {
        label: "Production"
        sql: lower(${environment_raw}) in ('production','prod') ;;
      }
      when: {
        label: "Staging"
        sql: lower(${environment_raw}) in ('stage','stg') ;;
      }
      when: {
        label: "Development"
        sql: lower(${environment_raw}) in ('development','dev') ;;
      }
      else: "Other Non-Production"
    }
    type: string
    sql: ${environment_raw} ;;
  }

  dimension: project_name {
    view_label: "Custom Resource Tagging"
    type: string
    sql: ${TABLE}.resource_tags_user_project_name ;;
  }

  dimension: startstop {
    hidden: yes
    type: string
    sql: split(${TABLE}.resource_tags_user_scheduler_ec2_startstop,';') ;;
  }

  measure: tagged_percentage {
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_of_tagged} / NULLIF(${total_count},0) ;;
  }

  measure: total_count {
    label: "Total"
    group_label: "Counts"
    type: count
  }

  measure: total_cost {
    group_label: "Costs"
    label: "Total"
    value_format_name: usd
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
  }

  measure: count_of_tagged {
    group_label: "Counts"
    label: "Tagged"
    type: count
    filters: {
      field: is_tagged
      value: "Yes"
    }
  }

  measure: cost_of_tagged {
    group_label: "Costs"
    label: "Tagged"
    value_format_name: usd
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: {
      field: is_tagged
      value: "Yes"
    }
  }

  measure: count_of_untagged {
    group_label: "Counts"
    label: "Untagged"
    type: count
    filters: {
      field: is_tagged
      value: "No"
    }
  }

  measure: cost_of_untagged {
    group_label: "Costs"
    label: "Untagged"
    value_format_name: usd
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: {
      field: is_tagged
      value: "No"
    }
  }

  measure: count_of_tagged_with_none {
    group_label: "Counts"
    label: "Tagged None"
    type: count
    filters: {
      field: is_tagged_with_none
      value: "Yes"
    }
  }

  measure: cost_of_tagged_with_none {
    group_label: "Costs"
    label: "Tagged None"
    value_format_name: usd
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: {
      field: is_tagged_with_none
      value: "Yes"
    }
  }

  measure: count_of_start_no_stop {
    group_label: "Counts"
    label: "Start no Stop"
    type: count
    filters: {
      field: has_start_no_stop
      value: "Yes"
    }
  }

  measure: cost_of_start_no_stop {
    group_label: "Costs"
    label: "Start no Stop"
    value_format_name: usd
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: {
      field: has_start_no_stop
      value: "Yes"
    }
  }

  measure: count_of_stop_no_start {
    group_label: "Counts"
    label: "Stop no Start"
    type: count
    filters: {
      field: has_stop_no_start
      value: "Yes"
    }
  }

  measure: cost_of_stop_no_start {
    group_label: "Costs"
    label: "Stop no Start"
    value_format_name: usd
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    filters: {
      field: has_stop_no_start
      value: "Yes"
    }
  }

  dimension: is_tagged {
    group_label: "Tag Flags"
    description: "*Yes* indicates that a resource has been tagged with an autostart or autostop tag of any value"
    type: yesno
    sql: NULLIF(trim(${autostart_tag}),'') is not null OR NULLIF(trim(${autostop_tag}),'') is not null ;;
  }

  dimension: is_tagged_with_none {
    group_label: "Tag Flags"
    description: "*Yes* indicates that a resource has been tagged with an autostart or autostop tag of value = none"
    type: yesno
    sql: lower(${autostart_tag}) like '%none%' OR lower(${autostop_tag}) like '%none%' ;;
  }

  dimension: has_start_no_stop {
    group_label: "Tag Flags"
    description: "*Yes* indicates that a resource has been tagged with an autostart but no autostop"
    type: yesno
    sql: coalesce(lower(${autostart_tag}),'none') <> 'none' AND coalesce(lower(${autostop_tag}),'none') = 'none' ;;
  }

  dimension: has_stop_no_start {
    group_label: "Tag Flags"
    description: "*Yes* indicates that a resource has been tagged with an autostart but no autostop"
    type: yesno
    sql: coalesce(lower(${autostart_tag}),'none') = 'none' AND coalesce(lower(${autostop_tag}),'none') <> 'none' ;;
  }

  dimension: autostart_tag {
    view_label: "Custom Resource Tagging"
    type: string
    sql: element_at(${startstop},1) ;;
  }

  dimension: autostop_tag {
    view_label: "Custom Resource Tagging"
    type: string
    sql: element_at(${startstop},2) ;;
  }

  # dimension: user_cost_category {
  #   view_label: "Custom Resource Tagging"
  #   type: string
  #   sql: ${TABLE}.resource_tags_user_cost_category ;;
  # }

  # dimension: customer_segment {
  #   view_label: "Custom Resource Tagging"
  #   type: string
  #   sql: CASE
  #         WHEN ${user_cost_category} = '744.00000000' THEN 'SMB'
  #         WHEN ${user_cost_category} = '' THEN 'Mid-Market'
  #         WHEN ${user_cost_category} = 'internal' THEN 'Enterprise'
  #         ELSE 'Enterprise'
  #         END
  #         ;;
  # }

  ### END EMNABLE FOR CUSTOM TAGS ###


  measure: count_line_items {
    view_label: "Line Items (Individual Charges)"
    type: count
  }

  measure: count_distinct_lines {
    view_label: "Line Items (Individual Charges)"
    type: count_distinct
    sql: ${pk} ;;
  }

  measure: count_distinct_lineitem_resourceid {
    view_label: "Line Items (Individual Charges)"
    label: "Resource Count"
    type: count_distinct
    sql: ${lineitem_resourceid} ;;
  }


  ### LINE ITEM AGGREGATIONS ###

  measure: total_gross_unblended_cost {
    view_label: "Line Items (Individual Charges)"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed, not including EDP Discount"
    type: sum
    sql: ${adj_unblended_cost} ;;
    value_format_name: usd
    drill_fields: [common*,cost_measures*]
  }

  measure: total_non_sp_edp_discount {
    type: sum
    sql: ${non_savings_plan_usage_edp_discount} ;;
    value_format_name: usd
    hidden: yes
    description: "EDP discounts on non-Savings plan lines and unusued Savings Plan amount"
  }

  measure: total_edp_discount_adj {
    type: number
    value_format_name: usd
    sql: ${total_non_sp_edp_discount} + ${total_usage_savings_plan_edp_discount} ;;
    description: "EDP discounts applied to the resources used"
    view_label: "Line Items (Individual Charges)"
    label: "Total EDP Discount - Adj"
  }


  measure: total_unblended_cost {
    view_label: "Line Items (Individual Charges)"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed."
    type: number
    sql: ${total_gross_unblended_cost} + ${total_edp_discount_adj} ;;
    value_format_name: usd
    drill_fields: [common*,cost_measures*]
  }

  measure: total_unblended_cost_raw {
    view_label: "Line Items (Individual Charges)"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed, where RIs are in main cost center and not allocated to used resources"
    type: sum_distinct
    sql: ${lineitem_unblendedcost} ;;
    value_format_name: usd
    sql_distinct_key: ${pk} ;;
  }

  measure: total_unblened_cost_raw_no_edp {
    type: sum
    sql: ${lineitem_unblendedcost} ;;
    filters: [type: "-EdpDiscount"]
    hidden: yes
  }

  measure: total_net_unblended_cost_raw {
    view_label: "Line Items (Individual Charges)"
    description: "The cost of all aggregated line items after tiered pricing and discounted usage have been processed, where RIs are in main cost center and not allocated to used resources"
    type: sum
    sql: ${lineitem_netunblendedcost} ;;
    value_format_name: usd
  }

  measure: average_unblended_rate {
    label: "Unblended Rate"
    view_label: "Line Items (Individual Charges)"
    description: "The average cost of all aggregated line items after tiered pricing and discounted usage have been processed."
    type: average
    sql: ${unblended_rate} ;;
    value_format_name: usd_0
  }

  measure: total_blended_cost {
    view_label: "Line Items (Individual Charges)"
    description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
    type: sum
    sql: ${lineitem_blendedcost} ;;
    value_format_name: usd
    drill_fields: [common*, total_blended_cost,  total_measures*]
  }

  measure: total_data_transfer_cost {
    view_label: "Line Items (Individual Charges)"
    description: "Total charges for data transfers"
    type: sum
    sql: ${lineitem_blendedcost} ;;
    value_format_name: usd_0
    filters: {
      field: data_transfer
      value: "Yes"
    }
    drill_fields: [common*, total_data_transfer_cost,  total_measures*]
  }

  measure: total_data_transfer_cost_unblended {
    view_label: "Line Items (Individual Charges)"
    description: "Total charges for data transfers"
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    value_format_name: usd_0
    filters: {
      field: data_transfer
      value: "Yes"
    }
    drill_fields: [common*, total_data_transfer_cost_unblended,  total_measures*]
  }

  measure: total_outbound_data_transfer_cost {
    view_label: "Line Items (Individual Charges)"
    description: "Total charges for data transfers"
    type: sum
    sql: ${lineitem_blendedcost} ;;
    value_format_name: usd_0
    filters: {
      field: data_transfer_outbound
      value: "Yes"
    }
    drill_fields: [common*, total_outbound_data_transfer_cost, inbound_outbound*]
  }


  measure: total_inbound_data_transfer_cost {
    view_label: "Line Items (Individual Charges)"
    description: "Total charges for data transfers"
    type: sum
    sql: ${lineitem_blendedcost} ;;
    value_format_name: usd_0
    filters: {
      field: data_transfer_inbound
      value: "Yes"
    }
    drill_fields: [common*, total_inbound_data_transfer_cost, inbound_outbound*]
  }

  measure: total_reserved_blended_cost {
    view_label: "Reserved Units"
    description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
    type: sum
    sql: ${lineitem_blendedcost};;
    value_format_name: usd_0
    filters: {
      field: ri_line_item
      value: "Yes"
    }
    drill_fields: [common*, total_reserved_blended_cost]
  }

  measure: total_reserved_unblended_cost {
    view_label: "Reserved Units"
    description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount});;
    value_format_name: usd_0
    filters: {
      field: ri_line_item
      value: "Yes"
    }
    drill_fields: [common*, total_reserved_blended_cost]
  }

  measure: total_non_reserved_blended_cost {
    view_label: "Reserved Units"
    description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
    type: sum
    sql: ${lineitem_blendedcost} ;;
    value_format_name: usd_0
    filters: {
      field: ri_line_item
      value: "No"
    }
    drill_fields: [common*, total_non_reserved_blended_cost]
  }

  measure: total_non_reserved_unblended_cost {
    view_label: "Reserved Units"
    description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
    type: sum
    sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}) ;;
    value_format_name: usd_0
    filters: {
      field: ri_line_item
      value: "No"
    }
    drill_fields: [common*, total_non_reserved_unblended_cost]
  }

  measure: percent_spend_on_non_ris{
    view_label: "Reserved Units"
    type: number
    sql: 1.0 * ${total_non_reserved_blended_cost} / NULLIF(${total_blended_cost},0) ;;
    link: {
      label: "Explore Non Reserved Blended Cost"
      url: "{{total_non_reserved_blended_cost._link}}"
    }
    link: {
      label: "Explore Total Blended Cost"
      url: "{{total_blended_cost._link}}"
    }
    value_format_name: percent_2
  }

  measure: percent_spend_on_ris{
    view_label: "Reserved Units"
    label: "Blended RI Coverage"
    type: number
    sql: 1.0 * ${total_reserved_blended_cost} / NULLIF(${total_blended_cost},0) ;;
    value_format_name: percent_2
    link: {
      label: "Explore Reserved Blended Cost"
      url: "{{total_reserved_blended_cost._link}}"
    }
    link: {
      label: "Explore Total Blended Cost"
      url: "{{total_blended_cost._link}}"
    }
  }

  measure: unblended_percent_spend_on_ris{
    view_label: "Reserved Units"
    label: "Unblended RI Coverage"
    type: number
    sql: 1.0 * ${total_non_reserved_unblended_cost} / NULLIF(${total_unblended_cost},0) ;;
    value_format_name: percent_2
    link: {
      label: "Explore Non Reserved Unblended Cost"
      url: "{{total_non_reserved_unblended_cost._link}}"
    }
    link: {
      label: "Explore Total Blended Cost"
      url: "{{total_blended_cost._link}}"
    }
  }

  measure: percent_spend_data_transfers_unblended {
    view_label: "Reserved Units"
    label: "Unblended Data Transfer Cost Percent"
    type: number
    sql: 1.0 * ${total_data_transfer_cost_unblended} / NULLIF(${total_unblended_cost},0) ;;
    value_format_name: percent_2
    link: {
      label: "Explore Data Transfer Unblended Cost"
      url: "{{total_data_transfer_cost_unblended._link}}"
    }
    link: {
      label: "Explore Total Blended Cost"
      url: "{{total_blended_cost._link}}"
    }
  }

  measure: count_usage_months {
#     hidden: yes
  type: count_distinct
  sql: ${usage_start_month} ;;
  drill_fields: [billing_period_start_month, total_measures*]
}

measure: average_blended_cost_all_time {
  view_label: "Line Items (Individual Charges)"
  description: "How much all aggregated line items are charged to a consolidated billing account in an organization"
  type: average
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd
  drill_fields: [common*, basic_blended_measures*]
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

measure: average_blended_rate {
  label: "Blended Rate"
  view_label: "Line Items (Individual Charges)"
  description: "The average rate applied to all aggregated line items for a consolidated billing account in an organization."
  type: average
  sql: ${blended_rate} ;;
  value_format_name: usd
  drill_fields: [common*, basic_blended_measures*]
}

measure: total_usage_amount {
  view_label: "Line Items (Individual Charges)"
  description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
  type: sum
  sql: ${usage_amount_adjusted} ;;
  value_format_name: decimal_0
  drill_fields: [common*, basic_blended_measures*]
}

measure: total_reserved_usage_amount {
  view_label: "Line Items (Individual Charges)"
  description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
  type: sum
  sql: ${usage_amount_adjusted} ;;
  value_format_name: decimal_0
  drill_fields: [common*, basic_blended_measures*]
  filters: [ri_line_item: "Yes"]
}

measure: total_reserved_usage_amount_temp {  ## temporary measure used to determine spend by resource on a reservation
  view_label: "Line Items (Individual Charges)"
  description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
  type: sum
  sql: ${lineitem_usageamount} ;;
  hidden: no
  value_format_name: decimal_0
  drill_fields: [common*, basic_blended_measures*]
  filters: [type: "-RIFee", ri_line_item: "Yes"]
}

measure: total_on_demand_usage_amount {
  view_label: "Line Items (Individual Charges)"
  description: "The amount of usage incurred by the customer. For all reserved units, use the Total Reserved Units column instead."
  type: sum
  sql: ${lineitem_usageamount} ;;
  value_format_name: decimal_0
  drill_fields: [common*, basic_blended_measures*]
  filters: [ri_line_item: "No"]
}

### AWS-Cardinal Agreement

measure: marketplace_unblendedcost {
  type: sum
  view_label: "AWS-Cardinal Agreement"
  hidden: yes
  value_format_name: "usd"
  sql: (${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount}))/2;;
  filters: [bill_billing_entity: "AWS Marketplace",type: "-Tax"]
}

measure: notmarketplace_unblendedcost {
  type: sum
  view_label: "AWS-Cardinal Agreement"
  hidden: yes
  value_format_name: "usd"
  sql: ${adj_unblended_cost} + if(${discount_edp_discount} is null, 0, ${discount_edp_discount});;
  filters: [bill_billing_entity: "-AWS Marketplace",type: "-Tax"]
}

measure: marketplace_unblendedcost_half {
  view_label: "AWS-Cardinal Agreement"
  type: number
  value_format_name: usd
  description: "this column is created to calculate AWS spend for marketplace, as per aws-cardinal aggrement"
  sql: ${marketplace_unblendedcost}+${notmarketplace_unblendedcost};;
}

### PRODUCT SPECIFIC COST MEASURES ###

measure: EC2_usage_amount {
  label: "EC2 Usage Amount"
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_usageamount} ;;
  filters: {
    field: product_code
    value: "AmazonEC2"
  }
  drill_fields: [common*, EC2_usage_amount, ec2_measures*]
}

measure: cloudfront_usage_amount {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_usageamount} ;;
  filters: {
    field: product_code
    value: "AmazonCloudFront"
  }
  drill_fields: [common*, cloudfront_usage_amount]
}

measure: cloudtrail_usage_amount {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_usageamount} ;;
  filters: {
    field: product_code
    value: "AWSCloudTrail"
  }
  drill_fields: [common*, cloudtrail_usage_amount]
}
measure: S3_usage_amount {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_usageamount} ;;
  filters: {
    field: product_code
    value: "AmazonS3"
  }
  drill_fields: [common*, S3_usage_amount]
}

measure: redshift_usage_amount {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_usageamount} ;;
  filters: {
    field: product_code
    value: "AmazonRedshift"
  }
  drill_fields: [common*, redshift_usage_amount]
}

measure: rds_usage_amount {
  label: "RDS Usage Amount"
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_usageamount} ;;
  filters: {
    field: product_code
    value: "AmazonRDS"
  }
  drill_fields: [common*, rds_usage_amount]
}

measure: EC2_blended_cost {
  label: "EC2 Blended Cost"
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonEC2"
  }
  drill_fields: [common*, EC2_blended_cost, ec2_measures*]
}

measure: EC2_reserved_blended_cost {
  label: "EC2 Reserved Blended Cost"
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonEC2"
  }
  filters: {
    field: ri_line_item
    value: "Yes"
  }
  drill_fields: [common*, EC2_reserved_blended_cost, ec2_measures*]
}

measure: EC2_non_reserved_blended_cost {
  label: "EC2 Non Reserved Blended Cost"
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonEC2"
  }
  filters: {
    field: ri_line_item
    value: "No"
  }
  drill_fields: [common*, EC2_non_reserved_blended_cost, ec2_measures*]
}

measure: cloudfront_blended_cost {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonCloudFront"
  }
  drill_fields: [common*, cloudtrail_blended_cost]
}

measure: cloudtrail_blended_cost {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AWSCloudTrail"
  }
  drill_fields: [common*, cloudtrail_blended_cost]
}
measure: S3_blended_cost {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonS3"
  }
  drill_fields: [common*, S3_blended_cost]
}

measure: redshift_blended_cost {
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonRedshift"
  }
  drill_fields: [common*, redshift_blended_cost]
}

measure: rds_blended_cost {
  label: "RDS Blended Cost"
  view_label: "Product Info"
  type: sum
  sql: ${lineitem_blendedcost} ;;
  value_format_name: usd_0
  filters: {
    field: product_code
    value: "AmazonRDS"
  }
  drill_fields: [common*, rds_blended_cost]
}





set: common {fields: [lineitem_resourceid, line_item_operation,   type, bill_payeraccountid, description]}
set: total_measures {fields: [total_data_transfer_cost_unblended, total_data_transfer_cost, total_blended_cost, total_unblended_cost]  }
set: inbound_outbound {fields: [total_data_transfer_cost_unblended, total_data_transfer_cost, total_outbound_data_transfer_cost, total_inbound_data_transfer_cost]}
set: basic_blended_measures {fields: [average_blended_cost_per_month, average_blended_rate, total_usage_amount]}
set: ec2_measures {fields: [EC2_blended_cost,EC2_reserved_blended_cost,EC2_non_reserved_blended_cost,EC2_usage_amount]}
set: cost_measures {fields: [total_unblended_cost, total_usage_amount]}
set: final_cost {fields: [lineitem_usageaccountid, project_name, apmid, product_servicecode, application, cost_center, cost_center_1to1, cost_center_raw_2, lineitem_resourceid, total_unblended_cost, aws_total_costs.tax_costs, aws_total_costs.support_costs, aws_total_costs.final_costs]}

}
