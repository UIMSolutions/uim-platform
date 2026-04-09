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

// import std.conv : to;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageAlertsUseCase : UIMUseCase {
  private AlertRepository repo;

  this(AlertRepository repo) {
    this.repo = repo;
  }

  Alert get_(AlertId id) {
    return repo.findById(id);
  }

  Alert[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Alert[] listByState(TenantId tenantId, AlertState state) {
    return repo.findByState(tenantId, state);
  }

  Alert[] listBySeverity(TenantId tenantId, AlertSeverity severity) {
    return repo.findBySeverity(tenantId, severity);
  }

  CommandResult acknowledge(AcknowledgeAlertRequest req) {
    auto a = repo.findById(req.alertId);
    if (a.id.isEmpty)
      return CommandResult(false, "", "Alert not found");

    a.state = AlertState.acknowledged;
    a.acknowledgedBy = req.acknowledgedBy;
    a.acknowledgedAt = clockSeconds();

    repo.update(a);
    return CommandResult(true, req.alertId, "");
  }

  CommandResult resolve(ResolveAlertRequest req) {
    auto a = repo.findById(req.alertId);
    if (a.id.isEmpty)
      return CommandResult(false, "", "Alert not found");

    a.state = AlertState.resolved;
    a.resolvedBy = req.resolvedBy;
    a.resolvedAt = clockSeconds();

    repo.update(a);
    return CommandResult(true, req.alertId, "");
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

    repo.save(a);
    return CommandResult(true, a.id, "");
  }

  CommandResult remove(AlertId id) {
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  long countOpen(TenantId tenantId) {
    return repo.countByState(tenantId, AlertState.open);
  }

  long countByTenant(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
