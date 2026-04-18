/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.dto;

// import uim.platform.logging.domain.types;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
// --- Log Ingestion ---

struct IngestLogRequest {
  TenantId tenantId;
  LogStreamId streamId;
  string level;
  string source;
  string message;
  string[string] structuredData;
  string traceId;
  string spanId;
  string requestId;
  string correlationId;
  string componentName;
  string spaceName;
  string orgName;
  string resourceType;
  string resourceId;
  string[] tags;
}

struct IngestLogBatchRequest {
  TenantId tenantId;
  IngestLogRequest[] entries;
}

// --- Log Stream ---

struct CreateLogStreamRequest {
  TenantId tenantId;
  string name;
  string description;
  string sourceType;
  RetentionPolicyId retentionPolicyId;
  string createdBy;
}

struct UpdateLogStreamRequest {
  string description;
  string retentionPolicyId;
  bool isActive;
}

// --- Trace / Span Ingestion ---

struct SpanEventDTO {
  string name;
  long timestamp;
  string[string] attributes;
}

struct IngestSpanRequest {
  TenantId tenantId;
  string traceId;
  string parentSpanId;
  string operationName;
  string serviceName;
  long startTime;
  long endTime;
  string status;
  string kind;
  string[string] attributes;
  SpanEventDTO[] events;
  string[string] resourceAttributes;
}

struct IngestSpanBatchRequest {
  TenantId tenantId;
  IngestSpanRequest[] spans;
}

// --- Search ---

struct SearchLogsRequest {
  TenantId tenantId;
  string query;
  string level;
  LogStreamId streamId;
  string traceId;
  string correlationId;
  long startTime;
  long endTime;
  int limit;
  int offset;
}

struct SearchLogsResponse {
  long totalCount;
}

// --- Dashboard ---

struct PanelDTO {
  string id;
  string title;
  string panelType;
  string query;
  int positionX;
  int positionY;
  int width;
  int height;
}

struct CreateDashboardRequest {
  TenantId tenantId;
  string name;
  string description;
  bool isDefault;
  PanelDTO[] panels;
  string createdBy;
}

struct UpdateDashboardRequest {
  string name;
  string description;
  bool isDefault;
  PanelDTO[] panels;
}

// --- Retention Policy ---

struct CreateRetentionPolicyRequest {
  TenantId tenantId;
  string name;
  string description;
  string dataType;
  int retentionDays;
  double maxSizeGB;
  bool isDefault;
  string createdBy;
}

struct UpdateRetentionPolicyRequest {
  string description;
  int retentionDays;
  double maxSizeGB;
  bool isDefault;
  bool isActive;
}

// --- Alert Rule ---

struct CreateAlertRuleRequest {
  TenantId tenantId;
  string name;
  string description;
  string query;
  string condition;
  string field;
  string pattern;
  double thresholdValue;
  string thresholdOperator;
  int evaluationWindowSeconds;
  string severity;
  NotificationChannelId[] channelIds;
  string createdBy;
}

struct UpdateAlertRuleRequest {
  string description;
  string query;
  string condition;
  string field;
  string pattern;
  double thresholdValue;
  string thresholdOperator;
  int evaluationWindowSeconds;
  string severity;
  bool isEnabled;
  NotificationChannelId[] channelIds;
}

// --- Alert ---

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

// --- Notification Channel ---

struct CreateNotificationChannelRequest {
  TenantId tenantId;
  string name;
  string description;
  string channelType;
  string[] emailRecipients;
  string emailSubjectPrefix;
  string webhookUrl;
  string webhookSecret;
  string webhookMethod;
  string slackWebhookUrl;
  string slackChannel;
  string createdBy;
}

struct UpdateNotificationChannelRequest {
  string description;
  string state;
  string[] emailRecipients;
  string emailSubjectPrefix;
  string webhookUrl;
  string webhookSecret;
  string slackWebhookUrl;
  string slackChannel;
}

// --- Pipeline ---

struct ProcessorDTO {
  string type;
  string name;
  string config;
  int order_;
}

struct CreatePipelineRequest {
  TenantId tenantId;
  string name;
  string description;
  string sourceType;
  string format;
  ProcessorDTO[] processors;
  LogStreamId targetStreamId;
  string createdBy;
}

struct UpdatePipelineRequest {
  string description;
  string format;
  ProcessorDTO[] processors;
  LogStreamId targetStreamId;
  bool isActive;
}

// --- Overview ---

struct OverviewSummary {
  long totalLogEntries;
  long totalSpans;
  long totalStreams;
  long totalDashboards;
  long totalAlerts;
  long openAlerts;
  long criticalAlerts;
  long totalPipelines;
  long activePipelines;
  long totalChannels;
}
