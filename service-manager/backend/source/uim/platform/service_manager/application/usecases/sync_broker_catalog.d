/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.sync_broker_catalog;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class SyncBrokerCatalogUseCase : ISyncBrokerCatalog {
  protected IServiceBrokerRepository brokers;
  protected IServiceOfferingRepository offerings;
  protected IServicePlanRepository plans;
  protected IBrokerCatalogGateway gateway;

  this(IServiceBrokerRepository brokers, IServiceOfferingRepository offerings, IServicePlanRepository plans,
    IBrokerCatalogGateway gateway) {
    this.brokers = brokers;
    this.offerings = offerings;
    this.plans = plans;
    this.gateway = gateway;
  }

  CatalogSyncResult syncCatalog(TenantId tenantId, ServiceBrokerId brokerId, UserId actor) {
    auto broker = brokers.findById(tenantId, brokerId).required("Service broker '" ~ brokerId.value ~ "'");
    if (broker.status == ServiceBrokerStatus.inactive)
      throw ServiceManagerException.ruleViolation("Service broker '" ~ broker.name ~ "' is inactive");

    CatalogSyncResult result;
    result.brokerId = broker.id;
    result.brokerName = broker.name;

    BrokerCatalog catalog;
    try
      catalog = gateway.fetchCatalog(broker);
    catch (Exception e) {
      broker.catalogFailed(e.msg);
      stampUpdated(broker, actor);
      brokers.save(broker);
      throw ServiceManagerException.gateway("Catalog of service broker '" ~ broker.name ~ "' could not be fetched: " ~ e.msg);
    }

    auto now = nowStdTime();
    auto owned = offerings.findByBroker(tenantId, broker.id);
    ServicePlan[] ownedPlans;
    foreach (o; owned)
      ownedPlans ~= plans.findByOffering(tenantId, o.id);

    auto delta = reconcileCatalog(broker, owned, ownedPlans, catalog, now, actor);
    foreach (o; delta.offerings)
      offerings.save(o);
    foreach (p; delta.plans)
      plans.save(p);

    broker.catalogFetched(now);
    stampUpdated(broker, actor);
    brokers.save(broker);

    result.succeeded = true;
    result.offeringsCreated = delta.offeringsCreated;
    result.offeringsUpdated = delta.offeringsUpdated;
    result.offeringsRemoved = delta.offeringsRemoved;
    result.plansCreated = delta.plansCreated;
    result.plansUpdated = delta.plansUpdated;
    result.syncedAt = now;
    return result;
  }

  CatalogSyncResult[] syncAll(TenantId tenantId, UserId actor) {
    CatalogSyncResult[] results;
    foreach (b; brokers.findAll(tenantId)) {
      if (b.status == ServiceBrokerStatus.inactive)
        continue;
      try
        results ~= syncCatalog(tenantId, b.id, actor);
      catch (ServiceManagerException e) {
        CatalogSyncResult failed;
        failed.brokerId = b.id;
        failed.brokerName = b.name;
        failed.error = e.msg;
        results ~= failed;
      }
    }
    return results;
  }
}
