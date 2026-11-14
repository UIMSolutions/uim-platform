/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.service_manager.persistence.repositories.repositories;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class PlatformRepository : DocumentRepository!(Platform, PlatformId, platformToRecord, recordToPlatform), IPlatformRepository {
  this(IDocumentStore store) {
    super(store, Collections.platforms);
  }

  Platform findByName(TenantId t, string name) {
    return first(t, (const Platform e) => e.name == name);
  }
}

class ServiceBrokerRepository : DocumentRepository!(ServiceBroker, ServiceBrokerId, brokerToRecord, recordToBroker),
IServiceBrokerRepository {
  this(IDocumentStore store) {
    super(store, Collections.serviceBrokers);
  }

  ServiceBroker findByName(TenantId t, string name) {
    return first(t, (const ServiceBroker e) => e.name == name);
  }

  ServiceBroker[] findByStatus(TenantId t, ServiceBrokerStatus status) {
    return where(t, (const ServiceBroker e) => e.status == status);
  }
}

class ServiceOfferingRepository : DocumentRepository!(ServiceOffering, ServiceOfferingId, offeringToRecord, recordToOffering),
IServiceOfferingRepository {
  this(IDocumentStore store) {
    super(store, Collections.serviceOfferings);
  }

  ServiceOffering[] findByBroker(TenantId t, ServiceBrokerId brokerId) {
    return where(t, (const ServiceOffering e) => e.brokerId == brokerId);
  }

  ServiceOffering findByName(TenantId t, ServiceBrokerId brokerId, string name) {
    return first(t, (const ServiceOffering e) => e.brokerId == brokerId && e.name == name);
  }
}

class ServicePlanRepository : DocumentRepository!(ServicePlan, ServicePlanId, planToRecord, recordToPlan), IServicePlanRepository {
  this(IDocumentStore store) {
    super(store, Collections.servicePlans);
  }

  ServicePlan[] findByOffering(TenantId t, ServiceOfferingId offeringId) {
    return where(t, (const ServicePlan e) => e.offeringId == offeringId);
  }
}

class ServiceInstanceRepository : DocumentRepository!(ServiceInstance, ServiceInstanceId, instanceToRecord, recordToInstance),
IServiceInstanceRepository {
  this(IDocumentStore store) {
    super(store, Collections.serviceInstances);
  }

  ServiceInstance findByName(TenantId t, string name) {
    return first(t, (const ServiceInstance e) => e.name == name);
  }

  ServiceInstance[] findByPlan(TenantId t, ServicePlanId planId) {
    return where(t, (const ServiceInstance e) => e.planId == planId);
  }

  ServiceInstance[] findByOffering(TenantId t, ServiceOfferingId offeringId) {
    return where(t, (const ServiceInstance e) => e.offeringId == offeringId);
  }

  ServiceInstance[] findByPlatform(TenantId t, PlatformId platformId) {
    return where(t, (const ServiceInstance e) => e.platformId == platformId);
  }
}

class ServiceBindingRepository : DocumentRepository!(ServiceBinding, ServiceBindingId, bindingToRecord, recordToBinding),
IServiceBindingRepository {
  this(IDocumentStore store) {
    super(store, Collections.serviceBindings);
  }

  ServiceBinding[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
    return where(t, (const ServiceBinding e) => e.instanceId == instanceId);
  }
}

class OperationRepository : DocumentRepository!(Operation, OperationId, operationToRecord, recordToOperation), IOperationRepository {
  this(IDocumentStore store) {
    super(store, Collections.operations);
  }

  Operation[] findByResource(TenantId t, ResourceType type, string resourceId) {
    return where(t, (const Operation e) => e.resourceType == type && e.resourceId == resourceId);
  }

  Operation[] findByStatus(TenantId t, OperationStatus status) {
    return where(t, (const Operation e) => e.status == status);
  }
}

class LabelRepository : DocumentRepository!(Label, LabelId, labelToRecord, recordToLabel), ILabelRepository {
  this(IDocumentStore store) {
    super(store, Collections.labels);
  }

  Label[] findByResource(TenantId t, ResourceType type, string resourceId) {
    return where(t, (const Label e) => e.resourceType == type && e.resourceId == resourceId);
  }

  size_t removeByResource(TenantId t, ResourceType type, string resourceId) {
    auto matching = findByResource(t, type, resourceId);
    foreach (l; matching)
      removeById(t, l.id);
    return matching.length;
  }
}

///
unittest {
  auto store = new MemoryDocumentStore;
  auto repo = new PlatformRepository(store);
  auto t = TenantId("t1");
  Platform p;
  p.id = PlatformId("p1");
  p.tenantId = t;
  p.name = "cf";
  repo.save(p);
  assert(repo.existsById(t, p.id) && repo.countAll(t) == 1);
  assert(repo.findByName(t, "cf").id == p.id);
  assert(repo.findById(TenantId("other"), p.id).isNull); // tenant isolation
  assert(repo.removeById(t, p.id) && repo.findAll(t).length == 0);
}
