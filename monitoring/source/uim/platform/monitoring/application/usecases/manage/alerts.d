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
  private AlertRepository repo;

  this(AlertRepository repo) {
    this.repo = repo;
  }

  bool existsAlert(string id) {
    return existsById(AlertId(id));
  }

  bool existsAlert(AlertId id) {
    return repo.existsById(id);
  }

  Alert getAlert(string id) {
    return getAlert(AlertId(id));
  }

  Alert getAlert(AlertId id) {
    return repo.findById(id);
  }

  Alert[] listAlerts(TenantId tenantId) {
    return listAlerts(TenantId(tenantId));
  }

  Alert[] listAlerts(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Alert[] listByState(TenantId tenantId, string stateStr) {
    return listByState(TenantId(tenantId), stateStr);
  }

  Alert[] listByState(TenantId tenantId, string stateStr) {
    return repo.findByState(tenantId, parseAlertState(stateStr));
  }

  Alert[] listBySeverity(TenantId tenantId, string severityStr) {
    return listBySeverity(TenantId(tenantId), severityStr);
  }

  Alert[] listBySeverity(TenantId tenantId, string severityStr) {
    return repo.findBySeverity(tenantId, parseSeverity(severityStr));
  }

  Alert[] listByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return repo.findByResource(tenantId, resourceId);
  }

  CommandResult acknowledgeAlert(AcknowledgeAlertRequest req) {
    if (!repo.existsById(req.alertId))
      return CommandResult(false, "", "Alert not found");

    auto alert = repo.findById(req.alertId);
    if (alert.state != AlertState.open)
      return CommandResult(false, "", "Alert is not in open state");

    alert.state = AlertState.acknowledged;
    alert.acknowledgedBy = req.acknowledgedBy;
    alert.acknowledgedAt = clockSeconds();

    repo.update(alert);
    return CommandResult(true, req.alertid.value, "");
  }

  CommandResult resolveAlert(ResolveAlertRequest req) {
    if (!repo.existsById(req.alertId))
      return CommandResult(false, "", "Alert not found");

    auto alert = repo.findById(req.alertId); 
    if (alert.state == AlertState.resolved)
      return CommandResult(false, "", "Alert is already resolved");

    alert.state = AlertState.resolved;
    alert.resolvedBy = req.resolvedBy;
    alert.resolvedAt = clockSeconds();

    repo.update(alert);
    return CommandResult(true, req.alertid.value, "");
  }

  CommandResult deleteAlert(string id) {
    return deleteAlert(AlertId(id));
  }

  CommandResult deleteAlert(AlertId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Alert not found");

    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }

  /// Create an alert (used by the evaluate_metrics use case).
  CommandResult triggerAlert(TenantId tenantId, AlertRuleId ruleId,
      MonitoredResourceId resourceId, string ruleName, string metricName,
      double currentValue, double thresholdValue, ThresholdOperator op,
      AlertSeverity severity, string message) {
    // import std.uuid : randomUUID;
    auto id = randomUUID();

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
    return CommandResult(true, id.value, "");
  }

  private static AlertState parseAlertState(string state) {
    switch (state) {
    case "acknowledged":
      return AlertState.acknowledged;
    case "resolved":
      return AlertState.resolved;
    case "expired":
      return AlertState.expired;
    default:
      return AlertState.open;
    }
  }

  private static AlertSeverity parseSeverity(string severity) {
    switch (severity) {
    case "info":
      return AlertSeverity.info;
    case "critical":
      return AlertSeverity.critical;
    case "fatal":
      return AlertSeverity.fatal;
    default:
      return AlertSeverity.warning;
    }
  }
}
