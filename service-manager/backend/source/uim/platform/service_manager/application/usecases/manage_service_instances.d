/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase : IManageServiceInstances {
  protected IServiceInstanceRepository instances;
  protected IServicePlanRepository plans;
  protected IServiceOfferingRepository offerings;
  protected IServiceBrokerRepository brokers;
  protected IPlatformRepository platforms;
  protected IServiceBindingRepository bindings;
  protected ILabelRepository labels;
  protected OperationTracker tracker;

  this(IServiceInstanceRepository instances, IServicePlanRepository plans, IServiceOfferingRepository offerings,
    IServiceBrokerRepository brokers, IPlatformRepository platforms, IServiceBindingRepository bindings,
    ILabelRepository labels, OperationTracker tracker) {
    this.instances = instances;
    this.plans = plans;
    this.offerings = offerings;
    this.brokers = brokers;
    this.platforms = platforms;
    this.bindings = bindings;
    this.labels = labels;
    this.tracker = tracker;
  }

  ServiceInstance[] listInstances(TenantId tenantId) {
    return instances.findAll(tenantId);
  }

  ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id) {
    return instances.findById(tenantId, id).required("Service instance '" ~ id.value ~ "'");
  }

  ServiceInstance provisionInstance(ProvisionServiceInstanceRequest r) {
    auto t = r.tenantId;
    if (r.planId.strip.length == 0)
      throw ServiceManagerException.invalid("Service instance planId is required");
    auto plan = plans.findById(t, ServicePlanId(r.planId)).required("Service plan '" ~ r.planId ~ "'");
    auto offering = offerings.findById(t, plan.offeringId).required("Service offering '" ~ plan.offeringId.value ~ "'");
    auto broker = brokers.findById(t, offering.brokerId).required("Service broker '" ~ offering.brokerId.value ~ "'");
    Platform platform;
    if (r.platformId.strip.length > 0)
      platform = platforms.findById(t, PlatformId(r.platformId)).required("Platform '" ~ r.platformId ~ "'");
    ProvisioningPolicy.checkProvisionable(broker, offering, plan, instances.findByPlan(t, plan.id).length, platform);

    ServiceInstance inst;
    stampCreated!(ServiceInstance, ServiceInstanceId)(inst, t, r.actor, r.id);
    if (instances.existsById(t, inst.id))
      throw ServiceManagerException.conflict("Service instance '" ~ inst.id.value ~ "' already exists");
    inst.name = r.name;
    inst.planId = plan.id;
    inst.offeringId = offering.id;
    inst.platformId = platform.id;
    inst.context = r.context;
    inst.parameters = r.parameters;
    inst.shared_ = r.shared_;
    inst.dashboardUrl = broker.brokerUrl.stripRight("/") ~ "/dashboard/" ~ inst.id.value;
    inst.validate();
    ensureUniqueName(inst);

    auto op = tracker.begin(t, r.actor, ResourceType.serviceInstance, inst.id.value, OperationType.create,
      "Provision '" ~ inst.name ~ "' (" ~ offering.name ~ "/" ~ plan.name ~ ")");
    inst.lastOperationId = op.id;
    if (tracker.synchronous)
      inst.transitionTo(ServiceInstanceStatus.created);
    tracker.finish(op);
    instances.save(inst);
    return inst;
  }

  ServiceInstance updateInstance(UpdateServiceInstanceRequest r) {
    auto t = r.tenantId;
    auto inst = getInstance(t, r.id);
    if (inst.status == ServiceInstanceStatus.deleting)
      throw ServiceManagerException.ruleViolation("Service instance '" ~ inst.name ~ "' is being deleted");

    r.name.applyTo(inst.name);
    r.shared_.applyTo(inst.shared_);
    r.usable.applyTo(inst.usable);
    bool brokerChange = r.parameters.applyTo(inst.parameters);
    brokerChange |= r.context.applyTo(inst.context);

    string planText;
    if (r.planId.isSet && r.planId.value != inst.planId.value) {
      auto newPlan = plans.findById(t, ServicePlanId(r.planId.value)).required("Service plan '" ~ r.planId.value ~ "'");
      auto offering = offerings.findById(t, inst.offeringId).required("Service offering '" ~ inst.offeringId.value ~ "'");
      ProvisioningPolicy.checkPlanChange(inst, offering, newPlan, instances.findByPlan(t, newPlan.id).length);
      inst.planId = newPlan.id;
      planText = " → plan " ~ newPlan.name;
      brokerChange = true;
    }
    inst.validate();
    ensureUniqueName(inst);

    if (brokerChange) {
      inst.transitionTo(ServiceInstanceStatus.updating);
      auto op = tracker.begin(t, r.actor, ResourceType.serviceInstance, inst.id.value, OperationType.update,
        "Update '" ~ inst.name ~ "'" ~ planText);
      inst.lastOperationId = op.id;
      if (tracker.synchronous)
        inst.transitionTo(ServiceInstanceStatus.created);
      tracker.finish(op);
    }
    stampUpdated(inst, r.actor);
    instances.save(inst);
    return inst;
  }

  void deprovisionInstance(TenantId tenantId, ServiceInstanceId id, UserId actor) {
    auto inst = getInstance(tenantId, id);
    auto bound = bindings.findByInstance(tenantId, id).length;
    if (bound > 0)
      throw ServiceManagerException.ruleViolation("Service instance '" ~ inst.name ~ "' still has " ~ countOf(bound,
          "binding") ~ "; delete them first");
    if (inst.status == ServiceInstanceStatus.deleting)
      throw ServiceManagerException.conflict("Service instance '" ~ inst.name ~ "' is already being deleted");

    inst.transitionTo(ServiceInstanceStatus.deleting);
    auto op = tracker.begin(tenantId, actor, ResourceType.serviceInstance, inst.id.value, OperationType.delete_,
      "Deprovision '" ~ inst.name ~ "'");
    tracker.finish(op);
    if (tracker.synchronous) {
      instances.removeById(tenantId, id);
      labels.removeByResource(tenantId, ResourceType.serviceInstance, id.value);
    } else {
      inst.lastOperationId = op.id;
      stampUpdated(inst, actor);
      instances.save(inst);
    }
  }

  protected void ensureUniqueName(const ServiceInstance inst) {
    auto other = instances.findByName(inst.tenantId, inst.name);
    if (!other.isNull && other.id != inst.id)
      throw ServiceManagerException.conflict("A service instance named '" ~ inst.name ~ "' already exists");
  }
}
