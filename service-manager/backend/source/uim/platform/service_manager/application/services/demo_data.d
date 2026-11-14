/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for local development (CLI `seed`, GUI, Fiori app).
module uim.platform.service_manager.application.services.demo_data;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct DemoDataResult {
  size_t platforms, brokers, offerings, plans, instances, bindings, labels;
}

/// Load a small, consistent data set into an empty tenant. Existing data
/// is never touched: a non-empty tenant answers conflict.
DemoDataResult seedDemoData(ServiceManagerPorts ports, TenantId tenantId, UserId actor) {
  if (ports.platforms.listPlatforms(tenantId).length || ports.brokers.listBrokers(tenantId).length)
    throw ServiceManagerException.conflict("Tenant '" ~ tenantId.value ~ "' already contains data");

  DemoDataResult r;

  RegisterPlatformRequest cf;
  cf.tenantId = tenantId;
  cf.actor = actor;
  cf.name = "cf-eu10-dev";
  cf.description = "Cloud Foundry development space";
  cf.type = PlatformType.cloudFoundry;
  cf.region = "eu10";
  auto platform = ports.platforms.registerPlatform(cf);
  RegisterPlatformRequest k8s = cf;
  k8s.name = "kyma-eu10-prod";
  k8s.description = "Kyma production cluster";
  k8s.type = PlatformType.kyma;
  ports.platforms.registerPlatform(k8s);
  r.platforms = 2;

  RegisterServiceBrokerRequest broker;
  broker.tenantId = tenantId;
  broker.actor = actor;
  broker.name = "uim-platform-broker";
  broker.description = "Brokers the UIM platform services";
  broker.brokerUrl = "http://localhost:9090/broker";
  auto b = ports.brokers.registerBroker(broker);
  r.brokers = 1;

  struct Seed {
    string name, description, category;
    string[] tags;
    string[2][] plans; // [name, pricing]
  }

  auto seeds = [
    Seed("xsuaa", "Authorization and trust management", "security", ["xsuaa", "security"], [["application", "free"], ["broker", "paid"]]),
    Seed("destination", "Destination service for outbound connectivity", "integration", ["destination"], [["lite", "free"]]),
    Seed("postgresql-db", "Managed PostgreSQL database", "data", ["database", "postgresql"], [["trial", "free"], ["standard", "paid"]]),
    Seed("ai-core", "Generative AI hub and model serving", "ai", ["ai"], [["extended", "beta"]])
  ];

  ServicePlan firstPlan;
  foreach (seed; seeds) {
    CreateServiceOfferingRequest o;
    o.tenantId = tenantId;
    o.actor = actor;
    o.brokerId = b.id.value;
    o.name = seed.name;
    o.description = seed.description;
    o.category = seed.category;
    o.tags = seed.tags;
    auto offering = ports.offerings.createOffering(o);
    r.offerings++;
    foreach (p; seed.plans) {
      CreateServicePlanRequest plan;
      plan.tenantId = tenantId;
      plan.actor = actor;
      plan.offeringId = offering.id.value;
      plan.name = p[0];
      plan.pricing = p[1];
      plan.description = seed.name ~ " " ~ p[0] ~ " plan";
      auto created = ports.plans.createPlan(plan);
      if (firstPlan.isNull)
        firstPlan = created;
      r.plans++;
    }
  }

  ProvisionServiceInstanceRequest inst;
  inst.tenantId = tenantId;
  inst.actor = actor;
  inst.name = "my-app-uaa";
  inst.planId = firstPlan.id.value;
  inst.platformId = platform.id.value;
  inst.parameters = `{"xsappname":"my-app","tenant-mode":"dedicated"}`;
  auto instance = ports.instances.provisionInstance(inst);
  r.instances = 1;
  if (!instance.isReady) { // asynchronous mode: complete the operation like a broker callback
    CompleteOperationRequest done;
    done.tenantId = tenantId;
    done.actor = actor;
    done.id = instance.lastOperationId;
    ports.operations.completeOperation(done);
  }

  CreateServiceBindingRequest bind;
  bind.tenantId = tenantId;
  bind.actor = actor;
  bind.instanceId = instance.id.value;
  bind.name = "my-app-uaa-key";
  auto binding = ports.bindings.createBinding(bind);
  r.bindings = 1;
  if (binding.status != ServiceBindingStatus.created) {
    CompleteOperationRequest done;
    done.tenantId = tenantId;
    done.actor = actor;
    done.id = binding.lastOperationId;
    ports.operations.completeOperation(done);
  }

  CreateLabelRequest label;
  label.tenantId = tenantId;
  label.actor = actor;
  label.resourceType = ResourceType.serviceInstance;
  label.resourceId = instance.id.value;
  label.key = "env";
  label.value = "dev";
  ports.labels.createLabel(label);
  r.labels = 1;
  return r;
}
