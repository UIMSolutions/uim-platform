/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reconciles the catalog fetched from a broker with the stored offerings
/// and plans of that broker (match by broker side catalog id).
module uim.platform.service_manager.domain.services.catalog_reconciler;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct CatalogReconciliation {
  ServiceOffering[] offerings; /// offerings to store (created, updated or retired)
  ServicePlan[] plans; /// plans to store (created or updated)
  size_t offeringsCreated, offeringsUpdated, offeringsRemoved;
  size_t plansCreated, plansUpdated;
}

/// Compute the changes. Offerings no longer advertised become `removed`
/// (they are kept because instances may still reference them).
CatalogReconciliation reconcileCatalog(const ServiceBroker broker, ServiceOffering[] existingOfferings,
  ServicePlan[] existingPlans, const BrokerCatalog catalog, long now, UserId actor) {
  CatalogReconciliation r;
  bool[string] advertised;

  foreach (svc; catalog.services) {
    if (svc.id.length == 0 || svc.name.length == 0)
      throw ServiceManagerException.gateway("Catalog of broker '" ~ broker.name ~ "' contains a service without id or name");
    advertised[svc.id] = true;

    ServiceOffering offering;
    bool found;
    foreach (o; existingOfferings)
      if (o.catalogId == svc.id) {
        offering = o;
        found = true;
        break;
      }
    if (!found) {
      offering.id = ServiceOfferingId(newResourceId());
      offering.tenantId = broker.tenantId;
      offering.brokerId = broker.id;
      offering.catalogId = svc.id;
      offering.createdAt = now;
      offering.createdBy = actor;
      offering.category = categoryOf(svc.tags);
    }
    offering.name = svc.name;
    offering.catalogName = svc.name;
    offering.description = svc.description;
    offering.bindable = svc.bindable;
    offering.instancesRetrievable = svc.instancesRetrievable;
    offering.bindingsRetrievable = svc.bindingsRetrievable;
    offering.planUpdateable = svc.planUpdateable;
    offering.tags = svc.tags.dup;
    offering.metadata = svc.metadata;
    if (offering.status == ServiceOfferingStatus.removed)
      offering.status = ServiceOfferingStatus.available;
    offering.updatedAt = now;
    offering.updatedBy = actor;
    r.offerings ~= offering;
    if (found)
      r.offeringsUpdated++;
    else
      r.offeringsCreated++;

    foreach (pd; svc.plans) {
      if (pd.id.length == 0 || pd.name.length == 0)
        throw ServiceManagerException.gateway("Service '" ~ svc.name ~ "' contains a plan without id or name");
      ServicePlan plan;
      bool planFound;
      foreach (p; existingPlans)
        if (p.offeringId == offering.id && p.catalogId == pd.id) {
          plan = p;
          planFound = true;
          break;
        }
      if (!planFound) {
        plan.id = ServicePlanId(newResourceId());
        plan.tenantId = broker.tenantId;
        plan.offeringId = offering.id;
        plan.catalogId = pd.id;
        plan.createdAt = now;
        plan.createdBy = actor;
      }
      plan.name = pd.name;
      plan.catalogName = pd.name;
      plan.description = pd.description;
      plan.pricing = pd.free ? ServicePlanPricing.free : ServicePlanPricing.paid;
      plan.bindable = pd.bindable;
      plan.planUpdateable = pd.planUpdateable;
      plan.maxInstances = pd.maxInstances;
      plan.schemas = pd.schemas;
      plan.metadata = pd.metadata;
      plan.updatedAt = now;
      plan.updatedBy = actor;
      r.plans ~= plan;
      if (planFound)
        r.plansUpdated++;
      else
        r.plansCreated++;
    }
  }

  foreach (o; existingOfferings)
    if (o.catalogId.length > 0 && o.catalogId !in advertised && o.status != ServiceOfferingStatus.removed) {
      auto retired = o;
      retired.status = ServiceOfferingStatus.removed;
      retired.updatedAt = now;
      retired.updatedBy = actor;
      r.offerings ~= retired;
      r.offeringsRemoved++;
    }
  return r;
}

/// Derive a category from OSB tags.
ServiceCategory categoryOf(const string[] tags) {
  foreach (t; tags) {
    switch (t.toLower) {
    case "database", "sql", "nosql", "hana", "postgresql", "redis", "storage", "data":
      return ServiceCategory.data;
    case "security", "xsuaa", "identity", "auth", "credentials":
      return ServiceCategory.security;
    case "integration", "messaging", "events", "destination", "connectivity":
      return ServiceCategory.integration;
    case "ai", "ml", "genai":
      return ServiceCategory.ai;
    case "platform", "runtime":
      return ServiceCategory.platform;
    case "application", "saas":
      return ServiceCategory.application;
    default:
      break;
    }
  }
  return ServiceCategory.other;
}

///
unittest {
  ServiceBroker broker;
  broker.id = ServiceBrokerId("b1");
  broker.tenantId = TenantId("t");
  broker.name = "demo";

  CatalogServiceDef svc;
  svc.id = "svc-1";
  svc.name = "postgres";
  svc.tags = ["database"];
  svc.plans = [CatalogPlanDef("plan-1", "small"), CatalogPlanDef("plan-2", "large", "", false)];
  auto catalog = BrokerCatalog([svc]);

  auto first = reconcileCatalog(broker, [], [], catalog, 1, UserId("u"));
  assert(first.offeringsCreated == 1 && first.plansCreated == 2);
  assert(first.offerings[0].category == ServiceCategory.data);
  assert(first.plans[1].pricing == ServicePlanPricing.paid);

  // second run updates in place, and a dropped service is retired
  ServiceOffering stale;
  stale.id = ServiceOfferingId("old");
  stale.catalogId = "svc-old";
  auto second = reconcileCatalog(broker, first.offerings ~ stale, first.plans, catalog, 2, UserId("u"));
  assert(second.offeringsUpdated == 1 && second.plansUpdated == 2 && second.offeringsRemoved == 1);
  assert(second.offerings[0].id == first.offerings[0].id);
  assert(second.offerings[$ - 1].status == ServiceOfferingStatus.removed);
}
