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
class ManageAlertsUseCase {
  protected IAlertRepository repo;

  this(IAlertRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createAlert(CreateAlertRequest r) {
    if (r.isNull || r.name.isEmpty)
      return UsecaseResult(false, "", "Alert ID and name are required");

    auto existing = repo.findById(r.tenantId, r.id);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Alert already exists");

    auto a = Alert(r.tenantId, r.alertId);
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
    return UsecaseResult(true, a.id.value, "");
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

  UsecaseResult acknowledgeAlert(AcknowledgeAlertRequest r) {
    auto existing = repo.findById(r.tenantId, r.alertId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Alert not found");

    existing.status = AlertStatus.acknowledged;
    existing.acknowledgedBy = r.acknowledgedBy;

    

    existing.acknowledgedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UsecaseResult updateAlert(UpdateAlertRequest r) {
    auto existing = repo.findById(r.tenantId, r.alertId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Alert not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.threshold.warningValue = r.warningValue;
    existing.threshold.criticalValue = r.criticalValue;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UsecaseResult deleteAlert(TenantId tenantId, AlertId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Alert not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  size_t countAlerts(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
