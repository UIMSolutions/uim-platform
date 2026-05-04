/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.health_checks;

// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.ports.repositories.health_checks;
// import uim.platform.monitoring.domain.ports.repositories.health_check_results;
// import uim.platform.monitoring.domain.services.health_checker;
// import uim.platform.monitoring.domain.types;

// // import std.conv : to;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Application service for health check CRUD and result recording.
class ManageHealthChecksUseCase { // TODO: UIMUseCase {
  private HealthCheckRepository checkRepo;
  private HealthCheckResultRepository resultRepo;

  this(HealthCheckRepository checkRepo, HealthCheckResultRepository resultRepo) {
    this.checkRepo = checkRepo;
    this.resultRepo = resultRepo;
  }

  CommandResult createCheck(CreateHealthCheckRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Check name is required");

    HealthCheck check;
    check.id = randomUUID();
    check.tenantId = req.tenantId;
    check.resourceId = req.resourceId;
    check.name = req.name;
    check.description = req.description;
    check.checkType = req.checkType.to!CheckType;
    check.isEnabled = true;
    check.intervalSeconds = req.intervalSeconds > 0 ? req.intervalSeconds : 60;
    check.url = req.url;
    check.expectedStatus = req.expectedStatus;
    check.mbeanName = req.mbeanName;
    check.mbeanAttribute = req.mbeanAttribute;
    check.customUrl = req.customUrl;
    check.expectedResponseContains = req.expectedResponseContains;
    check.warningThreshold = req.warningThreshold;
    check.criticalThreshold = req.criticalThreshold;
    check.thresholdOperator = parseThresholdOperator(req.thresholdOperator);
    check.createdBy = req.createdBy;
    check.createdAt = clockSeconds();
    check.updatedAt = check.createdAt;

    auto validation = HealthChecker.validate(check);
    if (!validation.valid) {
      string msg = "Validation failed: ";
      foreach (i, e; validation.errors) {
        if (i > 0)
          msg ~= "; ";
        msg ~= e;
      }
      return CommandResult(false, "", msg);
    }

    checkRepo.save(check);
    return CommandResult(true, check.id.value, "");
  }

  CommandResult updateCheck(string id, UpdateHealthCheckRequest req) {
    return updateCheck(HealthCheckId(id), req);
  }

  CommandResult updateCheck(HealthCheckId id, UpdateHealthCheckRequest req) {
    auto check = checkRepo.findById(id);
    if (check.isNull)
      return CommandResult(false, "", "Health check not found");

    if (req.description.length > 0)
      check.description = req.description;
    check.isEnabled = req.isEnabled;
    if (req.intervalSeconds > 0)
      check.intervalSeconds = req.intervalSeconds;
    if (req.url.length > 0)
      check.url = req.url;
    if (req.expectedStatus.length > 0)
      check.expectedStatus = req.expectedStatus;
    if (req.warningThreshold != 0)
      check.warningThreshold = req.warningThreshold;
    if (req.criticalThreshold != 0)
      check.criticalThreshold = req.criticalThreshold;
    if (req.thresholdOperator.length > 0)
      check.thresholdOperator = req.thresholdOperator.to!ThresholdOperator;
    check.updatedAt = clockSeconds();

    checkRepo.update(check);
    return CommandResult(true, id.value, "");
  }

  CommandResult recordResult(RecordCheckResultRequest req) {
    // import std.uuid : randomUUID;
    auto id = randomUUID();

    HealthCheckResult r;
    r.id = id;
    r.tenantId = req.tenantId;
    r.checkId = req.checkId;
    r.resourceId = req.resourceId;
    r.status = req.status.to!CheckStatus;
    r.value_ = req.value_;
    r.message = req.message;
    r.responseTimeMs = req.responseTimeMs;
    r.httpStatusCode = req.httpStatusCode;
    r.executedAt = clockSeconds();

    resultRepo.save(r);
    return CommandResult(true, id.value, "");
  }

  HealthCheck getCheck(HealthCheckId id) {
    return checkRepo.findById(id);
  }

  HealthCheck[] listChecks(TenantId tenantId) {
    return checkRepo.findByTenant(tenantId);
  }

  HealthCheck[] listByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return checkRepo.findByResource(tenantId, resourceId);
  }

  HealthCheck[] listByType(TenantId tenantId, string typeStr) {
    return checkRepo.findByType(tenantId, typeStr.to!CheckType);
  }

  HealthCheckResult[] getResults(TenantId tenantId, HealthCheckId checkId) {
    return resultRepo.findByCheck(tenantId, checkId);
  }

  HealthCheckResult getLatestResult(TenantId tenantId, HealthCheckId checkId) {
    return resultRepo.findLatestByCheck(tenantId, checkId);
  }

  CommandResult deleteCheck(HealthCheckId id) {
    if (!checkRepo.existsById(id))
      return CommandResult(false, "", "Health check not found");

    checkRepo.removeById(id);
    return CommandResult(true, id.value, "");
  }

}
