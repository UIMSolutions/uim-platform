module uim.platform.monitoring.domain.entities.alert_rule;

import uim.platform.monitoring.domain.types;

/// An alert rule that defines thresholds for triggering alerts.
struct AlertRule
{
    AlertRuleId id;
    TenantId tenantId;
    MonitoredResourceId resourceId;
    string name;
    string description;
    string metricName;
    MetricDefinitionId metricDefinitionId;
    ThresholdOperator operator_ = ThresholdOperator.greaterThan;
    double warningThreshold;
    double criticalThreshold;
    int evaluationPeriodSeconds = 300;
    int consecutiveBreaches = 1;
    AlertSeverity severity = AlertSeverity.warning;
    bool isEnabled = true;
    NotificationChannelId[] channelIds;
    string createdBy;
    long createdAt;
    long updatedAt;
}
