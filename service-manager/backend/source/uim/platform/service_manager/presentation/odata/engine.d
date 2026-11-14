/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST controller, the CLI and the GUI.
module uim.platform.service_manager.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates ServiceManagerException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

private size_t[string] countBy(T)(T[] items, scope string delegate(const T) @safe keyOf) {
  size_t[string] counts;
  foreach (item; items)
    counts[keyOf(item)]++;
  return counts;
}

ODataEngine serviceManagerEngine(ServiceManagerPorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(serviceManagerModel());

  // ── Platforms ─────────────────────────────────────────────────────────────
  auto platforms = new DelegateEntitySetProvider;
  platforms.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto used = countBy(ports.instances.listInstances(t), (const ServiceInstance i) => i.platformId.value);
    Json[] rows;
    foreach (e; ports.platforms.listPlatforms(t))
      rows ~= platformRow(e, used.get(e.id.value, 0));
    return rows;
  };
  platforms.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.platforms.getPlatform(t, PlatformId(key));
    return platformRow(e, ports.instances.listInstances(t).count!(i => i.platformId == e.id));
  };
  platforms.onCreate = (const RequestContext ctx, Json p) => platformRow(ports.platforms.registerPlatform(
      registerPlatformRequest(ctx, p)));
  platforms.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.platforms.updatePlatform(updatePlatformRequest(ctx, key, p));
    return platforms.onGet(ctx, key);
  };
  platforms.onRemove = (const RequestContext ctx, string key) {
    ports.platforms.deregisterPlatform(tenantOf(ctx), PlatformId(key));
  };

  // ── Service brokers ───────────────────────────────────────────────────────
  auto brokers = new DelegateEntitySetProvider;
  brokers.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto owned = countBy(ports.offerings.listOfferings(t), (const ServiceOffering o) => o.brokerId.value);
    Json[] rows;
    foreach (e; ports.brokers.listBrokers(t))
      rows ~= brokerRow(e, owned.get(e.id.value, 0));
    return rows;
  };
  brokers.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.brokers.getBroker(t, ServiceBrokerId(key));
    return brokerRow(e, ports.offerings.listOfferings(t).count!(o => o.brokerId == e.id));
  };
  brokers.onCreate = (const RequestContext ctx, Json p) => brokerRow(ports.brokers.registerBroker(registerBrokerRequest(ctx, p)));
  brokers.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.brokers.updateBroker(updateBrokerRequest(ctx, key, p));
    return brokers.onGet(ctx, key);
  };
  brokers.onRemove = (const RequestContext ctx, string key) {
    ports.brokers.deregisterBroker(tenantOf(ctx), ServiceBrokerId(key));
  };

  // ── Service offerings ─────────────────────────────────────────────────────
  auto offerings = new DelegateEntitySetProvider;
  offerings.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto owned = countBy(ports.plans.listPlans(t), (const ServicePlan p) => p.offeringId.value);
    Json[] rows;
    foreach (e; ports.offerings.listOfferings(t))
      rows ~= offeringRow(e, owned.get(e.id.value, 0));
    return rows;
  };
  offerings.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.offerings.getOffering(t, ServiceOfferingId(key));
    return offeringRow(e, ports.plans.listPlans(t).count!(p => p.offeringId == e.id));
  };
  offerings.onCreate = (const RequestContext ctx, Json p) => offeringRow(ports.offerings.createOffering(
      createOfferingRequest(ctx, p)));
  offerings.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.offerings.updateOffering(updateOfferingRequest(ctx, key, p));
    return offerings.onGet(ctx, key);
  };
  offerings.onRemove = (const RequestContext ctx, string key) {
    ports.offerings.deleteOffering(tenantOf(ctx), ServiceOfferingId(key));
  };

  // ── Service plans ─────────────────────────────────────────────────────────
  auto plans = new DelegateEntitySetProvider;
  plans.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto used = countBy(ports.instances.listInstances(t), (const ServiceInstance i) => i.planId.value);
    Json[] rows;
    foreach (e; ports.plans.listPlans(t))
      rows ~= planRow(e, used.get(e.id.value, 0));
    return rows;
  };
  plans.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.plans.getPlan(t, ServicePlanId(key));
    return planRow(e, ports.instances.listInstances(t).count!(i => i.planId == e.id));
  };
  plans.onCreate = (const RequestContext ctx, Json p) => planRow(ports.plans.createPlan(createPlanRequest(ctx, p)));
  plans.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.plans.updatePlan(updatePlanRequest(ctx, key, p));
    return plans.onGet(ctx, key);
  };
  plans.onRemove = (const RequestContext ctx, string key) {
    ports.plans.deletePlan(tenantOf(ctx), ServicePlanId(key));
  };

  // ── Service instances ─────────────────────────────────────────────────────
  auto instances = new DelegateEntitySetProvider;
  instances.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto bound = countBy(ports.bindings.listBindings(t), (const ServiceBinding b) => b.instanceId.value);
    Json[] rows;
    foreach (e; ports.instances.listInstances(t))
      rows ~= instanceRow(e, bound.get(e.id.value, 0));
    return rows;
  };
  instances.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.instances.getInstance(t, ServiceInstanceId(key));
    return instanceRow(e, ports.bindings.listBindings(t).count!(b => b.instanceId == e.id));
  };
  instances.onCreate = (const RequestContext ctx, Json p) => instanceRow(ports.instances.provisionInstance(
      provisionInstanceRequest(ctx, p)));
  instances.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.instances.updateInstance(updateInstanceRequest(ctx, key, p));
    return instances.onGet(ctx, key);
  };
  instances.onRemove = (const RequestContext ctx, string key) {
    ports.instances.deprovisionInstance(tenantOf(ctx), ServiceInstanceId(key), actorOf(ctx));
  };

  // ── Service bindings ──────────────────────────────────────────────────────
  auto bindings = new DelegateEntitySetProvider;
  bindings.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.bindings.listBindings(tenantOf(ctx)))
      rows ~= bindingRow(e);
    return rows;
  };
  bindings.onGet = (const RequestContext ctx, string key) => bindingRow(ports.bindings.getBinding(tenantOf(ctx),
      ServiceBindingId(key)));
  bindings.onCreate = (const RequestContext ctx, Json p) => bindingRow(ports.bindings.createBinding(
      createBindingRequest(ctx, p)));
  bindings.onRemove = (const RequestContext ctx, string key) {
    ports.bindings.deleteBinding(tenantOf(ctx), ServiceBindingId(key), actorOf(ctx));
  };

  // ── Operations ────────────────────────────────────────────────────────────
  auto operations = new DelegateEntitySetProvider;
  operations.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.operations.listOperations(tenantOf(ctx)))
      rows ~= operationRow(e);
    return rows;
  };
  operations.onGet = (const RequestContext ctx, string key) => operationRow(ports.operations.getOperation(tenantOf(ctx),
      OperationId(key)));
  operations.onRemove = (const RequestContext ctx, string key) {
    ports.operations.deleteOperation(tenantOf(ctx), OperationId(key));
  };

  // ── Labels ────────────────────────────────────────────────────────────────
  auto labels = new DelegateEntitySetProvider;
  labels.onList = (const RequestContext ctx) {
    Json[] rows;
    foreach (e; ports.labels.listLabels(tenantOf(ctx)))
      rows ~= labelRow(e);
    return rows;
  };
  labels.onGet = (const RequestContext ctx, string key) => labelRow(ports.labels.getLabel(tenantOf(ctx), LabelId(key)));
  labels.onCreate = (const RequestContext ctx, Json p) => labelRow(ports.labels.createLabel(createLabelRequest(ctx, p)));
  labels.onUpdate = (const RequestContext ctx, string key, Json p) => labelRow(ports.labels.updateLabel(
      updateLabelRequest(ctx, key, p)));
  labels.onRemove = (const RequestContext ctx, string key) {
    ports.labels.deleteLabel(tenantOf(ctx), LabelId(key));
  };

  // ── Statistics (singleton) ────────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("Platforms", new PortProvider(platforms))
    .provide("ServiceBrokers", new PortProvider(brokers))
    .provide("ServiceOfferings", new PortProvider(offerings))
    .provide("ServicePlans", new PortProvider(plans))
    .provide("ServiceInstances", new PortProvider(instances))
    .provide("ServiceBindings", new PortProvider(bindings))
    .provide("Operations", new PortProvider(operations))
    .provide("Labels", new PortProvider(labels))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ───────────────────────────────────────────────────────────────
  engine.handle("SyncBrokerCatalog", (const RequestContext ctx, Json p) => translated!Json(() => syncResultRow(
      ports.catalogSync.syncCatalog(tenantOf(ctx), ServiceBrokerId(textOf(p, "brokerId")), actorOf(ctx)))));
  engine.handle("CompleteOperation", (const RequestContext ctx, Json p) => translated!Json(
      () => operationResultRow(ports.operations.completeOperation(completeOperationRequest(ctx, p)))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
