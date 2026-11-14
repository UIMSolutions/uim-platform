/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceOfferingsUseCase : IManageServiceOfferings {
  protected IServiceOfferingRepository offerings;
  protected IServiceBrokerRepository brokers;
  protected IServicePlanRepository plans;
  protected ILabelRepository labels;

  this(IServiceOfferingRepository offerings, IServiceBrokerRepository brokers, IServicePlanRepository plans,
    ILabelRepository labels) {
    this.offerings = offerings;
    this.brokers = brokers;
    this.plans = plans;
    this.labels = labels;
  }

  ServiceOffering[] listOfferings(TenantId tenantId) {
    return offerings.findAll(tenantId);
  }

  ServiceOffering getOffering(TenantId tenantId, ServiceOfferingId id) {
    return offerings.findById(tenantId, id).required("Service offering '" ~ id.value ~ "'");
  }

  ServiceOffering createOffering(CreateServiceOfferingRequest r) {
    ServiceOffering o;
    stampCreated!(ServiceOffering, ServiceOfferingId)(o, r.tenantId, r.actor, r.id);
    if (offerings.existsById(r.tenantId, o.id))
      throw ServiceManagerException.conflict("Service offering '" ~ o.id.value ~ "' already exists");
    o.brokerId = ServiceBrokerId(r.brokerId);
    brokers.findById(r.tenantId, o.brokerId).required("Service broker '" ~ r.brokerId ~ "'");
    o.name = r.name;
    o.description = r.description;
    o.catalogId = r.catalogId.length > 0 ? r.catalogId : o.id.value;
    o.catalogName = r.catalogName.length > 0 ? r.catalogName : r.name;
    o.category = parseDomainEnumOr!ServiceCategory(r.category, categoryOf(r.tags), "category");
    r.bindable.applyTo(o.bindable);
    r.instancesRetrievable.applyTo(o.instancesRetrievable);
    r.bindingsRetrievable.applyTo(o.bindingsRetrievable);
    r.planUpdateable.applyTo(o.planUpdateable);
    o.metadata = r.metadata;
    o.tags = r.tags.dup;
    o.validate();
    ensureUniqueName(o);
    offerings.save(o);
    return o;
  }

  ServiceOffering updateOffering(UpdateServiceOfferingRequest r) {
    auto o = getOffering(r.tenantId, r.id);
    r.name.applyTo(o.name);
    r.description.applyTo(o.description);
    r.catalogName.applyTo(o.catalogName);
    if (r.category.isSet)
      o.category = parseDomainEnum!ServiceCategory(r.category.value, "category");
    if (r.status.isSet)
      o.status = parseDomainEnum!ServiceOfferingStatus(r.status.value, "status");
    r.bindable.applyTo(o.bindable);
    r.instancesRetrievable.applyTo(o.instancesRetrievable);
    r.bindingsRetrievable.applyTo(o.bindingsRetrievable);
    r.planUpdateable.applyTo(o.planUpdateable);
    r.metadata.applyTo(o.metadata);
    if (r.tags.isSet)
      o.tags = r.tags.value.dup;
    o.validate();
    ensureUniqueName(o);
    stampUpdated(o, r.actor);
    offerings.save(o);
    return o;
  }

  void deleteOffering(TenantId tenantId, ServiceOfferingId id) {
    auto o = getOffering(tenantId, id);
    auto owned = plans.findByOffering(tenantId, id).length;
    if (owned > 0)
      throw ServiceManagerException.ruleViolation("Service offering '" ~ o.name ~ "' still has " ~ countOf(owned,
          "service plan"));
    offerings.removeById(tenantId, id);
    labels.removeByResource(tenantId, ResourceType.serviceOffering, id.value);
  }

  protected void ensureUniqueName(const ServiceOffering o) {
    auto other = offerings.findByName(o.tenantId, o.brokerId, o.name);
    if (!other.isNull && other.id != o.id)
      throw ServiceManagerException.conflict("Broker already offers a service named '" ~ o.name ~ "'");
  }
}
