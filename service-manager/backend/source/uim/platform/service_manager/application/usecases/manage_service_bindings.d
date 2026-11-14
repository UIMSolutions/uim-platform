/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase : IManageServiceBindings {
  protected IServiceBindingRepository bindings;
  protected IServiceInstanceRepository instances;
  protected IServicePlanRepository plans;
  protected IServiceOfferingRepository offerings;
  protected IServiceBrokerRepository brokers;
  protected ILabelRepository labels;
  protected OperationTracker tracker;

  this(IServiceBindingRepository bindings, IServiceInstanceRepository instances, IServicePlanRepository plans,
    IServiceOfferingRepository offerings, IServiceBrokerRepository brokers, ILabelRepository labels, OperationTracker tracker) {
    this.bindings = bindings;
    this.instances = instances;
    this.plans = plans;
    this.offerings = offerings;
    this.brokers = brokers;
    this.labels = labels;
    this.tracker = tracker;
  }

  ServiceBinding[] listBindings(TenantId tenantId) {
    return bindings.findAll(tenantId);
  }

  ServiceBinding getBinding(TenantId tenantId, ServiceBindingId id) {
    return bindings.findById(tenantId, id).required("Service binding '" ~ id.value ~ "'");
  }

  ServiceBinding createBinding(CreateServiceBindingRequest r) {
    auto t = r.tenantId;
    if (r.instanceId.strip.length == 0)
      throw ServiceManagerException.invalid("Service binding instanceId is required");
    auto inst = instances.findById(t, ServiceInstanceId(r.instanceId)).required("Service instance '" ~ r.instanceId ~ "'");
    auto plan = plans.findById(t, inst.planId).required("Service plan '" ~ inst.planId.value ~ "'");
    auto offering = offerings.findById(t, inst.offeringId).required("Service offering '" ~ inst.offeringId.value ~ "'");
    ProvisioningPolicy.checkBindable(inst, offering, plan);

    ServiceBinding b;
    stampCreated!(ServiceBinding, ServiceBindingId)(b, t, r.actor, r.id);
    if (bindings.existsById(t, b.id))
      throw ServiceManagerException.conflict("Service binding '" ~ b.id.value ~ "' already exists");
    b.name = r.name;
    b.instanceId = inst.id;
    b.parameters = r.parameters;
    b.bindResource = r.bindResource;
    b.context = r.context;
    b.credentials = r.credentials.strip.length > 0 ? r.credentials : generatedCredentials(t, inst, b);
    b.validate();
    foreach (other; bindings.findByInstance(t, inst.id))
      if (other.name == b.name)
        throw ServiceManagerException.conflict("Service instance '" ~ inst.name ~ "' already has a binding named '" ~ b.name ~ "'");

    auto op = tracker.begin(t, r.actor, ResourceType.serviceBinding, b.id.value, OperationType.bind,
      "Bind '" ~ b.name ~ "' to '" ~ inst.name ~ "'");
    b.lastOperationId = op.id;
    if (tracker.synchronous)
      b.transitionTo(ServiceBindingStatus.created);
    tracker.finish(op);
    bindings.save(b);
    return b;
  }

  void deleteBinding(TenantId tenantId, ServiceBindingId id, UserId actor) {
    auto b = getBinding(tenantId, id);
    if (b.status == ServiceBindingStatus.deleting)
      throw ServiceManagerException.conflict("Service binding '" ~ b.name ~ "' is already being deleted");
    b.transitionTo(ServiceBindingStatus.deleting);
    auto op = tracker.begin(tenantId, actor, ResourceType.serviceBinding, b.id.value, OperationType.unbind,
      "Unbind '" ~ b.name ~ "'");
    tracker.finish(op);
    if (tracker.synchronous) {
      bindings.removeById(tenantId, id);
      labels.removeByResource(tenantId, ResourceType.serviceBinding, id.value);
    } else {
      b.lastOperationId = op.id;
      stampUpdated(b, actor);
      bindings.save(b);
    }
  }

  /// Credentials issued when the caller does not supply them (stands in for
  /// the broker's bind response).
  protected string generatedCredentials(TenantId tenantId, const ServiceInstance inst, const ServiceBinding b) {
    auto broker = brokers.findById(tenantId, offerings.findById(tenantId, inst.offeringId).brokerId);
    auto c = Json.emptyObject;
    c["instanceId"] = inst.id.value;
    c["bindingId"] = b.id.value;
    c["url"] = broker.brokerUrl;
    c["clientid"] = "sb-" ~ inst.name ~ "!" ~ b.id.value[0 .. 8];
    c["clientsecret"] = newResourceId();
    return c.toString;
  }
}
