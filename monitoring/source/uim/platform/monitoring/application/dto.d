/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.dto;

// import uim.platform.monitoring.domain.types;

import uim.platform.monitoring;

mixin(ShowModule!());

@safe:

/// --- Monitored Resource DTOs ---

struct RegisterResourceRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  string resourceType; // "javaApplication", "html5Application", etc.
  string url;
  string runtime;
  string region;
  int instanceCount;
  string[] tags;
  string registeredBy;
}

struct UpdateResourceRequest {
  string description;
  string url;
  string runtime;
  string state; // "started", "stopped", "error"
  int instanceCount;
  string[] tags;
}

/// --- Metric Definition DTOs ---

struct CreateMetricDefinitionRequest {
  TenantId tenantId;
  string name;
  string displayName;
  string description;
  string category; // "cpu", "memory", "custom", etc.
  string unit; // "percent", "bytes", "milliseconds", etc.
  string aggregation; // "average", "sum", "min", "max", "last"
  UserId createdBy;
}

struct UpdateMetricDefinitionRequest {
  string displayName;
  string description;
  string aggregation;
  bool isEnabled;
}

/// --- Metric DTOs ---

struct PushMetricRequest {
  TenantId tenantId;
  MonitoredResourceId resourceId;
  string name;
  double value_;
  string unit;
  string category;
  string[string] labels;
}

struct PushMetricBatchRequest {
  TenantId tenantId;
  PushMetricRequest[] metrics;
}

struct QueryMetricsRequest {
  TenantId tenantId;
  MonitoredResourceId resourceId;
  string metricName;
  long startTime;
  long endTime;
}

/// --- Health Check DTOs ---

struct CreateHealthCheckRequest {
  TenantId tenantId;
  MonitoredResourceId resourceId;
  string name;
  string description;
  string checkType; // "availability", "jmx", "customHttp", "process", "database", "certificate"
  int intervalSeconds;
  string url;
  string expectedStatus;
  string mbeanName;
  string mbeanAttribute;
  string customUrl;
  string expectedResponseContains;
  double warningThreshold;
  double criticalThreshold;
  string thresholdOperator;
  UserId createdBy;
}

struct UpdateHealthCheckRequest {
  string description;
  bool isEnabled;
  int intervalSeconds;
  string url;
  string expectedStatus;
  double warningThreshold;
  double criticalThreshold;
  string thresholdOperator;
}

struct RecordCheckResultRequest {
  TenantId tenantId;
  HealthCheckId checkId;
  MonitoredResourceId resourceId;
  string status; // "ok", "warning", "critical", "unknown"
  double value_;
  string message;
  int responseTimeMs;
  int httpStatusCode;
}

/// --- Alert Rule DTOs ---

struct CreateAlertRuleRequest {
  TenantId tenantId;
  MonitoredResourceId resourceId;
  string name;
  string description;
  string metricName;
  MetricDefinitionId metricDefinitionId;
  string operator_; // "greaterThan", "lessThan", etc.
  double warningThreshold;
  double criticalThreshold;
  int evaluationPeriodSeconds;
  int consecutiveBreaches;
  string severity; // "info", "warning", "critical", "fatal"
  NotificationChannelId[] channelIds;
  UserId createdBy;
}

struct UpdateAlertRuleRequest {
  string description;
  double warningThreshold;
  double criticalThreshold;
  int evaluationPeriodSeconds;
  int consecutiveBreaches;
  string severity;
  bool isEnabled;
  NotificationChannelId[] channelIds;
}

/// --- Alert DTOs ---

struct AcknowledgeAlertRequest {
  AlertId alertId;
  TenantId tenantId;
  string acknowledgedBy;
}

struct ResolveAlertRequest {
  AlertId alertId;
  TenantId tenantId;
  string resolvedBy;
}

/// --- Notification Channel DTOs ---

struct CreateNotificationChannelRequest {
  TenantId tenantId;
  string name;
  string description;
  string channelType; // "email", "webhook", "onPremise"

  // Email fields
  string[] emailRecipients;
  string emailSubjectPrefix;

  // Webhook fields
  string webhookUrl;
  string webhookSecret;
  string webhookMethod;

  // On-premise fields
  string onPremiseHost;
  int onPremisePort;
  string onPremiseProtocol;

  UserId createdBy;
}

struct UpdateNotificationChannelRequest {
  string description;
  string state; // "active", "inactive"
  string[] emailRecipients;
  string emailSubjectPrefix;
  string webhookUrl;
  string webhookSecret;
  string onPremiseHost;
  int onPremisePort;
}

/// --- Dashboard DTOs ---

struct DashboardSummary {
  long totalResources;
  long healthyResources;
  long unhealthyResources;
  long totalAlerts;
  long openAlerts;
  long criticalAlerts;
  long totalChecks;
  long failingChecks;
  long totalMetricDefinitions;
  long totalChannels;
}
