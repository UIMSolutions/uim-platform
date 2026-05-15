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



import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageAlertsUseCase { // TODO: UIMUseCase {
  private AlertRepository repo;

  this(AlertRepository repo) {
    this.repo = repo;
  }

  CommandResult createAlert(CreateAlertRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Alert ID and name are required");

    auto existing = repo.findById(r.tenantId, r.id);
    if (!existing.isNull)
      return CommandResult(false, "", "Alert already exists");

    Alert a;
    a.initEntity(r.tenantId);
    a.id = r.alertId;
    a.instanceId = r.instanceId;
    a.name = r.name;
    a.description = r.description;
    a.status = AlertStatus.active;
    a.metricName = r.metricName;

    a.threshold.metric = r.metricName;
    a.threshold.warningValue = r.warningValue;
    a.threshold.criticalValue = r.criticalValue;
    a.threshold.unit = r.unit;

    repo.save(a);
    return CommandResult(true, a.id.value, "");
  }

  Alert getAlertById(TenantId tenantId, AlertId id) {
    return repo.findById(tenantId, id);
  }

  Alert[] listAlerts(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Alert[] listActiveAlerts(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult acknowledgeAlert(AcknowledgeAlertRequest r) {
    auto existing = repo.findById(r.tenantId, r.alertId);
    if (existing.isNull)
      return CommandResult(false, "", "Alert not found");

    existing.status = AlertStatus.acknowledged;
    existing.acknowledgedBy = r.acknowledgedBy;

    import core.time : MonoTime;

    existing.acknowledgedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult updateAlert(UpdateAlertRequest r) {
    auto existing = repo.findById(r.tenantId, r.alertId);
    if (existing.isNull)
      return CommandResult(false, "", "Alert not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.threshold.warningValue = r.warningValue;
    existing.threshold.criticalValue = r.criticalValue;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteAlert(TenantId tenantId, AlertId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Alert not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countAlerts(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
