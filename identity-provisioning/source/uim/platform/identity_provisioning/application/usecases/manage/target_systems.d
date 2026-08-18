/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.manage.target_systems;


// import uim.platform.identity_provisioning.domain.entities.target_system;
// import uim.platform.identity_provisioning.domain.ports.repositories.target_systems;
// import uim.platform.identity_provisioning.application.dto;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
class ManageTargetSystemsUseCase {
  protected ITargetSystemRepository repo;

  this(ITargetSystemRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createTargetSystem(CreateTargetSystemRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "System name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Target system with this name already exists");

    auto sys = TargetSystem(req.tenantId); //, req.createdBy);
    sys.name = req.name;
    sys.description = req.description;
    sys.systemType = req.systemType;
    sys.connectionConfig = req.connectionConfig;
    sys.status = SystemStatus.configuring;

    repo.save(sys);
    return UsecaseResult(true, sys.id.value, "");
  }

  TargetSystem getTargetSystem(TenantId tenantId, TargetSystemId id) {
    return repo.findById(tenantId, id);
  }

  TargetSystem[] listTargetSystems(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateTargetSystem(UpdateTargetSystemRequest req) {
    if (req.systemId.isEmpty)
      return UsecaseResult(false, "", "System ID is required");

    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.systemId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Target system not found");

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

  UsecaseResult activateSystem(TenantId tenantId, TargetSystemId id) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return UsecaseResult(false, "", "Target system not found");

    if (sys.connectionConfig.length == 0)
      return UsecaseResult(false, "", "Connection configuration is required before activation");

    sys.status = SystemStatus.active;
    sys.updatedAt = currentTimestamp();
    repo.update(sys);
    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult deactivateSystem(TenantId tenantId, TargetSystemId id) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return UsecaseResult(false, "", "Target system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = currentTimestamp();
    repo.update(sys);
    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult deleteTargetSystem(TenantId tenantId, TargetSystemId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Target system not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
    // auto repo = new ITargetSystemRepository();
    // auto usecase = new ManageTargetSystemsUseCase(repo);
    // auto tenantId = TenantId("test-tenant");
// 
    // Test list
    // auto items = usecase.listTargetSystems(tenantId);
    // assert(items !is null);

}
