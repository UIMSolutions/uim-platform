/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_service_brokers;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBrokersUseCase : IManageServiceBrokers {
  protected IServiceBrokerRepository brokers;
  protected IServiceOfferingRepository offerings;
  protected IServicePlanRepository plans;
  protected IServiceInstanceRepository instances;
  protected ILabelRepository labels;

  this(IServiceBrokerRepository brokers, IServiceOfferingRepository offerings, IServicePlanRepository plans,
    IServiceInstanceRepository instances, ILabelRepository labels) {
    this.brokers = brokers;
    this.offerings = offerings;
    this.plans = plans;
    this.instances = instances;
    this.labels = labels;
  }

  ServiceBroker[] listBrokers(TenantId tenantId) {
    return brokers.findAll(tenantId);
  }

  ServiceBroker getBroker(TenantId tenantId, ServiceBrokerId id) {
    return brokers.findById(tenantId, id).required("Service broker '" ~ id.value ~ "'");
  }

  ServiceBroker registerBroker(RegisterServiceBrokerRequest r) {
    ServiceBroker b;
    stampCreated!(ServiceBroker, ServiceBrokerId)(b, r.tenantId, r.actor, r.id);
    if (brokers.existsById(r.tenantId, b.id))
      throw ServiceManagerException.conflict("Service broker '" ~ b.id.value ~ "' already exists");
    b.name = r.name;
    b.description = r.description;
    b.brokerUrl = r.brokerUrl.strip;
    b.credentials = r.credentials;
    b.validate();
    ensureUniqueName(b);
    brokers.save(b);
    return b;
  }

  ServiceBroker updateBroker(UpdateServiceBrokerRequest r) {
    auto b = getBroker(r.tenantId, r.id);
    r.name.applyTo(b.name);
    r.description.applyTo(b.description);
    if (r.brokerUrl.isSet)
      b.brokerUrl = r.brokerUrl.value.strip;
    r.credentials.applyTo(b.credentials);
    if (r.status.isSet)
      b.status = parseDomainEnum!ServiceBrokerStatus(r.status.value, "status");
    b.validate();
    ensureUniqueName(b);
    stampUpdated(b, r.actor);
    brokers.save(b);
    return b;
  }

  void deregisterBroker(TenantId tenantId, ServiceBrokerId id) {
    auto b = getBroker(tenantId, id);
    auto owned = offerings.findByBroker(tenantId, id);
    size_t used;
    foreach (o; owned)
      used += instances.findByOffering(tenantId, o.id).length;
    if (used > 0)
      throw ServiceManagerException.ruleViolation("Service broker '" ~ b.name ~ "' still has " ~ countOf(used,
          "service instance") ~ "; deprovision them first");

    // cascade: plans → offerings → broker (with their labels)
    foreach (o; owned) {
      foreach (p; plans.findByOffering(tenantId, o.id)) {
        plans.removeById(tenantId, p.id);
        labels.removeByResource(tenantId, ResourceType.servicePlan, p.id.value);
      }
      offerings.removeById(tenantId, o.id);
      labels.removeByResource(tenantId, ResourceType.serviceOffering, o.id.value);
    }
    brokers.removeById(tenantId, id);
    labels.removeByResource(tenantId, ResourceType.serviceBroker, id.value);
  }

  protected void ensureUniqueName(const ServiceBroker b) {
    auto other = brokers.findByName(b.tenantId, b.name);
    if (!other.isNull && other.id != b.id)
      throw ServiceManagerException.conflict("A service broker named '" ~ b.name ~ "' already exists");
  }
}
