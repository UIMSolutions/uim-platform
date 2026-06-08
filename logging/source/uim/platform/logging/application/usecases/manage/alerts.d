/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.alerts;
// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.ports.repositories.alerts;

import uim.platform.logging;

// mixin(ShowModule!());

@safe:
class ManageAlertsUseCase : TenantUseCase!(AlertRepository, Alert, AlertId) {
  this(AlertRepository repository) {
    super(repository);
  }

  size_t countOpen(TenantId tenantId) {
    return repository.countByState(tenantId, AlertState.open);
  }

  size_t countByTenant(TenantId tenantId) {
    return repository.countByTenant(tenantId);
  }

  Alert[] listAlerts(TenantId tenantId, AlertState state) {
    return repository.findByState(tenantId, state);
  }

  Alert[] listAlerts(TenantId tenantId, AlertSeverity severity) {
    return repository.findBySeverity(tenantId, severity);
  }

  CommandResult acknowledgeAlert(AcknowledgeAlertRequest req) {
    auto a = repository.findById(req.tenantId, req.alertId);
    if (a.isNull)
      return CommandResult(false, "", "Alert not found");

    a.state = AlertState.acknowledged;
    a.acknowledgedBy = req.acknowledgedBy;
    a.acknowledgedAt = clockSeconds();

    repository.update(a);
    return CommandResult(true, req.alertId.value, "");
  }

  CommandResult resolveAlert(ResolveAlertRequest req) {
    auto a = repository.findById(req.tenantId, req.alertId);
    if (a.isNull)
      return CommandResult(false, "", "Alert not found");

    a.state = AlertState.resolved;
    a.resolvedBy = req.resolvedBy;
    a.resolvedAt = clockSeconds();

    repository.update(a);
    return CommandResult(true, req.alertId.value, "");
  }

  CommandResult triggerAlert(TenantId tenantId, AlertRuleId ruleId, string ruleName,
    AlertSeverity severity, string message, long matchCount, LogEntryId sampleId) {
    import std.uuid : randomUUID;

    Alert a;
    a.initEntity(tenantId);
    a.ruleId = ruleId;
    a.ruleName = ruleName;
    a.severity = severity;
    a.state = AlertState.open;
    a.message = message;
    a.matchCount = matchCount;
    a.sampleLogEntryId = sampleId;

    repository.save(a);
    return CommandResult(true, a.id.value, "");
  }

  CommandResult deleteAlert(TenantId tenantId, AlertId id) {
    auto alert = repository.findById(tenantId, id);
    if (alert.isNull)
      return CommandResult(false, "", "Alert not found");

    repository.remove(alert);
    return CommandResult(true, alert.id.value, "");
  }

}

unittest {
  auto repo = new MemoryAlertRepository();
  auto usecase = new ManageAlertsUseCase(repo);
  auto tenantId = TenantId("test-tenant");

  // Trigger an alert
  usecase.triggerAlert(tenantId, AlertRuleId("rule-1"), "High CPU", 
    AlertSeverity.critical, "CPU usage over 90%", 1, LogEntryId("log-123"));

  assert(usecase.countByTenant(tenantId) == 1);
  assert(usecase.countOpen(tenantId) == 1);

  auto alerts = usecase.listAlerts(tenantId, AlertState.open);
  assert(alerts.length == 1);
  auto alertId = alerts[0].id;

  // Acknowledge the alert
  AcknowledgeAlertRequest ackReq;
  ackReq.tenantId = tenantId;
  ackReq.alertId = alertId;
  ackReq.acknowledgedBy = "operator-1";
  usecase.acknowledgeAlert(ackReq);

  assert(usecase.countOpen(tenantId) == 0);

  // Resolve the alert
  ResolveAlertRequest resReq;
  resReq.tenantId = tenantId;
  resReq.alertId = alertId;
  resReq.resolvedBy = "operator-1";
  usecase.resolveAlert(resReq);

  auto alert = repo.findById(tenantId, alertId);
  assert(alert.state == AlertState.resolved);
}
