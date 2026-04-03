/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.use_cases.manage_retention_policies;

import uim.platform.logging.domain.entities.retention_policy;
import uim.platform.logging.domain.ports.retention_policy_repository;
import uim.platform.logging.domain.services.retention_evaluator;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

import std.conv : to;

class ManageRetentionPoliciesUseCase {
  private RetentionPolicyRepository repo;

  this(RetentionPolicyRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateRetentionPolicyRequest req) {
    import std.uuid : randomUUID;

    RetentionPolicy p;
    p.id = randomUUID().to!string;
    p.tenantId = req.tenantId;
    p.name = req.name;
    p.description = req.description;
    p.dataType = parseDataType(req.dataType);
    p.retentionDays = (req.retentionDays > 0) ? req.retentionDays : 30;
    p.maxSizeGB = (req.maxSizeGB > 0) ? req.maxSizeGB : 10.0;
    p.isDefault = req.isDefault;
    p.isActive = true;
    p.createdBy = req.createdBy;
    p.createdAt = clockSeconds();

    auto validation = RetentionEvaluator.validate(p);
    if (!validation.valid) {
      string msg;
      foreach (e; validation.errors)
        msg ~= e ~ "; ";
      return CommandResult(false, "", msg);
    }

    repo.save(p);
    return CommandResult(true, p.id, "");
  }

  CommandResult update(RetentionPolicyId id, UpdateRetentionPolicyRequest req) {
    auto p = repo.findById(id);
    if (p.id.length == 0)
      return CommandResult(false, "", "Retention policy not found");

    if (req.description.length > 0)
      p.description = req.description;
    if (req.retentionDays > 0)
      p.retentionDays = req.retentionDays;
    if (req.maxSizeGB > 0)
      p.maxSizeGB = req.maxSizeGB;
    p.isDefault = req.isDefault;
    p.isActive = req.isActive;
    p.updatedAt = clockSeconds();

    repo.update(p);
    return CommandResult(true, id, "");
  }

  RetentionPolicy get_(RetentionPolicyId id) {
    return repo.findById(id);
  }

  RetentionPolicy[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(RetentionPolicyId id) {
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private static DataType parseDataType(string s) {
    switch (s) {
    case "logs":
      return DataType.logs;
    case "metrics":
      return DataType.metrics;
    case "traces":
      return DataType.traces;
    default:
      return DataType.all;
    }
  }

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
