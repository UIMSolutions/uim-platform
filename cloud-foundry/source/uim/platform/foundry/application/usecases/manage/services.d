/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.services;



// import uim.platform.foundry.domain.entities.service_instance;
// import uim.platform.foundry.domain.entities.service_binding;
// import uim.platform.foundry.domain.ports.repositories.service_instance;
// import uim.platform.foundry.domain.ports.repositories.service_binding;

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
    if (req.name.isEmpty)
      return CommandResult(false, "", "Service instance name is required");
    if (req.serviceName.isEmpty)
      return CommandResult(false, "", "Service name is required");
    if (req.servicePlanName.isEmpty)
      return CommandResult(false, "", "Service plan name is required");

    auto instance = instances.findByName(req.tenantId, req.spaceId, req.name);
    if (!instance.isNull)
      return CommandResult(false, "", "Service instance with this name already exists in space");

    auto srvInstance = ServiceInstance(req.tenantId, req.instanceId.isNull ? ServiceInstanceId(createId()) : req.instanceId, req.createdBy);
    srvInstance.spaceId = req.spaceId;
    srvInstance.name = req.name;
    srvInstance.serviceName = req.serviceName;
    srvInstance.servicePlanName = req.servicePlanName;
    srvInstance.status = ServiceInstanceStatus.active.toString;
    srvInstance.parameters = req.parameters;
    srvInstance.tags = req.tags;

    instances.save(srvInstance);
    return CommandResult(true, srvInstance.id.value, "");
  }

  ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId serviceInstanceId) {
    return instances.findById(tenantId, serviceInstanceId);
  }

  ServiceInstance[] listInstances(TenantId tenantId) {
    return instances.findByTenant(tenantId);
  }

  ServiceInstance[] listBySpace(TenantId tenantId, SpaceId spaceId) {
    return instances.findBySpace(tenantId, spaceId);
  }

  CommandResult updateInstance(UpdateServiceInstanceRequest req) {
    if (req.instanceId.isEmpty)
      return CommandResult(false, "", "Service instance ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto instance = instances.findById(req.tenantId, req.instanceId);
    if (instance.isNull)
      return CommandResult(false, "", "Service instance not found");

    if (req.name.length > 0)
      instance.name = req.name;
    if (req.parameters.length > 0)
      instance.parameters = req.parameters;
    if (req.tags.length > 0)
      instance.tags = req.tags;
    instance.updatedAt = currentTimestamp();

    instances.update(instance);
    return CommandResult(true, instance.id.value, "");
  }

  CommandResult deleteInstance(TenantId tenantId, ServiceInstanceId serviceInstanceId) {
    auto instance = instances.findById(tenantId, serviceInstanceId);
    if (instance.isNull )
      return CommandResult(false, "", "Service instance not found");

    // Remove all bindings for this instance
    auto instanceBindings = bindings.findByServiceInstance(tenantId, serviceInstanceId);
    instanceBindings.each!(b => bindings.remove(b));

    instances.remove(instance);
    return CommandResult(true, instance.id.value, "");
  }

  // --- Service Bindings ---

  CommandResult createBinding(CreateServiceBindingRequest request) {
    if (request.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (request.appId.isEmpty)
      return CommandResult(false, "", "Application ID is required");
    if (request.instanceId.isEmpty)
      return CommandResult(false, "", "Service instance ID is required");

    // Verify instance exists
    auto instance = instances.findById(request.tenantId, request.instanceId);
    if (instance.isNull)
      return CommandResult(false, "", "Service instance not found");

    auto binding = ServiceBinding(request.tenantId, request.bindingId.isNull ? ServiceBindingId(createId) : request.bindingId, request.createdBy);
    binding.appId = request.appId;
    binding.serviceInstanceId = request.instanceId;
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
