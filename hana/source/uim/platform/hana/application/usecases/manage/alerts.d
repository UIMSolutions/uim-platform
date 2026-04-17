/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.alerts;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.alert;
// import uim.platform.hana.domain.ports.repositories.alerts;
// import uim.platform.hana.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageAlertsUseCase : UIMUseCase {
  private AlertRepository repo;

  this(AlertRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateAlertRequest r) {
    if (r.id.isEmpty || r.name.length == 0)
      return CommandResult(false, "", "Alert ID and name are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "Alert already exists");

    Alert a;
    a.id = r.id;
    a.tenantId = r.tenantId;
    a.instanceId = r.instanceId;
    a.name = r.name;
    a.description = r.description;
    a.status = AlertStatus.active;
    a.metricName = r.metricName;

    a.threshold.metric = r.metricName;
    a.threshold.warningValue = r.warningValue;
    a.threshold.criticalValue = r.criticalValue;
    a.threshold.unit = r.unit;

    import core.time : MonoTime;

    a.createdAt = MonoTime.currTime.ticks;
    a.triggeredAt = a.createdAt;

    repo.save(a);
    return CommandResult(true, a.id, "");
  }

  Alert getById(AlertId id) {
    return repo.findById(id);
  }

  Alert[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Alert[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult acknowledge(AcknowledgeAlertRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Alert not found");

    auto existing = repo.findById(r.id);
    existing.status = AlertStatus.acknowledged;
    existing.acknowledgedBy = r.acknowledgedBy;

    import core.time : MonoTime;

    existing.acknowledgedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult update(UpdateAlertRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Alert not found");

    auto existing = repo.findById(r.id);
    existing.name = r.name;
    existing.description = r.description;
    existing.threshold.warningValue = r.warningValue;
    existing.threshold.criticalValue = r.criticalValue;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(AlertId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Alert not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
