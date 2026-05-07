/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.alerts;

// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.ports.repositories.alerts;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;


import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageAlertsUseCase : TenantUseCase!(AlertRepository, Alert, AlertId) { 
  this(AlertRepository repository) {
    super(repository);
  }

  Alert[] listByState(TenantId tenantId, AlertState state) {
    return repository.findByState(tenantId, state);
  }

  Alert[] listBySeverity(TenantId tenantId, AlertSeverity severity) {
    return repository.findBySeverity(tenantId, severity);
  }

  CommandResult acknowledge(AcknowledgeAlertRequest req) {
    auto a = repository.findById(req.alertId);
    if (a.isNull)
      return CommandResult(false, "", "Alert not found");

    a.state = AlertState.acknowledged;
    a.acknowledgedBy = req.acknowledgedBy;
    a.acknowledgedAt = clockSeconds();

    repository.update(a);
    return CommandResult(true, req.alertId.value, "");
  }

  CommandResult resolve(ResolveAlertRequest req) {
    auto a = repository.findById(req.alertId);
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
    a.id = randomUUID();
    a.tenantId = tenantId;
    a.ruleId = ruleId;
    a.ruleName = ruleName;
    a.severity = severity;
    a.state = AlertState.open;
    a.message = message;
    a.matchCount = matchCount;
    a.sampleLogEntryId = sampleId;
    a.triggeredAt = clockSeconds();

    repository.save(a);
    return CommandResult(true, a.id.value, "");
  }

  CommandResult deleteAlert(TenantId tenantId, AlertId id) {
    auto alert = repository.findById(tenantId, id);
    if (alert.isNull)      
      return CommandResult(false, "", "Alert not found");

    repository.removeById(tenantId, id);
    return CommandResult(true, alert.id.value, "");
  }

  size_t countOpen(TenantId tenantId) {
    return repository.countByState(tenantId, AlertState.open);
  }

  size_t countByTenant(TenantId tenantId) {
    return repository.countByTenant(tenantId);
  }
}
