/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.manage.proxy_systems;


// import uim.platform.identity_provisioning.domain.entities.proxy_system;
// import uim.platform.identity_provisioning.domain.ports.repositories.proxy_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.target_systems;
// import uim.platform.identity_provisioning.application.dto;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
class ManageProxySystemsUseCase {
  protected IProxySystemRepository repo;
  private ISourceSystemRepository sourceRepo;
  private ITargetSystemRepository targetRepo;

  this(IProxySystemRepository repo, ISourceSystemRepository sourceRepo,
      ITargetSystemRepository targetRepo) {
    this.repo = repo;
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
  }

  UsecaseResult createProxySystem(CreateProxySystemRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "System name is required");
    if (req.sourceSystemId.isEmpty)
      return UsecaseResult(false, "", "Source system ID is required");
    if (req.targetSystemId.isEmpty)
      return UsecaseResult(false, "", "Target system ID is required");

    // Verify source and target exist
    auto src = sourceRepo.findById(req.tenantId, req.sourceSystemId);
    if (src.isNull)
      return UsecaseResult(false, "", "Source system not found");
    auto tgt = targetRepo.findById(req.tenantId, req.targetSystemId);
    if (tgt.isNull)
      return UsecaseResult(false, "", "Target system not found");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Proxy system with this name already exists");

    auto sys = ProxySystem(req.tenantId);
    // , req.createdBy);
    sys.name = req.name;
    sys.description = req.description;
    sys.systemType = req.systemType;
    sys.connectionConfig = req.connectionConfig;
    sys.sourceSystemId = req.sourceSystemId;
    sys.targetSystemId = req.targetSystemId;
    sys.status = SystemStatus.configuring;

    repo.save(sys);
    return UsecaseResult(true, sys.id.value, "");
  }

  ProxySystem getProxySystem(TenantId tenantId, ProxySystemId id) {
    return repo.findById(tenantId, id);
  }

  ProxySystem[] listProxySystems(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateProxySystem(UpdateProxySystemRequest req) {
    if (req.systemId.isNull)
      return UsecaseResult(false, "", "System ID is required");
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.systemId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Proxy system not found");

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

  UsecaseResult activateSystem(TenantId tenantId, ProxySystemId id) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return UsecaseResult(false, "", "Proxy system not found");

    if (sys.connectionConfig.length == 0)
      return UsecaseResult(false, "", "Connection configuration is required before activation");

    sys.status = SystemStatus.active;
    sys.updatedAt = currentTimestamp();

    repo.update(sys);
    return UsecaseResult(true, sys.id.value, "");
  }

  UsecaseResult deactivateSystem(TenantId tenantId, ProxySystemId id) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return UsecaseResult(false, "", "Proxy system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = currentTimestamp();
    
    repo.update(sys);
    return UsecaseResult(true, sys.id.value, "");
  }

  UsecaseResult deleteProxySystem(TenantId tenantId, ProxySystemId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Proxy system not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

///
unittest {
//     auto iProxySystemRepository = new IProxySystemRepository();
//     auto iSourceSystemRepository = new ISourceSystemRepository();
//     auto iTargetSystemRepository = new ITargetSystemRepository();
//     auto usecase = new ManageProxySystemsUseCase(iProxySystemRepository, iSourceSystemRepository, iTargetSystemRepository);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listProxySystems(tenantId);
//     assert(items !is null);

}
