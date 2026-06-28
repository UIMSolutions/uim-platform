/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.application.usecases.manage.transformations;


// import uim.platform.identity.provisioning.domain.types;
// import uim.platform.identity.provisioning.domain.entities.transformation;
// import uim.platform.identity.provisioning.domain.ports.repositories.transformations;
// import uim.platform.identity.provisioning.domain.services.transformation_engine;
// import uim.platform.identity.provisioning.application.dto;
import uim.platform.identity.provisioning;

// mixin(ShowModule!());

@safe:
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

    Transformation t;
    t.initEntity(req.tenantId, req.createdBy);

    t.name = req.name;
    t.mappingRules = req.mappingRules;
    t.conditions = req.conditions;

    repo.save(t);
    return CommandResult(true, t.id.value, "");
  }

  Transformation getTransformation(TenantId tenantId, TransformationId id) {
    return repo.find(tenantId, id);
  }

  Transformation[] listTransformations(TenantId tenantId) {
    return repo.find(tenantId);
  }

  Transformation[] listBySystem(TenantId tenantId, string systemId) {
    return repo.findBySystem(tenantId, systemId);
  }

  CommandResult updateTransformation(UpdateTransformationRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Transformation ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.id);
    if (existing.isNull)
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
    updated.updatedAt = currentTimestamp();

    repo.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  /// Test a transformation with sample input.
  string testTransformation(TenantId tenantId, string inputAttributes, string systemId) {
    return engine.applyTransformations(inputAttributes, systemId, tenantId);
  }

  CommandResult deleteTransformation(TenantId tenantId, TransformationId id) {
    auto existing = repo.find(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Transformation not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }
}
