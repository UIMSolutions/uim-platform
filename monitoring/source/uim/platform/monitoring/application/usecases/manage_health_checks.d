/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.health_checks;

import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.domain.entities.health_check;
import uim.platform.monitoring.domain.entities.health_check_result;
import uim.platform.monitoring.domain.ports.repositories.health_checks;
import uim.platform.monitoring.domain.ports.repositories.health_check_results;
import uim.platform.monitoring.domain.services.health_checker;
import uim.platform.monitoring.domain.types;

// import std.conv : to;

/// Application service for health check CRUD and result recording.
class ManageHealthChecksUseCase
{
  private HealthCheckRepository checkRepo;
  private HealthCheckResultRepository resultRepo;

  this(HealthCheckRepository checkRepo, HealthCheckResultRepository resultRepo)
  {
    this.checkRepo = checkRepo;
    this.resultRepo = resultRepo;
  }

  CommandResult createCheck(CreateHealthCheckRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Check name is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    HealthCheck c;
    c.id = id;
    c.tenantId = req.tenantId;
    c.resourceId = req.resourceId;
    c.name = req.name;
    c.description = req.description;
    c.checkType = parseCheckType(req.checkType);
    c.isEnabled = true;
    c.intervalSeconds = req.intervalSeconds > 0 ? req.intervalSeconds : 60;
    c.url = req.url;
    c.expectedStatus = req.expectedStatus;
    c.mbeanName = req.mbeanName;
    c.mbeanAttribute = req.mbeanAttribute;
    c.customUrl = req.customUrl;
    c.expectedResponseContains = req.expectedResponseContains;
    c.warningThreshold = req.warningThreshold;
    c.criticalThreshold = req.criticalThreshold;
    c.thresholdOperator = parseThresholdOperator(req.thresholdOperator);
    c.createdBy = req.createdBy;
    c.createdAt = clockSeconds();
    c.updatedAt = c.createdAt;

    auto validation = HealthChecker.validate(c);
    if (!validation.valid)
    {
      string msg = "Validation failed: ";
      foreach (i, e; validation.errors)
      {
        if (i > 0)
          msg ~= "; ";
        msg ~= e;
      }
      return CommandResult(false, "", msg);
    }

    checkRepo.save(c);
    return CommandResult(true, id, "");
  }

  CommandResult updateCheck(HealthCheckId id, UpdateHealthCheckRequest req)
  {
    auto c = checkRepo.findById(id);
    if (c.id.length == 0)
      return CommandResult(false, "", "Health check not found");

    if (req.description.length > 0)
      c.description = req.description;
    c.isEnabled = req.isEnabled;
    if (req.intervalSeconds > 0)
      c.intervalSeconds = req.intervalSeconds;
    if (req.url.length > 0)
      c.url = req.url;
    if (req.expectedStatus.length > 0)
      c.expectedStatus = req.expectedStatus;
    if (req.warningThreshold != 0)
      c.warningThreshold = req.warningThreshold;
    if (req.criticalThreshold != 0)
      c.criticalThreshold = req.criticalThreshold;
    if (req.thresholdOperator.length > 0)
      c.thresholdOperator = parseThresholdOperator(req.thresholdOperator);
    c.updatedAt = clockSeconds();

    checkRepo.update(c);
    return CommandResult(true, id, "");
  }

  CommandResult recordResult(RecordCheckResultRequest req)
  {
    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    HealthCheckResult r;
    r.id = id;
    r.tenantId = req.tenantId;
    r.checkId = req.checkId;
    r.resourceId = req.resourceId;
    r.status = parseCheckStatus(req.status);
    r.value_ = req.value_;
    r.message = req.message;
    r.responseTimeMs = req.responseTimeMs;
    r.httpStatusCode = req.httpStatusCode;
    r.executedAt = clockSeconds();

    resultRepo.save(r);
    return CommandResult(true, id, "");
  }

  HealthCheck getCheck(HealthCheckId id)
  {
    return checkRepo.findById(id);
  }

  HealthCheck[] listChecks(TenantId tenantId)
  {
    return checkRepo.findByTenant(tenantId);
  }

  HealthCheck[] listByResource(TenantId tenantId, MonitoredResourceId resourceId)
  {
    return checkRepo.findByResource(tenantId, resourceId);
  }

  HealthCheck[] listByType(TenantId tenantId, string typeStr)
  {
    return checkRepo.findByType(tenantId, parseCheckType(typeStr));
  }

  HealthCheckResult[] getResults(TenantId tenantId, HealthCheckId checkId)
  {
    return resultRepo.findByCheck(tenantId, checkId);
  }

  HealthCheckResult getLatestResult(TenantId tenantId, HealthCheckId checkId)
  {
    return resultRepo.findLatestByCheck(tenantId, checkId);
  }

  CommandResult deleteCheck(HealthCheckId id)
  {
    auto c = checkRepo.findById(id);
    if (c.id.length == 0)
      return CommandResult(false, "", "Health check not found");

    checkRepo.remove(id);
    return CommandResult(true, id, "");
  }

  private static long clockSeconds()
  {
    // import std.datetime.systime : Clock;
    return Clock.currTime().toUnixTime();
  }

  private static CheckType parseCheckType(string s)
  {
    switch (s)
    {
    case "jmx":
      return CheckType.jmx;
    case "customHttp":
      return CheckType.customHttp;
    case "process":
      return CheckType.process;
    case "database":
      return CheckType.database;
    case "certificate":
      return CheckType.certificate;
    default:
      return CheckType.availability;
    }
  }

  private static CheckStatus parseCheckStatus(string s)
  {
    switch (s)
    {
    case "ok":
      return CheckStatus.ok;
    case "warning":
      return CheckStatus.warning;
    case "critical":
      return CheckStatus.critical;
    case "disabled":
      return CheckStatus.disabled;
    default:
      return CheckStatus.unknown;
    }
  }

  private static ThresholdOperator parseThresholdOperator(string s)
  {
    switch (s)
    {
    case "greaterOrEqual":
      return ThresholdOperator.greaterOrEqual;
    case "lessThan":
      return ThresholdOperator.lessThan;
    case "lessOrEqual":
      return ThresholdOperator.lessOrEqual;
    case "equal":
      return ThresholdOperator.equal;
    case "notEqual":
      return ThresholdOperator.notEqual;
    default:
      return ThresholdOperator.greaterThan;
    }
  }
}
