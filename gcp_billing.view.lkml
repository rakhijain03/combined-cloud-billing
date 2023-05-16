view: gcp_billing {
  derived_table: {
    partition_keys: ["usage_start_date"]
    datagroup_trigger: gcp_datagroup
    increment_key: "export_date"
    increment_offset: 0
    ## flatten billing table, unnesting values as needed
    sql: SELECT
                generate_uuid() as pk,
                billing_account_id,
                service.description AS service,
                sku.description AS sku,
                sku.id as sku_id,
                cast(usage_start_time as date) as usage_start_date,
                cast(usage_end_time as date) as usage_end_date,
                cast(export_time as date) as export_date,
                invoice.month as invoice_month,
                concat(substr(invoice.month,0,4),'-',substr(invoice.month,5,2)) as invoice_month_2,
                project.name AS project,
                project.id AS project_id,
                location.country AS country,
                location.region AS region,
                location.location AS location,
                location.zone AS zone,
                -- custom tagging based on company policy
                (SELECT value FROM UNNEST(project.labels) WHERE key = 'apmid') as project_apmid,
                (SELECT value FROM UNNEST(labels) WHERE key = 'resourcename') as resource_name,
                (SELECT value FROM UNNEST(labels) WHERE key = 'apmid') as resource_apmid,
                (SELECT value FROM UNNEST(labels) WHERE key = 'environment') as resource_environment,
                (SELECT p.value FROM UNNEST(project.labels) p WHERE p.key = 'costcenter') as project_cost_center,
                (SELECT r.value FROM UNNEST(labels) r WHERE r.key = 'costcenter') as resource_cost_center,
                sum(cost) as cost,
                sum(IFNULL((SELECT SUM(IFNULL(c.amount, 0.0)) from UNNEST(credits) c where c.type = 'PROMOTION'), 0.0)) as promotion_credits,
                sum(IFNULL((SELECT SUM(IFNULL(c.amount, 0.0)) from UNNEST(credits) c where c.type in ("COMMITTED_USAGE_DISCOUNT, COMMITTED_USAGE_DISCOUNT_DOLLAR_BASE")), 0.0)) as commited_use_credits,
                sum(IFNULL((SELECT SUM(IFNULL(c.amount, 0.0)) from UNNEST(credits) c where c.type = 'SUSTAINED_USAGE_DISCOUNT'), 0.0)) as sustained_used_discount,
                sum(IFNULL((SELECT SUM(IFNULL(amount, 0.0)) from UNNEST(credits)), 0.0)) as credit_total,
                usage.unit as usage_unit,
                sum(usage.amount) as usage_amount,
                usage.pricing_unit AS pricing_unit
              FROM
                @{gcp_billing_table}
              GROUP BY
                billing_account_id,
                service,
                sku,
                sku_id,
                usage_start_date,
                usage_end_date,
                export_date,
                invoice_month,
                project,
                project_id,
                country,
                region,
                location,
                zone,
                project_apmid,
                resource_name,
                resource_apmid,
                resource_environment,
                project_cost_center,
                resource_cost_center,
                usage_unit,
                pricing_unit
                ;;
  }

  dimension: pk {
    primary_key: yes
    sql: ${TABLE}."PK" ;;
    hidden: yes
  }

  dimension: invoice_month {
    can_filter: yes
    type: string
    sql: ${TABLE}.invoice_month_2 ;;
  }

  dimension: billing_account_id {
    type: string
    sql: ${TABLE}.billing_account_id ;;
  }

  dimension: service {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    group_label: "Resource Hierarchy"
    label: "Service"
    type: string
    sql: ${TABLE}.service ;;
  }

  dimension: usage_amount {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    group_label: "Resource Hierarchy"
    label: "Usage Amount"
    hidden: yes
    type: number
    sql: ${TABLE}.usage_amount ;;
  }

  measure: total_usage_amount {
    sql: ${usage_amount} ;;
    type: sum
    value_format_name: decimal_0
    description: "Total Usage amount of SKU"
  }

  dimension: usage_unit {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    group_label: "Resource Hierarchy"
    label: "Usage Unit"
    type: string
    sql: ${TABLE}.usage_unit ;;
  }

  dimension: sku {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    group_label: "Resource Hierarchy"
    label: "SKU"
    type: string
    sql: ${TABLE}.sku ;;
  }

  dimension: sku_id {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    group_label: "Resource Hierarchy"
    label: "SKU ID"
    type: string
    sql: ${TABLE}.sku_id ;;
  }

  dimension: sku_category {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    label: "SKU Category"
    group_label: "Resource Hierarchy"
    type: string
    description: "Provides an additional layer of granularity above SKU"
    sql:
      CASE
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%licensing%') THEN 'Compute Engine License'
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%network%') THEN 'Networking'
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%instance%') THEN 'Compute Engine Instance'
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%pd%') THEN 'Compute Engine Storage'
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%intel%') THEN 'Compute Engine Instance'
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%storage%') THEN 'Compute Engine Storage'
        WHEN (lower(${service}) = 'compute engine'
              AND lower(${sku}) LIKE '%ip%') THEN 'Networking'
        WHEN (lower(${service}) = 'bigquery'
              AND lower(${sku}) LIKE '%storage%') THEN 'BigQuery Storage'
        WHEN (lower(${service}) = 'bigquery'
              AND lower(${sku}) = 'analysis') THEN 'BigQuery Analysis'
        WHEN (lower(${service}) = 'bigquery'
              AND lower(${sku}) = 'streaming insert') THEN 'BigQuery Streaming'
        WHEN (lower(${service}) = 'cloud storage'
              AND lower(${sku}) LIKE '%storage%') THEN 'GCS Storage'
        WHEN (lower(${service}) = 'cloud storage'
              AND lower(${sku}) LIKE '%download%') THEN 'GCS Download'
        WHEN (lower(${service}) = 'cloud dataflow'
              AND lower(${sku}) LIKE '%pd%') THEN 'Dataflow PD'
        WHEN ((lower(${service}) = 'cloud dataflow'
              AND lower(${sku}) LIKE '%vcpu%')
                    OR lower(${sku}) LIKE '%ram%') THEN 'Dataflow Compute'
        ELSE ${service}
      END ;;
  }


  dimension_group: usage_start {
    #drill_fields: [project,environment.environment,resource.resource,sku_category,sku,pricing_unit]
    timeframes: [raw,date,day_of_week_index,day_of_month,day_of_year,week,week_of_year,month,month_name,quarter,quarter_of_year,year]
    type: time
    sql: cast(${TABLE}.usage_start_date as timestamp) ;;
  }

  dimension_group: usage_end {
    timeframes: [raw,date,day_of_week_index,day_of_month,day_of_year,week,week_of_year,month,month_name,quarter,quarter_of_year,year]
    type: time
    sql: cast(${TABLE}.usage_end_date as timestamp) ;;
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



### this dimension is only used for allocation to one cost center


  dimension: project {
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    group_label: "Resource Hierarchy"
    label: "Project"
    type: string
    sql: ${TABLE}.project ;;
  }

  dimension: project_id {
    hidden: yes
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: credit_total {
    description: "Sum of all credits"
    sql: ${TABLE}.credit_total ;;
    hidden: yes
  }

  dimension: system_details {
    hidden: yes
    type: string
    sql: ${TABLE}.system_details ;;
  }

  dimension: country {
    drill_fields: [region_cleansed,zone]
    group_label: "Location Hierarchy"
    label: "1) Country"
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: region {
    hidden: yes
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: location {
    hidden: yes
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: region_cleansed {
    drill_fields: [zone]
    group_label: "Location Hierarchy"
    label: "2) Region"
    description: "The region of the hosted service. If region is null, defaults to what is populated in location"
    sql: COALESCE(${region},${location}) ;;
  }

  dimension: zone {
    group_label: "Location Hierarchy"
    label: "3) Zone"
    type: string
    sql: ${TABLE}.zone ;;
  }

  dimension: gross_cost {
    group_label: "Costs and Credits"
    description: "The cost associated to an SKU, between Start Date and End Date"
    value_format_name: usd
    type: number
    sql: COALESCE(${TABLE}.cost,0) ;;
    hidden: yes
  }

  measure: total_gross_cost {
    group_label: "Costs and Credits"
    description: "The total cost associated to the SKU, between the Start Date and End Date"
    value_format_name: usd
    type: sum
    sql: ${gross_cost} ;;
    drill_fields: [sku_level_drill_fields*]
  }

  measure: total_net_cost {
    group_label: "Costs and Credits"
    description: "The total cost associated to an SKU, between Start Date and End Date, less credits"
    value_format_name: usd
    sql: ${gross_cost} + ${credit_total} ;;
    type: sum
    drill_fields: [sku_level_drill_fields*]
  }

  measure: total_net_cost_less_support_tax {
    group_label: "Costs and Credits"
    description: "The total net costs after credit, less support and tax"
    value_format_name: usd
    sql: ${gross_cost} + ${credit_total} ;;
    type: sum
    filters: [cost_type: "Cost"]
    drill_fields: [sku_level_drill_fields*]
  }

  dimension: pricing_unit {
    group_label: "Resource Hierarchy"
    label: "Pricing Unit"
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    type: string
    sql: ${TABLE}.pricing_unit ;;
  }

  measure: total_credit {
    group_label: "Costs and Credits"
    description: "The total amount of all usage credits associated to an SKU, between Start Date and End Date"
    value_format_name: usd
    type: sum
    sql: ${credit_total} ;;
    hidden: no
  }

  # dimension: project_cost_center {
  #   hidden: yes
  #   type: string
  #   sql: ${TABLE}.project_cost_center ;;
  # }
  # dimension: resource_cost_center {
  #   hidden: yes
  #   type: string
  #   sql: ${TABLE}.resource_cost_center ;;
  # }


# ## If a cost center is allocated to a particular resource, we should use that. If that doesn't exist, default to the project cost center
#   dimension: cost_center_t1 {
#     hidden: yes
#     sql: IF(${resource_cost_center} is null or CHAR_LENGTH(TRIM(${resource_cost_center})) = 0,TRIM(${project_cost_center}),TRIM(${resource_cost_center})) ;;
#   }

# ##  specific rules to allocating back costs for charge backs

#   dimension: cost_center {
#     label: "Cost Center"
#     drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
#     type: string
#     sql:
#           CASE
#             WHEN (${cost_center_t1} is NULL OR CHAR_LENGTH(${cost_center_t1}) = 0) AND ${sku} = 'Tax' THEN 'Tax'
#             WHEN ${sku} = 'Platinum-level support cost' THEN 'Platinum-level support cost'
#             WHEN ${cost_center_t1} is NULL AND (${sku} NOT IN ('Tax', 'Platinum-level support cost')) THEN 'Shared-185'
#             WHEN ${cost_center_t1} LIKE '%shared%' THEN 'Shared-185'
#             WHEN ${cost_center_t1} = '1120000174'
#               AND ${project} IN ('ecomm-market-np', 'ecomm-advrpt-np', 'ecomm-advrpt-pr', 'ecomm-market-pr', 'ecomm-pharma-np', 'ecomm-pharma-pr', 'ecomm-red-np')
#               AND ${in_migration_period} THEN '1120000160'
#             ELSE ${cost_center_t1}
#           END
#           ;;
#   }

  dimension: resource_environment {
    sql: ${TABLE}.resource_environment ;;
    group_label: "Resource Hierarchy"
    hidden: yes
  }

  dimension: environment_clean {
    description: "The environment values standardized. EX: prod and production both become Production"
    group_label: "Resource Hierarchy"
    label: "Environment"
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    case: {
      when: {
        label: "production"
        sql: ${resource_environment} in ('production','prod') ;;
      }
      when: {
        label: "stage"
        sql: ${resource_environment} in ('stage','stg') ;;
      }
      when: {
        label: "development"
        sql: ${resource_environment} in ('development','dev') ;;
      }
      when: {
        label: "qa"
        sql: ${resource_environment} in ('quality','qa') ;;
      }
      else: "other"
    }
    sql: ${resource_environment} ;;
  }

  dimension: resource_name {
    group_label: "Resource Hierarchy"
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    sql: CASE WHEN ${sku} = 'Tax' THEN 'Tax' WHEN ${sku} = 'Platinum-level support cost' THEN 'Platinum-level support cost' ELSE ${TABLE}.resource_name END ;;
  }

  dimension: instance_name{
    group_label: "Resource Hierarchy"
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    hidden: no
    type: string
    sql: CASE WHEN ${sku} = 'Tax' THEN 'Tax' WHEN ${sku} = 'Platinum-level support cost' THEN 'Platinum-level support cost' ELSE ${TABLE}.instance_name END;;
  }

  dimension: project_apmid {
    hidden: yes
    type: string
    sql: ${TABLE}.project_apmid ;;
  }

  dimension: resource_apmid {
    hidden: yes
    type: string
    sql: ${TABLE}.resource_apmid ;;
  }

## If a cost center is allocated to a particular resource, we should use that. If that doesn't exist, default to the project cost center
  dimension: apmid_t1 {
    hidden: yes
    sql:  IF(${resource_apmid} is null or CHAR_LENGTH(TRIM(${resource_apmid})) = 0,TRIM(${project_apmid}),TRIM(${resource_apmid}))
      ;;
  }

## cardinal specific rules to allocating back costs for charge backs
  # dimension: apmid {
  #   hidden: yes
  #   group_label: "Service Now Org Hierarchy"
  #   label: "6) APMID"
  #   type: string
  #   sql:
  #         CASE
  #           WHEN (${apmid_t1} is NULL OR CHAR_LENGTH(${apmid_t1}) = 0) AND ${sku} = 'Tax' THEN 'Tax'
  #           WHEN ${sku} = 'Platinum-level support cost' THEN 'Platinum-level support cost'
  #           WHEN ${apmid_t1} is NULL AND (${sku} NOT IN ('Tax', 'Platinum-level support cost')) THEN 'Shared-185'
  #           WHEN ${apmid_t1} LIKE '%shared%' THEN 'Shared-185'
  #           WHEN ${apmid_t1} = '1120000174'
  #             AND ${project} IN ('ecomm-market-np', 'ecomm-advrpt-np', 'ecomm-advrpt-pr', 'ecomm-market-pr', 'ecomm-pharma-np', 'ecomm-pharma-pr', 'ecomm-red-np')
  #             AND ${in_migration_period} THEN '1120000160'
  #           ELSE ${apmid_t1}
  #         END
  #         ;;
  # }

  dimension: apmid_2 {
    group_label: "Resource Hierarchy"
    label: "APMID"
    drill_fields: [service,environment_clean,resource_name,sku_category,sku,total_net_cost,total_usage_amount,project]
    sql: CASE WHEN ${sku} = 'Tax' THEN 'Tax' WHEN ${sku} = 'Platinum-level support cost' THEN 'Platinum-level support cost'
      ELSE (CASE WHEN ${TABLE}.resource_apmid IS NULL OR CHAR_LENGTH(${TABLE}.resource_apmid) = 0 THEN ${TABLE}.project_apmid ELSE ${TABLE}.resource_apmid END)  END ;;
  }

  dimension: apmid_source {
    group_label: "Resource Hierarchy"
    sql: CASE WHEN ${TABLE}.resource_apmid IS NULL OR CHAR_LENGTH(${TABLE}.resource_apmid) = 0 THEN 'Project_apmid' ELSE 'Resource_apmid' END ;;
  }

  dimension: cost_type {
    hidden: yes
    type: string
    sql:
          CASE
            WHEN ${sku} = 'Tax' THEN 'Tax'
            WHEN ${sku} = 'Platinum-level support cost' THEN 'Support'
            ELSE 'Cost'
          END
          ;;
  }

  dimension: is_tax {
    hidden: yes
    type: yesno
    sql: ${cost_type} = 'Tax' ;;
  }

  dimension: is_support {
    hidden: yes
    type: yesno
    sql: ${cost_type} = 'Support' ;;
  }

  dimension: is_tax_or_support {
    hidden: no
    type: yesno
    sql: ${is_tax} OR ${is_support} ;;
  }

## Measures to determine total tax and support, and divide between cost centers based on % of net costs ##

  measure: total_tax {
    type: sum
    filters: [cost_type: "Tax"]
    sql: ${gross_cost} + ${credit_total} ;;
    group_label: "Costs and Credits"
    value_format_name: usd
  }

  measure: total_support {
    type: sum
    filters: [cost_type: "Support"]
    sql: ${gross_cost} + ${credit_total} ;;
    group_label: "Costs and Credits"
    value_format_name: usd
  }

  measure: percent_of_total {
    group_label: "Costs and Credits"
    description: "Percent of net cost divided by all costs for the same time period"
    value_format_name: percent_1
    type: number
    sql: 1.0 * ${total_net_cost_less_support_tax} / NULLIF(${gcp_billing_total.total_cost_less_support_tax},0) ;;
  }

  measure: tax_allocation {
    group_label: "Costs and Credits"
    description: "Allocated taxes based on percent of total multiplied by net cost"
    value_format_name: usd
    type: number
    sql: ${gcp_billing_total.total_tax_costs} * ${percent_of_total} ;;
  }

  measure: suport_allocation {
    group_label: "Costs and Credits"
    description: "Allocated support based on percent of total multiplied by net cost"
    value_format_name: usd
    type: number
    sql: ${gcp_billing_total.total_support_costs} * ${percent_of_total} ;;
  }

# ## GKE Distribution based on Usage ##

#   measure: gke_cost_offset {
#     group_label: "GKE Costs"
#     description: "Amount of GKE costs that are in original Cost Center that will be offset by new allocation totals"
#     sql: ${gross_cost} + ${credit_total} ;;
#     type: sum
#     filters: [project: "gke-prod, gke-np",invoice_month: "-2019%, -2018%, -null", service: "Compute Engine, Stackdriver Monitoring, Stackdriver Logging"]  ## Step 1: Identifying costs associated with GKE that we want to distribute using the usage % data
#     value_format_name: usd
#   }

#   measure: gke_cost_not_offset {
#     group_label: "GKE Costs"
#     sql: ${gross_cost} + ${credit_total} ;;
#     type: sum
#     value_format_name: usd
#     filters: [project: "gke-prod, gke-np", service: "-Compute Engine, -Stackdriver Monitoring, -Stackdriver Logging"] ## SKUs that are not included in Step 1 but are considered GKE
#   }

#   measure: gke_distributed_costs {
#     group_label: "GKE Costs"
#     description: "Total GKE costs * Compute Engine usage by Cost Center"
#     value_format_name: usd
#     sql: ${gke_billing_aggregated_totals.total_cost} * ${gke_costcenter_usage_percent.percent} ;;  ## Step 2: Reference the GKE Billing Totals by Month (sum of gke_cost_offset) and multiply by the % distribution of usage by month/cost center
#   }

#   measure: gke_net_distribution {
#     group_label: "GKE Costs"
#     description: "Net of GKE cost offset (original shared cost center) and Distributed Costs based on Compute Engine Usage"
#     sql: ${gke_distributed_costs} - ${gke_cost_offset} ;; ## Step 3: Combine the non-distributed and the distributed costs, subtracting the total distributed amount
#     type: number
#     value_format_name: usd
#     drill_fields: [cost_center, gke_cost_offset, gke_cost_not_offset, gke_distributed_costs]
#   }

#   measure: total_gke_spend {
#     group_label: "GKE Costs"
#     sql: ${gke_distributed_costs} + ${gke_cost_not_offset} ;;
#     description: "Total GKE spend including distributed amount and not offset amount -- only can be used at the cost/center detail level"
#     drill_fields: [cost_center, gke_cost_offset, gke_cost_not_offset, gke_distributed_costs]
#     value_format_name: usd_0
#   }


## final_cost ##

  measure: final_cost {
    type: number
    group_label: "Costs and Credits"
    description: "Total costs, less credits, plus support and tax allocation"
    value_format_name: usd
    sql: ${total_net_cost_less_support_tax} + ${tax_allocation} + ${suport_allocation};;
    drill_fields: [sku_level_drill_fields*,tax_allocation,suport_allocation,final_cost,project]
  }

  # measure: final_cost_gke {
  #   type: number
  #   group_label: "Costs and Credits"
  #   description: "Total costs, less credits, plus support and tax allocation and GKE distribution"
  #   label: "Final Cost - with GKE Distribution"
  #   value_format_name: usd
  #   sql: ${total_net_cost_less_support_tax} + ${tax_allocation} + ${suport_allocation} + ${gke_net_distribution} ;;
  #   drill_fields: [sku_level_drill_fields*,tax_allocation,suport_allocation,final_cost,project]
  # }

  set: sku_level_drill_fields {
    fields: [project,resource_name,sku_category,sku, pricing_unit, usage_unit, total_gross_cost, total_credit, total_net_cost, total_usage_amount,project]
  }


  measure: count_months {
    #hidden: yes
    type: count_distinct
    sql: ${invoice_month}  ;;
  }

  # measure: budget {
  #   value_format_name: usd
  #   type: number
  #   sql: 1.0*${inv_fy20_budget.budget_math} * NULLIF(${count_months},0) ;;
  # }

  #set: drill_fields {
  #  fields: [vw_key_servicenow_fields.dv_u_svp,vw_key_servicenow_fields.dv_u_vp,vw_key_servicenow_fields.dv_u_director,vw_key_servicenow_fields.dv_u_manager,project,resource_name,cost_center,apmid_2,sku_category,sku, pricing_unit, usage_unit,total_gross_cost, total_credit, total_net_cost,total_usage]
  #}
}
