module uim.platform.xyz.application.usecases.manage_alerts;

import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.alert;
import uim.platform.xyz.domain.ports.alert_repository;
import uim.platform.xyz.domain.types;

import std.conv : to;

/// Application service for alert lifecycle management (list, acknowledge, resolve).
class ManageAlertsUseCase
{
    private AlertRepository repo;

    this(AlertRepository repo)
    {
        this.repo = repo;
    }

    Alert getAlert(AlertId id)
    {
        return repo.findById(id);
    }

    Alert[] listAlerts(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    Alert[] listByState(TenantId tenantId, string stateStr)
    {
        return repo.findByState(tenantId, parseAlertState(stateStr));
    }

    Alert[] listBySeverity(TenantId tenantId, string severityStr)
    {
        return repo.findBySeverity(tenantId, parseSeverity(severityStr));
    }

    Alert[] listByResource(TenantId tenantId, MonitoredResourceId resourceId)
    {
        return repo.findByResource(tenantId, resourceId);
    }

    CommandResult acknowledgeAlert(AcknowledgeAlertRequest req)
    {
        auto alert = repo.findById(req.alertId);
        if (alert.id.length == 0)
            return CommandResult(false, "", "Alert not found");

        if (alert.state != AlertState.open)
            return CommandResult(false, "", "Alert is not in open state");

        alert.state = AlertState.acknowledged;
        alert.acknowledgedBy = req.acknowledgedBy;
        alert.acknowledgedAt = clockSeconds();

        repo.update(alert);
        return CommandResult(true, req.alertId, "");
    }

    CommandResult resolveAlert(ResolveAlertRequest req)
    {
        auto alert = repo.findById(req.alertId);
        if (alert.id.length == 0)
            return CommandResult(false, "", "Alert not found");

        if (alert.state == AlertState.resolved)
            return CommandResult(false, "", "Alert is already resolved");

        alert.state = AlertState.resolved;
        alert.resolvedBy = req.resolvedBy;
        alert.resolvedAt = clockSeconds();

        repo.update(alert);
        return CommandResult(true, req.alertId, "");
    }

    CommandResult deleteAlert(AlertId id)
    {
        auto alert = repo.findById(id);
        if (alert.id.length == 0)
            return CommandResult(false, "", "Alert not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }

    /// Create an alert (used by the evaluate_metrics use case).
    CommandResult triggerAlert(TenantId tenantId, AlertRuleId ruleId, MonitoredResourceId resourceId,
        string ruleName, string metricName, double currentValue, double thresholdValue,
        ThresholdOperator op, AlertSeverity severity, string message)
    {
        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        Alert a;
        a.id = id;
        a.tenantId = tenantId;
        a.ruleId = ruleId;
        a.resourceId = resourceId;
        a.ruleName = ruleName;
        a.metricName = metricName;
        a.currentValue = currentValue;
        a.thresholdValue = thresholdValue;
        a.operator_ = op;
        a.severity = severity;
        a.state = AlertState.open;
        a.message = message;
        a.triggeredAt = clockSeconds();

        repo.save(a);
        return CommandResult(true, id, "");
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }

    private static AlertState parseAlertState(string s)
    {
        switch (s)
        {
            case "acknowledged": return AlertState.acknowledged;
            case "resolved":     return AlertState.resolved;
            case "expired":      return AlertState.expired;
            default:             return AlertState.open;
        }
    }

    private static AlertSeverity parseSeverity(string s)
    {
        switch (s)
        {
            case "info":        return AlertSeverity.info;
            case "critical":    return AlertSeverity.critical;
            case "fatal":       return AlertSeverity.fatal;
            default:            return AlertSeverity.warning;
        }
    }
}
