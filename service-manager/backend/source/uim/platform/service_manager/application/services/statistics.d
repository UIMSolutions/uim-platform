/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.services.statistics;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class StatisticsService : IServiceManagerStatistics {
  protected IPlatformRepository platforms;
  protected IServiceBrokerRepository brokers;
  protected IServiceOfferingRepository offerings;
  protected IServicePlanRepository plans;
  protected IServiceInstanceRepository instances;
  protected IServiceBindingRepository bindings;
  protected IOperationRepository operations;
  protected ILabelRepository labels;

  this(IPlatformRepository platforms, IServiceBrokerRepository brokers, IServiceOfferingRepository offerings,
    IServicePlanRepository plans, IServiceInstanceRepository instances, IServiceBindingRepository bindings,
    IOperationRepository operations, ILabelRepository labels) {
    this.platforms = platforms;
    this.brokers = brokers;
    this.offerings = offerings;
    this.plans = plans;
    this.instances = instances;
    this.bindings = bindings;
    this.operations = operations;
    this.labels = labels;
  }

  ServiceManagerStatistics compute(TenantId tenantId) {
    ServiceManagerStatistics s;
    s.tenantId = tenantId;

    auto allPlatforms = platforms.findAll(tenantId);
    s.platforms = allPlatforms.length;
    s.activePlatforms = allPlatforms.count!(p => p.isActive);

    auto allBrokers = brokers.findAll(tenantId);
    s.brokers = allBrokers.length;
    s.activeBrokers = allBrokers.count!(b => b.isActive);
    s.failedBrokers = allBrokers.count!(b => b.status == ServiceBrokerStatus.registrationFailed);

    auto allOfferings = offerings.findAll(tenantId);
    s.offerings = allOfferings.length;
    s.availableOfferings = allOfferings.count!(o => o.isAvailable);
    s.plans = plans.countAll(tenantId);

    foreach (i; instances.findAll(tenantId)) {
      s.instances++;
      with (ServiceInstanceStatus) switch (i.status) {
      case created:
        s.readyInstances++;
        break;
      case creating, updating, deleting:
        s.pendingInstances++;
        break;
      case failed, orphaned:
        s.failedInstances++;
        break;
      default:
        break;
      }
    }
    s.bindings = bindings.countAll(tenantId);

    foreach (op; operations.findAll(tenantId)) {
      s.operations++;
      if (!op.isFinal)
        s.runningOperations++;
      else if (op.status == OperationStatus.failed)
        s.failedOperations++;
    }
    s.labels = labels.countAll(tenantId);
    return s;
  }
}
