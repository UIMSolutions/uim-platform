module uim.platform.xyz.domain.entities.alert;

import domain.types;

/// An active or resolved alert triggered by a rule breach.
struct Alert
{
    AlertId id;
    TenantId tenantId;
    AlertRuleId ruleId;
    MonitoredResourceId resourceId;
    string ruleName;
    string metricName;
    double currentValue;
    double thresholdValue;
    ThresholdOperator operator_;
    AlertSeverity severity = AlertSeverity.warning;
    AlertState state = AlertState.open;
    string message;
    string acknowledgedBy;
    string resolvedBy;
    long triggeredAt;
    long acknowledgedAt;
    long resolvedAt;
}
