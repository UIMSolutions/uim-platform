module uim.platform.monitoring.domain.entities.health_check;

import uim.platform.monitoring.domain.types;

/// Configuration for a health or availability check.
struct HealthCheck
{
    HealthCheckId id;
    TenantId tenantId;
    MonitoredResourceId resourceId;
    string name;
    string description;
    CheckType checkType = CheckType.availability;
    bool isEnabled = true;
    int intervalSeconds = 60;

    /// For availability checks: HTTP endpoint to probe.
    string url;
    string expectedStatus;

    /// For JMX checks: MBean object name and attribute.
    string mbeanName;
    string mbeanAttribute;

    /// For custom HTTP checks: the custom URL and expected response.
    string customUrl;
    string expectedResponseContains;

    /// Thresholds for warning and critical states.
    double warningThreshold = 0;
    double criticalThreshold = 0;
    ThresholdOperator thresholdOperator = ThresholdOperator.greaterThan;

    string createdBy;
    long createdAt;
    long updatedAt;
}
