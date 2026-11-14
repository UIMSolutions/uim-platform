/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_service_plans;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServicePlansUseCase : IManageServicePlans {
  protected IServicePlanRepository plans;
  protected IServiceOfferingRepository offerings;
  protected IServiceInstanceRepository instances;
  protected ILabelRepository labels;

  this(IServicePlanRepository plans, IServiceOfferingRepository offerings, IServiceInstanceRepository instances,
    ILabelRepository labels) {
    this.plans = plans;
    this.offerings = offerings;
    this.instances = instances;
    this.labels = labels;
  }

  ServicePlan[] listPlans(TenantId tenantId) {
    return plans.findAll(tenantId);
  }

  ServicePlan getPlan(TenantId tenantId, ServicePlanId id) {
    return plans.findById(tenantId, id).required("Service plan '" ~ id.value ~ "'");
  }

  ServicePlan createPlan(CreateServicePlanRequest r) {
    ServicePlan p;
    stampCreated!(ServicePlan, ServicePlanId)(p, r.tenantId, r.actor, r.id);
    if (plans.existsById(r.tenantId, p.id))
      throw ServiceManagerException.conflict("Service plan '" ~ p.id.value ~ "' already exists");
    p.offeringId = ServiceOfferingId(r.offeringId);
    offerings.findById(r.tenantId, p.offeringId).required("Service offering '" ~ r.offeringId ~ "'");
    p.name = r.name;
    p.description = r.description;
    p.catalogId = r.catalogId.length > 0 ? r.catalogId : p.id.value;
    p.catalogName = r.catalogName.length > 0 ? r.catalogName : r.name;
    p.pricing = parseDomainEnumOr!ServicePlanPricing(r.pricing, ServicePlanPricing.free, "pricing");
    r.bindable.applyTo(p.bindable);
    r.planUpdateable.applyTo(p.planUpdateable);
    p.maxInstances = r.maxInstances;
    p.schemas = r.schemas;
    p.metadata = r.metadata;
    p.validate();
    ensureUniqueName(p);
    plans.save(p);
    return p;
  }

  ServicePlan updatePlan(UpdateServicePlanRequest r) {
    auto p = getPlan(r.tenantId, r.id);
    r.name.applyTo(p.name);
    r.description.applyTo(p.description);
    r.catalogName.applyTo(p.catalogName);
    if (r.pricing.isSet)
      p.pricing = parseDomainEnum!ServicePlanPricing(r.pricing.value, "pricing");
    r.bindable.applyTo(p.bindable);
    r.planUpdateable.applyTo(p.planUpdateable);
    r.maxInstances.applyTo(p.maxInstances);
    r.schemas.applyTo(p.schemas);
    r.metadata.applyTo(p.metadata);
    p.validate();
    ensureUniqueName(p);
    stampUpdated(p, r.actor);
    plans.save(p);
    return p;
  }

  void deletePlan(TenantId tenantId, ServicePlanId id) {
    auto p = getPlan(tenantId, id);
    auto used = instances.findByPlan(tenantId, id).length;
    if (used > 0)
      throw ServiceManagerException.ruleViolation("Service plan '" ~ p.name ~ "' still has " ~ countOf(used,
          "service instance"));
    plans.removeById(tenantId, id);
    labels.removeByResource(tenantId, ResourceType.servicePlan, id.value);
  }

  protected void ensureUniqueName(const ServicePlan p) {
    foreach (other; plans.findByOffering(p.tenantId, p.offeringId))
      if (other.name == p.name && other.id != p.id)
        throw ServiceManagerException.conflict("Offering already has a plan named '" ~ p.name ~ "'");
  }
}
