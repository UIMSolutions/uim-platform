/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.service_plans;

import uim.platform.management.application.dto;
import uim.platform.management.domain.entities.service_plan;
import uim.platform.management.domain.ports.repositories.service_plans;
import uim.platform.management.domain.types;

/// Use case: manage the service plan catalog.
class ManageServicePlansUseCase : UIMUseCase {
  private ServicePlanRepository repo;

  this(ServicePlanRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateServicePlanRequest req) {
    if (req.serviceName.length == 0)
      return CommandResult(false, "", "Service name is required");
    if (req.planName.length == 0)
      return CommandResult(false, "", "Plan name is required");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();

    ServicePlan plan;
    plan.id = id;
    plan.serviceName = req.serviceName;
    plan.serviceDisplayName = req.serviceDisplayName;
    plan.planName = req.planName;
    plan.planDisplayName = req.planDisplayName.length > 0 ? req.planDisplayName : req.planName;
    plan.description = req.description;
    plan.category = parseCategory(req.category);
    plan.pricingModel = parsePricingModel(req.pricingModel);
    plan.isFree = req.isFree;
    plan.isBeta = req.isBeta;
    plan.availableRegions = req.availableRegions;
    plan.maxQuota = req.maxQuota;
    plan.unit = req.unit;
    plan.supportedPlatforms = req.supportedPlatforms;
    plan.providerDisplayName = req.providerDisplayName;
    plan.createdAt = clockSeconds();
    plan.modifiedAt = plan.createdAt;
    plan.metadata = req.metadata;

    repo.save(plan);
    return CommandResult(true, id, "");
  }

  CommandResult update(ServicePlanId id, UpdateServicePlanRequest req) {
    auto plan = repo.findById(id);
    if (plan.id.isEmpty)
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
    plan.modifiedAt = clockSeconds();

    repo.update(plan);
    return CommandResult(true, id, "");
  }

  ServicePlan getById(ServicePlanId id) {
    return repo.findById(id);
  }

  ServicePlan[] listAll() {
    return repo.findAll();
  }

  ServicePlan[] listByService(string serviceName) {
    return repo.findByService(serviceName);
  }

  ServicePlan[] listByCategory(string category) {
    return repo.findByCategory(parseCategory(category));
  }

  ServicePlan[] listByRegion(string region) {
    return repo.findByRegion(region);
  }

  CommandResult remove(ServicePlanId id) {
    auto plan = repo.findById(id);
    if (plan.id.isEmpty)
      return CommandResult(false, "", "Service plan not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private ServicePlanCategory parseCategory(string s) {
    switch (s) {
    case "service":
      return ServicePlanCategory.service;
    case "application":
      return ServicePlanCategory.application;
    case "environment":
      return ServicePlanCategory.environment;
    case "elasticService":
      return ServicePlanCategory.elasticService;
    default:
      return ServicePlanCategory.service;
    }
  }

  private PricingModel parsePricingModel(string s) {
    switch (s) {
    case "free":
      return PricingModel.free;
    case "subscription":
      return PricingModel.subscription;
    case "consumption":
      return PricingModel.consumption;
    case "byol":
      return PricingModel.byol;
    default:
      return PricingModel.free;
    }
  }

  private long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / 10_000_000;
  }
}
