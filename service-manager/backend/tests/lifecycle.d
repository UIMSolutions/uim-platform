/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests through the driving ports and the OData engine
/// (memory store, fake broker gateway). Run with: dub test --config=defaultTest
module tests.lifecycle;

import uim.platform.service_manager;

@safe:

version (unittest) {
  private class FakeGateway : IBrokerCatalogGateway {
    BrokerCatalog catalog;
    bool fail;

    BrokerCatalog fetchCatalog(const ServiceBroker broker) {
      if (fail)
        throw ServiceManagerException.gateway("connection refused");
      return catalog;
    }
  }

  private ServiceManagerContainer container(bool sync, IBrokerCatalogGateway gateway = null) {
    Json[string] o;
    o["storage"] = "memory";
    o["syncProvisioning"] = sync;
    return new ServiceManagerContainer(loadServiceManagerConfig(o, "/nonexistent"), gateway);
  }

  private int status(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }
}

/// Asynchronous provisioning: operations stay inProgress until completed.
unittest {
  auto gw = new FakeGateway;
  CatalogServiceDef svc;
  svc.id = "svc-pg";
  svc.name = "postgres";
  svc.tags = ["database"];
  svc.plans = [CatalogPlanDef("p1", "small")];
  gw.catalog = BrokerCatalog([svc]);

  auto c = container(false, gw);
  auto e = c.engine;
  auto ctx = RequestContext.local("t1", "test", "tester");

  auto broker = e.create(ctx, "ServiceBrokers", parseJsonString(`{"name":"b","brokerUrl":"https://broker.example.com"}`));
  auto sync = e.invoke(ctx, "SyncBrokerCatalog", parseJsonString(`{"brokerId":"` ~ broker["id"].get!string ~ `"}`));
  assert(sync["offeringsCreated"].get!long == 1 && sync["plansCreated"].get!long == 1);

  auto plan = e.query(ctx, "ServicePlans", ["$filter": "name eq 'small'"]).rows[0];
  auto inst = e.create(ctx, "ServiceInstances", parseJsonString(`{"name":"db","planId":"` ~ plan["id"].get!string ~ `"}`));
  assert(inst["status"].get!string == "creating");

  // no binding while the instance is still being created
  assert(status(() {
      e.create(ctx, "ServiceBindings", parseJsonString(`{"name":"k","instanceId":"` ~ inst["id"].get!string ~ `"}`));
    }) == 422);

  // broker callback: provisioning finished
  auto done = e.invoke(ctx, "CompleteOperation", parseJsonString(`{"operationId":"` ~ inst["lastOperationId"].get!string
      ~ `","succeeded":true}`));
  assert(done["status"].get!string == "succeeded");
  assert(e.read(ctx, "ServiceInstances", inst["id"].get!string)["status"].get!string == "created");
  assert(status(() {
      e.invoke(ctx, "CompleteOperation", parseJsonString(`{"operationId":"` ~ inst["lastOperationId"].get!string
        ~ `","succeeded":true}`));
    }) == 409);

  // binding with generated credentials
  auto binding = e.create(ctx, "ServiceBindings", parseJsonString(`{"name":"k","instanceId":"` ~ inst["id"].get!string ~ `"}`));
  e.invoke(ctx, "CompleteOperation", parseJsonString(`{"operationId":"` ~ binding["lastOperationId"].get!string ~ `","succeeded":true}`));
  assert(parseJsonString(e.read(ctx, "ServiceBindings", binding["id"].get!string)["credentials"].get!string)["clientsecret"]
      .get!string.length == 36);

  // integrity: plan in use, instance bound, broker owning instances
  assert(status(() { e.remove(ctx, "ServicePlans", plan["id"].get!string); }) == 422);
  assert(status(() { e.remove(ctx, "ServiceInstances", inst["id"].get!string); }) == 422);
  assert(status(() { e.remove(ctx, "ServiceBrokers", broker["id"].get!string); }) == 422);

  // unbind → deleting → removed by the operation callback
  e.remove(ctx, "ServiceBindings", binding["id"].get!string);
  auto unbinding = e.read(ctx, "ServiceBindings", binding["id"].get!string);
  assert(unbinding["status"].get!string == "deleting");
  e.invoke(ctx, "CompleteOperation", parseJsonString(`{"operationId":"` ~ unbinding["lastOperationId"].get!string ~ `","succeeded":true}`));
  assert(status(() { e.read(ctx, "ServiceBindings", binding["id"].get!string); }) == 404);

  // failed deprovisioning leaves the instance in 'failed'
  e.remove(ctx, "ServiceInstances", inst["id"].get!string);
  auto deleting = e.read(ctx, "ServiceInstances", inst["id"].get!string);
  e.invoke(ctx, "CompleteOperation", parseJsonString(`{"operationId":"` ~ deleting["lastOperationId"].get!string
      ~ `","succeeded":false,"errorMessage":"broker timeout"}`));
  assert(e.read(ctx, "ServiceInstances", inst["id"].get!string)["status"].get!string == "failed");
  assert(e.read(ctx, "Statistics", "")["failedOperations"].get!long == 1);

  // tenant isolation
  assert(e.query(RequestContext.local("t2", "test"), "ServiceInstances", null).total == 0);
}

/// Catalog sync failures, retired offerings, quotas and labels.
unittest {
  auto gw = new FakeGateway;
  CatalogServiceDef svc;
  svc.id = "svc-1";
  svc.name = "cache";
  auto quota = CatalogPlanDef("p1", "one");
  quota.maxInstances = 1;
  svc.plans = [quota];
  gw.catalog = BrokerCatalog([svc]);

  auto c = container(true, gw);
  auto e = c.engine;
  auto ctx = RequestContext.local("t1", "test", "tester");
  auto brokerId = e.create(ctx, "ServiceBrokers", parseJsonString(`{"name":"b","brokerUrl":"http://b.local"}`))["id"].get!string;

  gw.fail = true;
  assert(status(() { e.invoke(ctx, "SyncBrokerCatalog", parseJsonString(`{"brokerId":"` ~ brokerId ~ `"}`)); }) == 502);
  assert(e.read(ctx, "ServiceBrokers", brokerId)["status"].get!string == "registrationFailed");

  gw.fail = false;
  e.invoke(ctx, "SyncBrokerCatalog", parseJsonString(`{"brokerId":"` ~ brokerId ~ `"}`));
  assert(e.read(ctx, "ServiceBrokers", brokerId)["status"].get!string == "active");

  auto planId = e.query(ctx, "ServicePlans", null).rows[0]["id"].get!string;
  auto inst = e.create(ctx, "ServiceInstances", parseJsonString(`{"name":"c1","planId":"` ~ planId ~ `"}`));
  assert(inst["status"].get!string == "created");
  assert(status(() { e.create(ctx, "ServiceInstances", parseJsonString(`{"name":"c2","planId":"` ~ planId ~ `"}`)); }) == 422);
  assert(status(() { e.create(ctx, "ServiceInstances", parseJsonString(`{"name":"c1","planId":"` ~ planId ~ `"}`)); }) == 422);

  // labels: resource must exist, keys unique per resource, removed with the resource
  e.create(ctx, "Labels", parseJsonString(`{"resourceType":"serviceInstance","resourceId":"` ~ inst["id"].get!string
      ~ `","key":"env","value":"dev"}`));
  assert(status(() {
      e.create(ctx, "Labels", parseJsonString(`{"resourceType":"serviceInstance","resourceId":"` ~ inst["id"].get!string
        ~ `","key":"env","value":"prod"}`));
    }) == 409);
  assert(status(() {
      e.create(ctx, "Labels", parseJsonString(`{"resourceType":"serviceInstance","resourceId":"nope","key":"env"}`));
    }) == 404);
  e.remove(ctx, "ServiceInstances", inst["id"].get!string);
  assert(e.query(ctx, "Labels", null).total == 0);

  // broker drops the service → offering retired, no new instances
  gw.catalog = BrokerCatalog.init;
  auto sync = e.invoke(ctx, "SyncBrokerCatalog", parseJsonString(`{"brokerId":"` ~ brokerId ~ `"}`));
  assert(sync["offeringsRemoved"].get!long == 1);
  assert(e.query(ctx, "ServiceOfferings", null).rows[0]["status"].get!string == "removed");
  assert(status(() { e.create(ctx, "ServiceInstances", parseJsonString(`{"name":"c3","planId":"` ~ planId ~ `"}`)); }) == 422);

  // secrets are write-only
  auto p = e.create(ctx, "Platforms", parseJsonString(`{"name":"cf","type":"cloudFoundry","credentials":"s3cret"}`));
  assert(p["credentials"].type == Json.Type.null_ && p["hasCredentials"].get!bool);
  assert(status(() { e.create(ctx, "Platforms", parseJsonString(`{"name":"k","type":"mainframe"}`)); }) == 400);
}
