/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.services;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.service_instance;
import uim.platform.foundry.domain.entities.service_binding;

// import uim.platform.foundry.domain.ports.service_instance;
// import uim.platform.foundry.domain.ports.service_binding;
import uim.platform.foundry.domain.ports;
import uim.platform.foundry.application.dto;

class ManageServicesUseCase
{
  private ServiceInstanceRepository instanceRepo;
  private ServiceBindingRepository bindingRepo;

  this(ServiceInstanceRepository instanceRepo, ServiceBindingRepository bindingRepo)
  {
    this.instanceRepo = instanceRepo;
    this.bindingRepo = bindingRepo;
  }

  // --- Service Instances ---

  CommandResult createInstance(CreateServiceInstanceRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.spaceId.length == 0)
      return CommandResult("", "Space ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Service instance name is required");
    if (req.serviceName.length == 0)
      return CommandResult("", "Service name is required");
    if (req.servicePlanName.length == 0)
      return CommandResult("", "Service plan name is required");

    auto existing = instanceRepo.findByName(req.spaceId, req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Service instance with this name already exists in space");

    auto now = Clock.currStdTime();
    auto si = ServiceInstance();
    si.id = randomUUID().toString();
    si.spaceId = req.spaceId;
    si.tenantId = req.tenantId;
    si.name = req.name;
    si.serviceName = req.serviceName;
    si.servicePlanName = req.servicePlanName;
    si.status = ServiceInstanceStatus.active;
    si.parameters = req.parameters;
    si.tags = req.tags;
    si.createdBy = req.createdBy;
    si.createdAt = now;
    si.updatedAt = now;

    instanceRepo.save(si);
    return CommandResult(si.id, "");
  }

  ServiceInstance* getInstance(ServiceInstanceId id, TenantId tenantId)
  {
    return instanceRepo.findById(id, tenantId);
  }

  ServiceInstance[] listInstances(TenantId tenantId)
  {
    return instanceRepo.findByTenant(tenantId);
  }

  ServiceInstance[] listBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return instanceRepo.findBySpace(spaceId, tenantId);
  }

  CommandResult updateInstance(UpdateServiceInstanceRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Service instance ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = instanceRepo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Service instance not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.parameters.length > 0)
      updated.parameters = req.parameters;
    if (req.tags.length > 0)
      updated.tags = req.tags;
    updated.updatedAt = Clock.currStdTime();

    instanceRepo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult deleteInstance(ServiceInstanceId id, TenantId tenantId)
  {
    auto existing = instanceRepo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Service instance not found");

    // Remove all bindings for this instance
    auto bindings = bindingRepo.findByServiceInstance(id, tenantId);
    foreach (b; bindings)
      bindingRepo.remove(b.id, tenantId);

    instanceRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }

  // --- Service Bindings ---

  CommandResult createBinding(CreateServiceBindingRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.appId.length == 0)
      return CommandResult("", "Application ID is required");
    if (req.serviceInstanceId.length == 0)
      return CommandResult("", "Service instance ID is required");

    // Verify instance exists
    auto instance = instanceRepo.findById(req.serviceInstanceId, req.tenantId);
    if (instance is null)
      return CommandResult("", "Service instance not found");

    auto binding = ServiceBinding();
    binding.id = randomUUID().toString();
    binding.appId = req.appId;
    binding.serviceInstanceId = req.serviceInstanceId;
    binding.tenantId = req.tenantId;
    binding.name = req.name.length > 0 ? req.name : instance.serviceName ~ "-binding";
    binding.status = BindingStatus.active;
    binding.credentials = `{"uri":"` ~ instance.serviceName ~ `://localhost","username":"admin"}`;
    binding.bindingOptions = req.bindingOptions;
    binding.createdBy = req.createdBy;
    binding.createdAt = Clock.currStdTime();

    bindingRepo.save(binding);
    return CommandResult(binding.id, "");
  }

  ServiceBinding[] listBindings(TenantId tenantId)
  {
    return bindingRepo.findByTenant(tenantId);
  }

  ServiceBinding[] listBindingsByApp(AppId appId, TenantId tenantId)
  {
    return bindingRepo.findByApp(appId, tenantId);
  }

  CommandResult deleteBinding(ServiceBindingId id, TenantId tenantId)
  {
    auto existing = bindingRepo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Service binding not found");

    bindingRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
