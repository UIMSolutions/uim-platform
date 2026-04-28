/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.application.usecases.manage.transformations;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.transformation;
import uim.platform.identity.provisioning.domain.ports.repositories.transformations;
import uim.platform.identity.provisioning.domain.services.transformation_engine;
import uim.platform.identity.provisioning.application.dto;

class ManageTransformationsUseCase { // TODO: UIMUseCase {
  private TransformationRepository repo;
  private TransformationEngine engine;

  this(TransformationRepository repo, TransformationEngine engine) {
    this.repo = repo;
    this.engine = engine;
  }

  CommandResult createTransformation(CreateTransformationRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.systemId.isEmpty)
      return CommandResult(false, "", "System ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Transformation name is required");
    if (req.mappingRules.length == 0)
      return CommandResult(false, "", "Mapping rules are required");

    if (!engine.validateRules(req.mappingRules))
      return CommandResult(false, "", "Invalid mapping rules format");

    auto now = Clock.currStdTime();
    auto t = Transformation();
    t.id = randomUUID();
    t.tenantId = req.tenantId;
    t.systemId = req.systemId;
    t.systemRole = req.systemRole;
    t.name = req.name;
    t.mappingRules = req.mappingRules;
    t.conditions = req.conditions;
    t.createdBy = req.createdBy;
    t.createdAt = now;
    t.updatedAt = now;

    repo.save(t);
    return CommandResult(t.id, "");
  }

  Transformation* getTransformation(TransformationId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Transformation[] listTransformations(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Transformation[] listBySystem(string systemtenantId, id tenantId) {
    return repo.findBySystem(systemtenantId, id);
  }

  CommandResult updateTransformation(UpdateTransformationRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Transformation ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult(false, "", "Transformation not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.mappingRules.length > 0) {
      if (!engine.validateRules(req.mappingRules))
        return CommandResult(false, "", "Invalid mapping rules format");
      updated.mappingRules = req.mappingRules;
    }
    if (req.conditions.length > 0)
      updated.conditions = req.conditions;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Test a transformation with sample input.
  string testTransformation(string inputAttributes, string systemtenantId, id tenantId) {
    return engine.applyTransformations(inputAttributes, systemtenantId, id);
  }

  CommandResult deleteTransformation(TransformationId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing is null)
      return CommandResult(false, "", "Transformation not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
