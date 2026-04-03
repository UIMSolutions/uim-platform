module application.usecases.manage_transformations;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.transformation;
import domain.ports.transformation_repository;
import domain.services.transformation_engine;
import uim.platform.xyz.application.dto;

class ManageTransformationsUseCase
{
  private TransformationRepository repo;
  private TransformationEngine engine;

  this(TransformationRepository repo, TransformationEngine engine)
  {
    this.repo = repo;
    this.engine = engine;
  }

  CommandResult createTransformation(CreateTransformationRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.systemId.length == 0)
      return CommandResult("", "System ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Transformation name is required");
    if (req.mappingRules.length == 0)
      return CommandResult("", "Mapping rules are required");

    if (!engine.validateRules(req.mappingRules))
      return CommandResult("", "Invalid mapping rules format");

    auto now = Clock.currStdTime();
    auto t = Transformation();
    t.id = randomUUID().toString();
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

  Transformation* getTransformation(TransformationId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Transformation[] listTransformations(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  Transformation[] listBySystem(string systemId, TenantId tenantId)
  {
    return repo.findBySystem(systemId, tenantId);
  }

  CommandResult updateTransformation(UpdateTransformationRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Transformation ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Transformation not found");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    if (req.mappingRules.length > 0)
    {
      if (!engine.validateRules(req.mappingRules))
        return CommandResult("", "Invalid mapping rules format");
      updated.mappingRules = req.mappingRules;
    }
    if (req.conditions.length > 0) updated.conditions = req.conditions;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Test a transformation with sample input.
  string testTransformation(string inputAttributes, string systemId, TenantId tenantId)
  {
    return engine.applyTransformations(inputAttributes, systemId, tenantId);
  }

  CommandResult deleteTransformation(TransformationId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Transformation not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
