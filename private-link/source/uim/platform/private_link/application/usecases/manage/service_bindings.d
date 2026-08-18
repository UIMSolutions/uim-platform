/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.application.usecases.manage.service_bindings;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
/// Use case: bind/unbind a private link service instance to an application.
class ManageServiceBindingsUseCase {
  protected ServiceBindingRepository bindings;
  private ServiceInstanceRepository instances;
  private PrivateEndpointRepository endpoints;
  private EndpointResolver resolver;

  this(ServiceBindingRepository bindings,
       ServiceInstanceRepository instances,
       PrivateEndpointRepository endpoints,
       EndpointResolver resolver) {
    this.bindings  = bindings;
    this.instances = instances;
    this.endpoints = endpoints;
    this.resolver  = resolver;
  }

  UsecaseResult createBinding(CreateServiceBindingRequest req) {
    auto inst = instances.findById(req.tenantId, req.instanceId);
    if (inst.id.value.length == 0)
      return UsecaseResult(false, "", "Service instance not found");
    if (inst.status != InstanceStatus.ready)
      return UsecaseResult(false, "", "Service instance is not ready");

    auto ep = resolver.resolveForInstance(req.tenantId, req.instanceId);
    if (ep.id.value.length == 0)
      return UsecaseResult(false, "", "No ready private endpoint found for this instance");

    auto binding = ServiceBinding();
    binding.id = ServiceBindingId(generateId());
    binding.tenantId = req.tenantId;
    binding.serviceInstanceId = req.instanceId;
    binding.applicationId = req.applicationId;
    binding.hostname = ep.hostname;
    binding.privateIpAddress = ep.privateIpAddress;
    binding.port = ep.port;
    binding.status = BindingStatus.active;
    binding.createdAt = currentTimestamp();

    bindings.save(binding);
    return UsecaseResult(true, binding.id.value, "Service binding created");
  }

  UsecaseResult deleteBinding(TenantId tenantId, ServiceBindingId id) {
    auto binding = bindings.findById(tenantId, id);
    if (binding.id.value.length == 0)
      return UsecaseResult(false, "", "Service binding not found");
    bindings.remove(binding);
    return UsecaseResult(true, id.value, "Service binding deleted");
  }

  ServiceBinding getBinding(TenantId tenantId, ServiceBindingId id) {
    return bindings.findById(tenantId, id);
  }

  ServiceBinding[] listBindings(TenantId tenantId) {
    return bindings.findByTenant(tenantId);
  }

  ServiceBinding[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return bindings.findByServiceInstance(tenantId, instanceId);
  }
}

///
unittest {
    auto serviceBindingRepository = new ServiceBindingRepository();
    auto serviceInstanceRepository = new ServiceInstanceRepository();
    auto privateEndpointRepository = new PrivateEndpointRepository();
    auto endpointResolver = new EndpointResolver();
    auto usecase = new ManageServiceBindingsUseCase(serviceBindingRepository, serviceInstanceRepository, privateEndpointRepository, endpointResolver);
    auto tenantId = TenantId("test-tenant");

    // Test list
    auto items = usecase.listBindings(tenantId);
    assert(items !is null);

}
