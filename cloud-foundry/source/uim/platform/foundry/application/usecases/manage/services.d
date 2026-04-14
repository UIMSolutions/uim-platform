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

// import uim.platform.foundry.domain.ports.repositories.service_instance;
// import uim.platform.foundry.domain.ports.repositories.service_binding;
import uim.platform.foundry.domain.ports;
import uim.platform.foundry.application.dto;

class ManageServicesUseCase : UIMUseCase {
  private ServiceInstanceRepository instanceRepo;
  private ServiceBindingRepository bindingRepo;

  this(ServiceInstanceRepository instanceRepo, ServiceBindingRepository bindingRepo) {
    this.instanceRepo = instanceRepo;
    this.bindingRepo = bindingRepo;
  }

  // --- Service Instances ---

  CommandResult createInstance(CreateServiceInstanceRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Service instance name is required");
    if (req.serviceName.length == 0)
      return CommandResult(false, "", "Service name is required");
    if (req.servicePlanName.length == 0)
      return CommandResult(false, "", "Service plan name is required");

    auto existing = instanceRepo.findByName(req.spaceId, req.tenantId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Service instance with this name already exists in space");

    auto now = Clock.currStdTime();
    auto si = ServiceInstance();
    si.id = randomUUID();
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

  ServiceInstance* getInstance(ServiceInstanceId tenantId, id tenantId) {
    return instanceRepo.findById(tenantId, id);
  }

  ServiceInstance[] listInstances(TenantId tenantId) {
    return instanceRepo.findByTenant(tenantId);
  }

  ServiceInstance[] listBySpace(SpaceId spacetenantId, id tenantId) {
    return instanceRepo.findBySpace(spacetenantId, id);
  }

  CommandResult updateInstance(UpdateServiceInstanceRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Service instance ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = instanceRepo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult(false, "", "Service instance not found");

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

  CommandResult deleteInstance(TenantId tenantId, ServiceInstanceId id) {
    if (!instanceRepo.existsById(tenantId, id))
      return CommandResult(false, "", "Service instance not found");

    // Remove all bindings for this instance
    auto bindings = bindingRepo.findByServiceInstance(tenantId, id);
    foreach (b; bindings)
      bindingRepo.remove(tenantId, b.id);

    instanceRepo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }

  // --- Service Bindings ---

  CommandResult createBinding(CreateServiceBindingRequest request) {
    if (request.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (request.appId.isEmpty)
      return CommandResult(false, "", "Application ID is required");
    if (request.serviceInstanceId.isEmpty)
      return CommandResult(false, "", "Service instance ID is required");

    // Verify instance exists
    auto instance = instanceRepo.findById(request.serviceInstanceId, request.tenantId);
    if (instance is null)
      return CommandResult(false, "", "Service instance not found");

    auto binding = ServiceBinding();
    binding.id = randomUUID();
    binding.appId = request.appId;
    binding.serviceInstanceId = request.serviceInstanceId;
    binding.tenantId = request.tenantId;
    binding.name = request.name.length > 0 ? request.name : instance.serviceName ~ "-binding";
    binding.status = BindingStatus.active;
    binding.credentials = `{"uri":"` ~ instance.serviceName ~ `://localhost","username":"admin"}`;
    binding.bindingOptions = request.bindingOptions;
    binding.createdBy = request.createdBy;
    binding.createdAt = Clock.currStdTime();

    bindingRepo.save(binding);
    return CommandResult(binding.id, "");
  }

  ServiceBinding[] listBindings(TenantId tenantId) {
    return bindingRepo.findByTenant(tenantId);
  }

  ServiceBinding[] listBindingsByApp(AppId appId, TenantId tenantId) {
    return bindingRepo.findByApp(appId, tenantId);
  }

  CommandResult deleteBinding(ServiceBindingId bindingId, TenantId tenantId) {
    auto existing = bindingRepo.findById(bindingId, tenantId);
    if (existing is null)
      return CommandResult(false, "", "Service binding not found");

    bindingRepo.remove(bindingId, tenantId);
    return CommandResult(true, bindingId.toString, "");
  }
}
