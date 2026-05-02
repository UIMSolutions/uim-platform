/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.services;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_instance;
// import uim.platform.foundry.domain.entities.service_binding;

// // import uim.platform.foundry.domain.ports.repositories.service_instance;
// // import uim.platform.foundry.domain.ports.repositories.service_binding;
// import uim.platform.foundry.domain.ports;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageServicesUseCase { // TODO: UIMUseCase {
  private IServiceInstanceRepository instances;
  private IServiceBindingRepository bindings;

  this(IServiceInstanceRepository instances, IServiceBindingRepository bindings) {
    this.instances = instances;
    this.bindings = bindings;
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

    auto instance = instances.findByName(req.tenantId, req.spaceId, req.name);
    if (!instance.isNull)
      return CommandResult(false, "", "Service instance with this name already exists in space");

    auto now = Clock.currStdTime();
    auto srvInstance = ServiceInstance();
    srvInstance.initEntity(req.tenantId, req.createdBy);

    srvInstance.spaceId = req.spaceId;
    srvInstance.tenantId = req.tenantId;
    srvInstance.name = req.name;
    srvInstance.serviceName = req.serviceName;
    srvInstance.servicePlanName = req.servicePlanName;
    srvInstance.status = ServiceInstanceStatus.active;
    srvInstance.parameters = req.parameters;
    srvInstance.tags = req.tags;

    instances.save(srvInstance);
    return CommandResult(true, srvInstance.id.value, "");
  }

  ServiceInstance* getInstance(TenantId tenantId, ServiceInstanceId serviceInstanceId) {
    return instances.findById(tenantId, serviceInstanceId);
  }

  ServiceInstance[] listInstances(TenantId tenantId) {
    return instances.findByTenant(tenantId);
  }

  ServiceInstance[] listBySpace(TenantId tenantId, SpaceId spaceId) {
    return instances.findBySpace(tenantId, spaceId);
  }

  CommandResult updateInstance(UpdateServiceInstanceRequest req) {
    if (req.serviceInstanceId.isEmpty)
      return CommandResult(false, "", "Service instance ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto instance = instances.findById(req.tenantId, req.serviceInstanceId);
    if (instance.isNull)
      return CommandResult(false, "", "Service instance not found");

    auto updated = *instance;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.parameters.length > 0)
      updated.parameters = req.parameters;
    if (req.tags.length > 0)
      updated.tags = req.tags;
    updated.updatedAt = Clock.currStdTime();

    instances.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  CommandResult deleteInstance(TenantId tenantId, ServiceInstanceId serviceInstanceId) {
    auto instance = instances.findById(tenantId, serviceInstanceId);
    if (instance.isNull )
      return CommandResult(false, "", "Service instance not found");

    // Remove all bindings for this instance
    auto instanceBindings = bindings.findByServiceInstance(tenantId, serviceInstanceId);
    instanceBindings.each!(b => bindings.removeById(tenantId, b.id));

    instances.remove(instance);
    return CommandResult(true, serviceInstanceid.value, "");
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
    auto instance = instances.findById(request.tenantId, request.serviceInstanceId);
    if (instance.isNull)
      return CommandResult(false, "", "Service instance not found");

    auto binding = ServiceBinding();
    binding.initEntity(request.tenantId, request.createdBy);
    binding.appId = request.appId;
    binding.serviceInstanceId = request.serviceInstanceId;
    binding.name = request.name.length > 0 ? request.name : instance.serviceName ~ "-binding";
    binding.status = BindingStatus.active;
    binding.credentials = `{"uri":"` ~ instance.serviceName ~ `://localhost","username":"admin"}`;
    binding.bindingOptions = request.bindingOptions;

    bindings.save(binding);
    return CommandResult(true, binding.id.value, "");
  }

  ServiceBinding[] listBindings(TenantId tenantId) {
    return bindings.findByTenant(tenantId);
  }

  ServiceBinding[] listBindingsByApp(TenantId tenantId, AppId appId) {
    return bindings.findByApp(tenantId, appId);
  }

  CommandResult deleteBinding(TenantId tenantId, ServiceBindingId bindingId) {
    auto binding = bindings.findById(tenantId, bindingId);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    bindings.remove(binding);
    return CommandResult(true, binding.id.value, "");
  }
}
