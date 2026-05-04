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

// // import std.conv : to;
import uim.platform.monitoring;

mixin(ShowModule!());

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
    resource.id = randomUUID();
    resource.tenantId = req.tenantId;
    resource.subaccountId = req.subaccountId;
    resource.name = req.name;
    resource.description = req.description;
    resource.resourceType = parseResourceType(req.resourceType);
    resource.state = ResourceState.unknown;
    resource.url = req.url;
    resource.runtime = req.runtime;
    resource.region = req.region;
    resource.instanceCount = req.instanceCount;
    resource.tags = req.tags;
    resource.registeredBy = req.registeredBy;
    resource.registeredAt = clockSeconds();
    resource.lastSeenAt = resource.registeredAt;

    repo.save(resource);
    return CommandResult(true, resource.id.value, "");
  }

  CommandResult updateResource(MonitoredResourceId id, UpdateResourceRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Resource not found");

    auto resource = repo.findById(id);
    if (req.description.length > 0)
      resource.description = req.description;
    if (req.url.length > 0)
      resource.url = req.url;
    if (req.runtime.length > 0)
      resource.runtime = req.runtime;
    if (req.state.length > 0)
      resource.state = parseResourceState(req.state);
    if (req.instanceCount > 0)
      resource.instanceCount = req.instanceCount;
    if (req.tags.length > 0)
      resource.tags = req.tags;
    resource.lastSeenAt = clockSeconds();

    repo.update(resource);
    return CommandResult(true, resource.id.value, "");
  }

  bool existsResource(MonitoredResourceId id) {
    return repo.existsById(id);
  }

  MonitoredResource getResource(MonitoredResourceId id) {
    return repo.findById(id);
  }

  MonitoredResource[] listResources(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  MonitoredResource[] listByType(TenantId tenantId, string typeStr) {
    return repo.findByType(tenantId, parseResourceType(typeStr));
  }

  CommandResult removeResource(MonitoredResourceId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Resource not found");

    auto resource = repo.findById(id);
    repo.removeById(id);
    return CommandResult(true, resource.id.value, "");
  }

  private static ResourceType parseResourceType(string resourceType) {
    switch (resourceType) {
    case "html5Application":
      return ResourceType.html5Application;
    case "hanaXsApplication":
      return ResourceType.hanaXsApplication;
    case "databaseSystem":
      return ResourceType.databaseSystem;
    case "nodeApplication":
      return ResourceType.nodeApplication;
    case "customApplication":
      return ResourceType.customApplication;
    case "service":
      return ResourceType.service;
    default:
      return ResourceType.javaApplication;
    }
  }

  private static ResourceState parseResourceState(string resourceState) {
    switch (resourceState) {
    case "started":
      return ResourceState.started;
    case "stopped":
      return ResourceState.stopped;
    case "error":
      return ResourceState.error;
    default:
      return ResourceState.unknown;
    }
  }
}
