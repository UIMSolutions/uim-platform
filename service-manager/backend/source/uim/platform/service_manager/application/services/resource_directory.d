/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Resolves typed resource references (used by labels).
module uim.platform.service_manager.application.services.resource_directory;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ResourceDirectory {
  protected IPlatformRepository platforms;
  protected IServiceBrokerRepository brokers;
  protected IServiceOfferingRepository offerings;
  protected IServicePlanRepository plans;
  protected IServiceInstanceRepository instances;
  protected IServiceBindingRepository bindings;

  this(IPlatformRepository platforms, IServiceBrokerRepository brokers, IServiceOfferingRepository offerings,
    IServicePlanRepository plans, IServiceInstanceRepository instances, IServiceBindingRepository bindings) {
    this.platforms = platforms;
    this.brokers = brokers;
    this.offerings = offerings;
    this.plans = plans;
    this.instances = instances;
    this.bindings = bindings;
  }

  bool exists(TenantId tenantId, ResourceType type, string id) {
    final switch (type) {
    case ResourceType.platform:
      return platforms.existsById(tenantId, PlatformId(id));
    case ResourceType.serviceBroker:
      return brokers.existsById(tenantId, ServiceBrokerId(id));
    case ResourceType.serviceOffering:
      return offerings.existsById(tenantId, ServiceOfferingId(id));
    case ResourceType.servicePlan:
      return plans.existsById(tenantId, ServicePlanId(id));
    case ResourceType.serviceInstance:
      return instances.existsById(tenantId, ServiceInstanceId(id));
    case ResourceType.serviceBinding:
      return bindings.existsById(tenantId, ServiceBindingId(id));
    }
  }
}
