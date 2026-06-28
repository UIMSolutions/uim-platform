/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.monitored_resources;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.ports.repositories.monitored_resources;
// import uim.platform.monitoring.domain.types;
// 
import uim.platform.monitoring;

// mixin(ShowModule!());

@safe:
/// Application service for monitored resource CRUD operations.
class ManageMonitoredResourcesUseCase { // TODO: UIMUseCase {
  private MonitoredResourceRepository repo;

  this(MonitoredResourceRepository repo) {
    this.repo = repo;
  }

  CommandResult register(RegisterResourceRequest req) {
    if (repo.existsByName(req.tenantId, req.name))
      return CommandResult(false, "", "Resource with name '" ~ req.name ~ "' already exists");

    if (req.name.length == 0)
      return CommandResult(false, "", "Resource name is required");

    MonitoredResource resource;
    resource.initEntity(req.tenantId, req.registeredBy);
    resource.subaccountId = req.subaccountId;
    resource.name = req.name;
    resource.description = req.description;
    resource.resourceType = req.resourceType.to!ResourceType;
    resource.state = ResourceState.unknown;
    resource.url = req.url;
    resource.runtime = req.runtime;
    resource.region = req.region;
    resource.instanceCount = req.instanceCount;
    resource.tags = req.tags;
    resource.lastSeenAt = resource.registeredAt;

    repo.save(resource);
    return CommandResult(true, resource.id.value, "");
  }

  CommandResult updateResource(UpdateResourceRequest req) {
    auto resource = repo.findById(req.tenantId, req.resourceId);
    if (resource.isNull)
      return CommandResult(false, "", "Resource not found");

    if (req.description.length > 0)
      resource.description = req.description;
    if (req.url.length > 0)
      resource.url = req.url;
    if (req.runtime.length > 0)
      resource.runtime = req.runtime;
    if (req.state.length > 0)
      resource.state = req.state.to!ResourceState;
    if (req.instanceCount > 0)
      resource.instanceCount = req.instanceCount;
    if (req.tags.length > 0)
      resource.tags = req.tags;
    resource.lastSeenAt = clockSeconds();

    repo.update(resource);
    return CommandResult(true, resource.id.value, "");
  }

  bool existsResource(TenantId tenantId, MonitoredResourceId id) {
    return repo.existsById(tenantId, id);
  }

  MonitoredResource getResource(TenantId tenantId, MonitoredResourceId id) {
    return repo.find(tenantId, id);
  }

  MonitoredResource[] listResources(TenantId tenantId) {
    return repo.find(tenantId);
  }

  MonitoredResource[] listByType(TenantId tenantId, string typeStr) {
    return repo.findByType(tenantId, typeStr.to!ResourceType);
  }

  CommandResult deleteMonitoredResource(TenantId tenantId, MonitoredResourceId id) {
    auto resource = repo.find(tenantId, id);
    if (resource.isNull)
      return CommandResult(false, "", "Resource not found");

    repo.remove(resource);
    return CommandResult(true, resource.id.value, "");
  }

}
