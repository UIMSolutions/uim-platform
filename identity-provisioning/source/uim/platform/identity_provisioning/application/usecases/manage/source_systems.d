/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.manage.source_systems;


// import uim.platform.identity_provisioning.domain.entities.source_system;
// import uim.platform.identity_provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity_provisioning.application.dto;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
class ManageSourceSystemsUseCase {
  protected ISourceSystemRepository repo;

  this(ISourceSystemRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createSourceSystem(CreateSourceSystemRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "System name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Source system with this name already exists");

    auto sys = SourceSystem(req.tenantId); //, req.createdBy);
    sys.name = req.name;
    sys.description = req.description;
    sys.systemType = req.systemType;
    sys.connectionConfig = req.connectionConfig;
    sys.status = SystemStatus.configuring;

    repo.save(sys);
    return UsecaseResult(true, sys.id.value, "");
  }

  SourceSystem getSourceSystem(TenantId tenantId, SourceSystemId id) {
    return repo.findById(tenantId, id);
  }

  SourceSystem[] listSourceSystems(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateSourceSystem(UpdateSourceSystemRequest req) {
    if (req.systemId.isNull)
      return UsecaseResult(false, "", "System ID is required");
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.systemId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Source system not found");

    auto updated = existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.connectionConfig.length > 0)
      updated.connectionConfig = req.connectionConfig;
    updated.updatedAt = currentTimestamp();

    repo.update(updated);
    return UsecaseResult(true, updated.id.value, "");
  }

  /// Activate a source system for provisioning.
  UsecaseResult activateSystem(TenantId tenantId, SourceSystemId id) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return UsecaseResult(false, "", "Source system not found");

    if (sys.connectionConfig.length == 0)
      return UsecaseResult(false, "", "Connection configuration is required before activation");

    sys.status = SystemStatus.active;
    sys.updatedAt = currentTimestamp();
    repo.update(sys);
    return UsecaseResult(true, sys.id.value, "");
  }

  /// Deactivate a source system.
  UsecaseResult deactivateSystem(TenantId tenantId, SourceSystemId id) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return UsecaseResult(false, "", "Source system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = currentTimestamp();
    repo.update(sys);
    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult deleteSourceSystem(TenantId tenantId, SourceSystemId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Source system not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
//     auto repo = new ISourceSystemRepository();
//     auto usecase = new ManageSourceSystemsUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listSourceSystems(tenantId);
//     assert(items !is null);

}
