view: standardized_category {
  derived_table: {
    datagroup_trigger: daily
    sql:SELECT "Compute Engine" as product_code,"Compute Engine Instance" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Compute Instance" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Compute Engine" as product_code,"Compute Engine Storage" as sku_category,"Storage" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Compute Engine" as product_code,"Compute Engine License" as sku_category,"License" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"Database Instance" as sku_category,"Database" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonWorkSpaces" as product_code,"Enterprise Applications" as sku_category,"" as standard_usage_group,"End User Computing"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Storage" as sku_category,"Storage" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Compute Engine" as product_code,"Dataflow Compute" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Compute Engine" as product_code,"Compute Engine" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Storage Snapshot" as sku_category,"Snapshot" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Invoice" as product_code,"Invoice" as sku_category,"" as standard_usage_group,"Cost Management"as Standardized_Category UNION ALL
      SELECT "Support" as product_code,"Support" as sku_category,"" as standard_usage_group,"Support"as Standardized_Category UNION ALL
      SELECT "ComputeSavingsPlans" as product_code,"" as sku_category,"" as standard_usage_group,"Cost Management"as Standardized_Category UNION ALL
      SELECT "NetApp Cloud Volumes" as product_code,"NetApp Cloud Volumes" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "Cloud Storage" as product_code,"GCS Storage" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonRedshift" as product_code,"Compute Instance" as sku_category,"Data Warehouse" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonS3" as product_code,"Storage" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"System Operation" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Stackdriver Logging" as product_code,"Stackdriver Logging" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Data Transfer" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AWSGlue" as product_code,"AWS Glue" as sku_category,"Networking" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"Provisioned IOPS" as sku_category,"Database Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"Database Storage" as sku_category,"Database Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"Storage Snapshot" as sku_category,"Snapshot" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "Compute Engine" as product_code,"Networking" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "BigQuery" as product_code,"BigQuery Analysis" as sku_category,"Data Warehouse" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "p9xyzn6irhdi4789la2cu09n" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Load Balancer" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "93cq63jb3oqgmk99wdn7n5r5m" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonWorkSpaces" as product_code,"" as sku_category,"" as standard_usage_group,"End User Computing"as Standardized_Category UNION ALL
      SELECT "89ervo8w217g201447jbu77e" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "Cloud SQL" as product_code,"Cloud SQL" as sku_category,"Compute" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "806j2of0qy5osgjjixq9gqc6g" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "bk9ifwvjadm70j0qym0ui6msi" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "Stackdriver Monitoring" as product_code,"Stackdriver Monitoring" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonEFS" as product_code,"Storage" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "2sicodp2tjinebxlwpk4xb5l5" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AWSDirectConnect" as product_code,"Direct Connect" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"Data Payload" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AWSConfig" as product_code,"Management Tools - AWS Config Rules" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Fee" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonS3" as product_code,"" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"" as sku_category,"Database Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AWSStorageGateway" as product_code,"StorageGateway-Storage" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Dedicated Host" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "6kxdw3bbmdeda3o6i1ggqt4km" as product_code,"" as sku_category,"Unknown" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AWSDirectConnect" as product_code,"Data Transfer" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "Cloud Pub/Sub" as product_code,"Cloud Pub/Sub" as sku_category,"Compute" as standard_usage_group,"Notification service"as Standardized_Category UNION ALL
      SELECT "Cloud SQL" as product_code,"Dataflow Compute" as sku_category,"Compute" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonRedshift" as product_code,"" as sku_category,"Data Warehouse" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Load Balancer-Application" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "Security Command Center" as product_code,"Security Command Center" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "Aqua Security Software Inc. Aqua Cloud Native Security Platform" as product_code,"Aqua Security Software Inc. Aqua Cloud Native Security Platform" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonGuardDuty" as product_code,"GuardDuty" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "Directions API" as product_code,"Directions API" as sku_category,"Enterprise App" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonS3" as product_code,"API Request" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"System Operation" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"Metric" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"NAT Gateway" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AWSFMS" as product_code,"Firewall Manager Policy" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"API Request" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AWSSupportBusiness" as product_code,"AWSSupportBusiness" as sku_category,"Admin" as standard_usage_group,"Support"as Standardized_Category UNION ALL
      SELECT "AWSDeveloperSupport" as product_code,"AWSDeveloperSupport" as sku_category,"Admin" as standard_usage_group,"Support"as Standardized_Category UNION ALL
      SELECT "AWSConfig" as product_code,"Management Tools - AWS Config" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AWSLambda" as product_code,"Serverless" as sku_category,"Networking" as standard_usage_group,"Cloud Function"as Standardized_Category UNION ALL
      SELECT "Cloud Data Fusion" as product_code,"Cloud Data Fusion" as sku_category,"Networking" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AWSBackup" as product_code,"AWS Backup Storage" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AWSCloudTrail" as product_code,"Management Tools - AWS CloudTrail Paid Events Recorded" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonVPC" as product_code,"Cloud Connectivity" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AWSDatabaseMigrationSvc" as product_code,"Replication Server" as sku_category,"Networking" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonEFS" as product_code,"Provisioned Throughput" as sku_category,"Networking" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "Cloud Storage" as product_code,"Cloud Storage" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"Load Balancer-Network" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AWSDirectoryService" as product_code,"AWS Directory Service" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AWSDataTransfer" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Migration & Transfer"as Standardized_Category UNION ALL
      SELECT "NetApp, Inc. Cloud Manager for Cloud Volumes ONTAP" as product_code,"NetApp, Inc. Cloud Manager for Cloud Volumes ONTAP" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AWSCloudTrail" as product_code,"Management Tools - AWS CloudTrail Data Events Recorded" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "BigQuery" as product_code,"BigQuery Storage" as sku_category,"Database Storage" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "15ifz3sewlwbamqirgbxavdx3" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "dqopnmm95odjilthdh7l0hvrm" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "e7pnwyzhiwgalbdwq0btijzmm" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"Data Transfer" as sku_category,"Networking" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "8kmev5c1k8k5l252u6tao69d5" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "530ta1y1xx5vet0jer1rpp019" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonES" as product_code,"Elastic Search Instance" as sku_category,"Compute" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "2tyyu17icrugeluktpk37i7dp" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "Palo Alto Networks, Inc. VM-Series Next-Generation Firewall Bundle 2" as product_code,"Palo Alto Networks, Inc. VM-Series Next-Generation Firewall Bundle 2" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonElastiCache" as product_code,"Cache Instance" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"IP Address" as sku_category,"Networking" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"Storage Snapshot" as sku_category,"Snapshot" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonS3" as product_code,"Data Transfer" as sku_category,"Cloud Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AWSDatabaseMigrationSvc" as product_code,"Replication Storage" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"Alarm" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AWSTransfer" as product_code,"AWS Transfer for SFTP" as sku_category,"Networking" as standard_usage_group,"Migration & Transfer"as Standardized_Category UNION ALL
      SELECT "3buiebsof1934vu37o4o6cdar" as product_code,"" as sku_category,"" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonCloudFront" as product_code,"Data Transfer" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AWSQueueService" as product_code,"API Request" as sku_category,"Networking" as standard_usage_group,"Application Integration"as Standardized_Category UNION ALL
      SELECT "Maps API" as product_code,"Maps API" as sku_category,"Enterprise App" as standard_usage_group,"Google Maps"as Standardized_Category UNION ALL
      SELECT "AmazonDynamoDB" as product_code,"Provisioned IOPS" as sku_category,"Networking" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"Dashboard" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "awswaf" as product_code,"Web Application Firewall" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "Cloud Machine Learning Engine" as product_code,"Cloud Machine Learning Engine" as sku_category,"Enterprise App" as standard_usage_group,"AI/ML"as Standardized_Category UNION ALL
      SELECT "AmazonMacie" as product_code,"AWS Security Services - Macie Log Processing" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonS3" as product_code,"Fee" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonS3GlacierDeepArchive" as product_code,"" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "SnowballExtraDays" as product_code,"Extra Days" as sku_category,"Storage" as standard_usage_group,"Migration & Transfer"as Standardized_Category UNION ALL
      SELECT "AmazonCloudWatch" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "Geocoding API" as product_code,"Geocoding API" as sku_category,"Enterprise App" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonApiGateway" as product_code,"API Calls" as sku_category,"Enterprise App" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "ElasticMapReduce" as product_code,"Elastic Map Reduce Instance" as sku_category,"Compute" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "Cloud Dataflow" as product_code,"Dataflow Compute" as sku_category,"Compute" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AmazonRedshift" as product_code,"Redshift Data Scan" as sku_category,"Data Warehouse" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonEKS" as product_code,"Compute" as sku_category,"Compute" as standard_usage_group,"Containers"as Standardized_Category UNION ALL
      SELECT "awskms" as product_code,"Encryption Key" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonQuickSight" as product_code,"Business Analytics" as sku_category,"Compute" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "dxijnaemxcccba02q03mqy3o3" as product_code,"" as sku_category,"Unknown" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonRoute53" as product_code,"DNS Query" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonMSK" as product_code,"Managed Streaming for Apache Kafka (MSK)" as sku_category,"Networking" as standard_usage_group,"Migration & Transfer"as Standardized_Category UNION ALL
      SELECT "AWSConfig" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "Cloud Natural Language" as product_code,"Cloud Natural Language" as sku_category,"Enterprise App" as standard_usage_group,"AI/ML"as Standardized_Category UNION ALL
      SELECT "AWSDeviceFarm" as product_code,"Device Minutes" as sku_category,"Networking" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonApiGateway" as product_code,"Amazon API Gateway Cache" as sku_category,"Networking" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonKinesis" as product_code,"Kinesis Streams" as sku_category,"Enterprise App" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AmazonCloudFront" as product_code,"Request" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AWSGlue" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AmazonGuardDuty" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonVPC" as product_code,"Data Transfer" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonVPC" as product_code,"VpcEndpoint" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonRDS" as product_code,"Serverless" as sku_category,"Networking" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "Cloud Storage" as product_code,"GCS Download" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AWSStorageGateway" as product_code,"StorageGateway-Fee" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AmazonEC2" as product_code,"CPU Credits" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AWSCloudTrail" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonLightsail" as product_code,"Lightsail Instance" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonVPC" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonECS" as product_code,"Compute" as sku_category,"Compute" as standard_usage_group,"Containers"as Standardized_Category UNION ALL
      SELECT "AWSDatabaseMigrationSvc" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "3puu34wvr2m1k06t81ag1pee6" as product_code,"" as sku_category,"Unknown" as standard_usage_group,""as Standardized_Category UNION ALL
      SELECT "AmazonElastiCache" as product_code,"" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "awskms" as product_code,"API Request" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "Cloud DNS" as product_code,"Cloud DNS" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AWSSecurityHub" as product_code,"AWS Security Hub - Standards" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "Cloud Memorystore for Redis" as product_code,"Cloud Memorystore for Redis" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AWSDirectoryService" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonNeptune" as product_code,"Database Instance" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AWSRoboMaker" as product_code,"RoboMaker Simulation" as sku_category,"Enterprise App" as standard_usage_group,"Robotics"as Standardized_Category UNION ALL
      SELECT "AmazonRoute53" as product_code,"DNS Zone" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "Source Repository" as product_code,"Source Repository" as sku_category,"Enterprise App" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonAthena" as product_code,"Athena Queries" as sku_category,"Compute" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AmazonRedshift" as product_code,"Redshift Managed Storage" as sku_category,"Data Warehouse" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AWSServiceCatalog" as product_code,"Portfolio" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AWSLambda" as product_code,"" as sku_category,"Compute" as standard_usage_group,"Cloud Function"as Standardized_Category UNION ALL
      SELECT "AmazonSES" as product_code,"Sending Email" as sku_category,"Enterprise App" as standard_usage_group,"Customer Engagement"as Standardized_Category UNION ALL
      SELECT "AWSEvents" as product_code,"EventBridge" as sku_category,"Security & Management & Governance" as standard_usage_group,"Management & Governance"as Standardized_Category UNION ALL
      SELECT "AmazonApiGateway" as product_code,"Data Transfer" as sku_category,"Networking" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonDynamoDB" as product_code,"Database Storage" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AWSSecurityHub" as product_code,"AWS Security Hub - Findings" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonECR" as product_code,"EC2 Container Registry" as sku_category,"Networking" as standard_usage_group,"Containers"as Standardized_Category UNION ALL
      SELECT "awswaf" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonRoute53" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonApiGateway" as product_code,"" as sku_category,"Enterprise App" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonES" as product_code,"Elastic Search Volume" as sku_category,"Storage" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AmazonEFS" as product_code,"" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "datapipeline" as product_code,"Inactive Pipeline" as sku_category,"Networking" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AWSCodePipeline" as product_code,"Active Pipeline" as sku_category,"Networking" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "AmazonDynamoDB" as product_code,"Amazon DynamoDB PayPerRequest Throughput" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonKinesisFirehose" as product_code,"Kinesis Firehose" as sku_category,"Networking" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "Cloud AutoML" as product_code,"Cloud AutoML" as sku_category,"Enterprise App" as standard_usage_group,"AI/ML"as Standardized_Category UNION ALL
      SELECT "AmazonStates" as product_code,"AWS Step Functions" as sku_category,"Enterprise App" as standard_usage_group,"Application Integration"as Standardized_Category UNION ALL
      SELECT "AmazonEKS" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Containers"as Standardized_Category UNION ALL
      SELECT "AmazonDynamoDB" as product_code,"" as sku_category,"Storage" as standard_usage_group,"Database"as Standardized_Category UNION ALL
      SELECT "AmazonKinesis" as product_code,"" as sku_category,"Enterprise App" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "AWSSupportBusiness" as product_code,"" as sku_category,"Admin" as standard_usage_group,"Support"as Standardized_Category UNION ALL
      SELECT "AmazonSageMaker" as product_code,"ML Instance" as sku_category,"Enterprise App" as standard_usage_group,"AI/ML"as Standardized_Category UNION ALL
      SELECT "AmazonRegistrar" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Networking"as Standardized_Category UNION ALL
      SELECT "AmazonSNS" as product_code,"Simple Messaging Service" as sku_category,"Enterprise App" as standard_usage_group,"Notification service"as Standardized_Category UNION ALL
      SELECT "Distance Matrix API" as product_code,"Distance Matrix API" as sku_category,"Enterprise App" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "Cloud Key Management Service (KMS)" as product_code,"Cloud Key Management Service (KMS)" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "AmazonLightsail" as product_code,"" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AmazonSNS" as product_code,"API Request" as sku_category,"Enterprise App" as standard_usage_group,"Notification service"as Standardized_Category UNION ALL
      SELECT "awskms" as product_code,"" as sku_category,"Security & Management & Governance" as standard_usage_group,"Security, Identity & Compliance"as Standardized_Category UNION ALL
      SELECT "Cloud Dataflow" as product_code,"Dataflow PD" as sku_category,"Networking" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "CodeBuild" as product_code,"Compute" as sku_category,"Compute" as standard_usage_group,"Developer Tools"as Standardized_Category UNION ALL
      SELECT "BigQuery" as product_code,"BigQuery Streaming" as sku_category,"Data Warehouse" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "Cloud Document AI API" as product_code,"Cloud Document AI API" as sku_category,"Enterprise App" as standard_usage_group,"AI/ML"as Standardized_Category UNION ALL
      SELECT "AmazonQuickSight" as product_code,"" as sku_category,"Enterprise App" as standard_usage_group,"Analytics"as Standardized_Category UNION ALL
      SELECT "App Engine" as product_code,"App Engine" as sku_category,"Compute" as standard_usage_group,"Compute"as Standardized_Category UNION ALL
      SELECT "AWSBackup" as product_code,"" as sku_category,"Storage" as standard_usage_group,"Storage"as Standardized_Category UNION ALL
      SELECT "AWSQueueService" as product_code,"" as sku_category,"Networking" as standard_usage_group,"Application Integration"as Standardized_Category ;; }

      dimension: product_code {
        hidden: yes
        type: string
        sql: ${TABLE}.product_code ;;
      }
      dimension: sku_category {
        hidden: yes
        type: string
        sql: ${TABLE}.sku_category ;;
      }
      dimension: standardized_category {
        type: string
        sql: CASE WHEN ${TABLE}.standard_usage_group IS NULL OR LENGTH(${TABLE}.standard_usage_group) = 0 THEN "Other" ELSE  ${TABLE}.standard_usage_group END ;;
      }
    }
