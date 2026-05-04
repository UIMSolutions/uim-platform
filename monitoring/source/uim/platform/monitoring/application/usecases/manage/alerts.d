/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.alerts;

// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert;
// import uim.platform.monitoring.domain.ports.repositories.alerts;
// import uim.platform.monitoring.domain.types;

// // import std.conv : to;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Application service for alert lifecycle management (list, acknowledge, resolve).
class ManageAlertsUseCase { // TODO: UIMUseCase {
  private AlertRepository alerts;

  this(AlertRepository alerts) {
    this.alerts = alerts;
  }

  bool existsAlert(AlertId id) {
    return alerts.existsById(id);
  }

  Alert getAlert(AlertId id) {
    return alerts.findById(id);
  }

  Alert[] listAlerts(TenantId tenantId) {
    return alerts.findByTenant(tenantId);
  }

  Alert[] listByState(TenantId tenantId, AlertState state) {
    return alerts.findByState(tenantId, state);
  }

  Alert[] listBySeverity(TenantId tenantId, AlertSeverity severity) {
    return alerts.findBySeverity(tenantId, severity);
  }

  Alert[] listByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return alerts.findByResource(tenantId, resourceId);
  }

  CommandResult acknowledgeAlert(AcknowledgeAlertRequest req) {
    auto alert = alerts.findById(req.alertId);
    if (alert.isNull)
      return CommandResult(false, "", "Alert not found");

    if (alert.state != AlertState.open)
      return CommandResult(false, "", "Alert is not in open state");

    alert.state = AlertState.acknowledged;
    alert.acknowledgedBy = req.acknowledgedBy;
    alert.acknowledgedAt = clockSeconds();

    alerts.update(alert);
    return CommandResult(true, alert.id.value, "");
  }

  CommandResult resolveAlert(ResolveAlertRequest req) {
    auto alert = alerts.findById(req.alertId);
    if (alert.isNull)
      return CommandResult(false, "", "Alert not found");

    if (alert.state == AlertState.resolved)
      return CommandResult(false, "", "Alert is already resolved");

    alert.state = AlertState.resolved;
    alert.resolvedBy = req.resolvedBy;
    alert.resolvedAt = clockSeconds();

    alerts.update(alert);
    return CommandResult(true, alert.id.value, "");
  }

  CommandResult deleteAlert(AlertId id) {
    auto alert = alerts.findById(id);
    if (alert.isNull)
      return CommandResult(false, "", "Alert not found");

    alerts.removeById(id);
    return CommandResult(true, alert.id.value, "");
  }

  /// Create an alert (used by the evaluate_metrics use case).
  CommandResult triggerAlert(TenantId tenantId, AlertRuleId ruleId,
      MonitoredResourceId resourceId, string ruleName, string metricName,
      double currentValue, double thresholdValue, ThresholdOperator op,
      AlertSeverity severity, string message) {
    // import std.uuid : randomUUID;
    auto id = randomUUID();

    Alert alert;
    alert.id = id;
    alert.tenantId = tenantId;
    alert.ruleId = ruleId;
    alert.resourceId = resourceId;
    alert.ruleName = ruleName;
    alert.metricName = metricName;
    alert.currentValue = currentValue;
    alert.thresholdValue = thresholdValue;
    alert.operator_ = op;
    alert.severity = severity;
    alert.state = AlertState.open;
    alert.message = message;
    alert.triggeredAt = clockSeconds();

    alerts.save(alert);
    return CommandResult(true, alert.id.value, "");
  }


}
