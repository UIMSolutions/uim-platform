/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.service_plans;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.ports.repositories.service_plans;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage the service plan catalog.
class ManageServicePlansUseCase { // TODO: UIMUseCase {
  private ServicePlanRepository servicePlans;

  this(ServicePlanRepository servicePlans) {
    this.servicePlans = servicePlans;
  }

  CommandResult createPlan(CreateServicePlanRequest req) {
    if (req.serviceName.isEmpty)
      return CommandResult(false, "", "Service name is required");
    if (req.planname.isEmpty)
      return CommandResult(false, "", "Plan name is required");

    auto plan = ServicePlan(req.tenantId);
    plan.serviceName = req.serviceName;
    plan.serviceDisplayName = req.serviceDisplayName;
    plan.planName = req.planName;
    plan.planDisplayName = req.planDisplayName.length > 0 ? req.planDisplayName : req.planName;
    plan.description = req.description;
    plan.category = req.category.toServicePlanCategory;
    plan.pricingModel = req.pricingModel.toPricingModel;
    plan.metadata = req.metadata;
    // plan.provisionable = req.provisionable;
    plan.isFree = req.isFree;
    plan.isBeta = req.isBeta;
    plan.availableRegions = req.availableRegions;
    plan.maxQuota = req.maxQuota;
    plan.unit = req.unit;
    plan.supportedPlatforms = req.supportedPlatforms;
    plan.providerDisplayName = req.providerDisplayName;
    // plan.createdBy = req.createdBy;
    // plan.updatedBy = req.createdBy;

    servicePlans.save(plan);
    return CommandResult(true, plan.id.value, "");
  }

  CommandResult updatePlan(UpdateServicePlanRequest req) {
    auto plan = servicePlans.findById(req.tenantId, req.planId);
    if (plan.isNull)
      return CommandResult(false, "", "Service plan not found");

    if (req.planDisplayName.length > 0)
      plan.planDisplayName = req.planDisplayName;
    if (req.description.length > 0)
      plan.description = req.description;
    if (req.availableRegions.length > 0)
      plan.availableRegions = req.availableRegions;
    if (req.maxQuota > 0)
      plan.maxQuota = req.maxQuota;
    plan.isBeta = req.isBeta;
    plan.provisionable = req.provisionable;
    if (req.metadata.length > 0)
      plan.metadata = req.metadata;
    // plan.updatedBy = req.updatedBy;
    // plan.updatedAt = clockSeconds();

    servicePlans.update(plan);
    return CommandResult(true, plan.id.value, "");
  }

  ServicePlan getPlan(TenantId tenantId, ServicePlanId id) {
    return servicePlans.findById(tenantId, id);
  }

  ServicePlan[] listPlans(TenantId tenantId) {
    return servicePlans.findByTenant(tenantId);
  }

  ServicePlan[] listPlansByService(TenantId tenantId, string serviceName) {
    return servicePlans.findByService(tenantId, serviceName);
  }

  ServicePlan[] listPlansByCategory(TenantId tenantId, string category) {
    return servicePlans.findByCategory(tenantId, category.toServicePlanCategory);
  }

  ServicePlan[] listPlansByRegion(TenantId tenantId, string region) {
    return servicePlans.findByRegion(tenantId, region);
  }

  CommandResult deletePlan(TenantId tenantId, ServicePlanId id) {
    auto entity = servicePlans.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Service plan not found");

    servicePlans.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
