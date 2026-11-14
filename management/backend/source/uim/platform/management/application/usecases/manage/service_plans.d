/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.service_plans;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage the service plan catalog.
class ManageServicePlansUseCase : IManageServicePlansUseCase {
  protected IServicePlanRepository servicePlans;
  protected IEntitlementRepository entitlements;

  this(IServicePlanRepository servicePlans, IEntitlementRepository entitlements) {
    this.servicePlans = servicePlans;
    this.entitlements = entitlements;
  }

  UsecaseResult createPlan(CreateServicePlanRequest req) {
    if (req.serviceName.length == 0)
      return invalid("Service name is required");
    if (req.planName.length == 0)
      return invalid("Plan name is required");
    if (req.maxQuota < 0)
      return invalid("Maximum quota must not be negative");
    ServicePlanCategory category = ServicePlanCategory.service;
    if (req.category.length > 0 && !tryParseEnum!ServicePlanCategory(req.category, category))
      return invalid("Unknown category '" ~ req.category ~ "' (expected " ~ enumNames!ServicePlanCategory().join(", ") ~ ")");
    PricingModel pricing = PricingModel.free;
    if (req.pricingModel.length > 0 && !tryParseEnum!PricingModel(req.pricingModel, pricing))
      return invalid("Unknown pricing model '" ~ req.pricingModel ~ "' (expected " ~ enumNames!PricingModel().join(", ") ~ ")");
    if (servicePlans.findByService(req.tenantId, req.serviceName).any!(p => p.planName == req.planName))
      return conflict("Plan '" ~ req.planName ~ "' of service '" ~ req.serviceName ~ "' already exists");

    auto plan = ServicePlan(req.tenantId);
    plan.serviceName = req.serviceName;
    plan.serviceDisplayName = req.serviceDisplayName.length > 0 ? req.serviceDisplayName : req.serviceName;
    plan.planName = req.planName;
    plan.planDisplayName = req.planDisplayName.length > 0 ? req.planDisplayName : req.planName;
    plan.description = req.description;
    plan.category = category;
    plan.pricingModel = pricing;
    plan.metadata = req.metadata;
    plan.provisionable = req.provisionable;
    plan.isFree = req.isFree || pricing == PricingModel.free;
    plan.isBeta = req.isBeta;
    plan.availableRegions = req.availableRegions;
    plan.maxQuota = req.maxQuota;
    plan.unit = req.unit.length > 0 ? req.unit : "instances";
    plan.supportedPlatforms = req.supportedPlatforms;
    plan.providerDisplayName = req.providerDisplayName;
    plan.createdBy = actor(req.createdBy);
    plan.updatedBy = plan.createdBy;

    servicePlans.save(plan);
    return created(plan.id.value, "Service plan created");
  }

  UsecaseResult updatePlan(UpdateServicePlanRequest req) {
    auto plan = servicePlans.findById(req.tenantId, req.planId);
    if (plan.isNull)
      return notFound("Service plan");

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
    plan.update(actor(req.updatedBy));

    servicePlans.update(plan);
    return ok(plan.id.value, "Service plan updated");
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
    ServicePlanCategory c;
    if (!tryParseEnum!ServicePlanCategory(category, c))
      return null;
    return servicePlans.findByCategory(tenantId, c);
  }

  ServicePlan[] listPlansByRegion(TenantId tenantId, string region) {
    return servicePlans.findByRegion(tenantId, region);
  }

  UsecaseResult deletePlan(TenantId tenantId, ServicePlanId id) {
    auto entity = servicePlans.findById(tenantId, id);
    if (entity.isNull)
      return notFound("Service plan");
    if (entitlements.findByTenant(tenantId).any!(e => e.servicePlanId == id && e.consumesQuota))
      return violation("Service plan '" ~ entity.planName ~ "' is still entitled; revoke its entitlements first");

    servicePlans.remove(entity);
    return ok(entity.id.value, "Service plan deleted");
  }
}
