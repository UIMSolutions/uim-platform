/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the Kyma service: which kinds exist, how they are
/// named per protocol, their table columns and their actions.
module uim.platform.kyma.presentation.resources.registry;

import uim.platform.kyma;
import uim.platform.kyma.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  KymaPorts ports;

  this(KymaPorts ports) {
    this.ports = ports;
    auto p = ports;

    _adapters ~= new ResourceAdapter!(KymaEnvironment, KymaEnvironmentId, CreateEnvironmentRequest, UpdateEnvironmentRequest)(
      p.environments, "environments", "Environments", "Environment", "Environments", "")
      .column("Name", "name").column("Plan", "plan").column("Region", "region").column("Status", "status")
      .column("Nodes", "autoScalerMax").column("Kubernetes", "kubernetesVersion").column("API Server", "kubeApiServerUrl")
      .column("ID", "id")
      .action("stop", "Stop", (who, id, _) => p.environments.stop(who.tenantId, id, who.userId))
      .action("start", "Start", (who, id, _) => p.environments.start(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(KymaNamespace, NamespaceId, CreateNamespaceRequest, UpdateNamespaceRequest)(
      p.namespaces, "namespaces", "Namespaces", "Namespace", "Namespaces", "environmentId")
      .column("Name", "name").column("Status", "status").column("CPU Limit", "cpuLimit")
      .column("Memory Limit", "memoryLimit").column("Istio", "istioInjection").column("Environment", "environmentId")
      .column("ID", "id");

    _adapters ~= new ResourceAdapter!(ServerlessFunction, ServerlessFunctionId, CreateFunctionRequest, UpdateFunctionRequest)(
      p.functions, "functions", "Functions", "Function", "Serverless Functions", "namespaceId")
      .column("Name", "name").column("Namespace", "namespaceName").column("Runtime", "runtime")
      .column("Status", "status").column("Replicas", "maxReplicas").column("Handler", "handler").column("ID", "id");

    _adapters ~= new ResourceAdapter!(ApiRule, ApiRuleId, CreateApiRuleRequest, UpdateApiRuleRequest)(
      p.apiRules, "api-rules", "ApiRules", "ApiRule", "API Rules", "namespaceId")
      .column("Name", "name").column("Namespace", "namespaceName").column("Host", "host")
      .column("Service", "serviceName").column("Port", "servicePort").column("Status", "status").column("ID", "id");

    _adapters ~= new ResourceAdapter!(ServiceInstance, ServiceInstanceId, CreateServiceInstanceRequest, UpdateServiceInstanceRequest)(
      p.serviceInstances, "service-instances", "ServiceInstances", "ServiceInstance", "Service Instances", "namespaceId")
      .column("Name", "name").column("Namespace", "namespaceName").column("Offering", "serviceOfferingName")
      .column("Plan", "servicePlanName").column("Status", "status").column("Bindings", "bindingCount").column("ID", "id");

    _adapters ~= new ResourceAdapter!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest, UpdateServiceBindingRequest)(
      p.serviceBindings, "service-bindings", "ServiceBindings", "ServiceBinding", "Service Bindings", "serviceInstanceId")
      .column("Name", "name").column("Namespace", "namespaceName").column("Instance", "serviceInstanceName")
      .column("Secret", "secretName").column("Status", "status").column("ID", "id");

    _adapters ~= new ResourceAdapter!(EventSubscription, EventSubscriptionId, CreateEventSubscriptionRequest, UpdateEventSubscriptionRequest)(
      p.subscriptions, "event-subscriptions", "EventSubscriptions", "EventSubscription", "Event Subscriptions", "namespaceId")
      .column("Name", "name").column("Namespace", "namespaceName").column("Source", "source")
      .column("Event Types", "eventTypes").column("Sink", "sinkUrl").column("Status", "status").column("ID", "id")
      .action("pause", "Pause", (who, id, _) => p.subscriptions.pause(who.tenantId, id, who.userId))
      .action("resume", "Resume", (who, id, _) => p.subscriptions.resume(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(KymaModule, KymaModuleId, EnableModuleRequest, UpdateModuleRequest)(
      p.modules, "modules", "Modules", "Module", "Kyma Modules", "environmentId")
      .column("Name", "name").column("Version", "version").column("Channel", "channel")
      .column("Status", "status").column("Requires", "requiredModules").column("Environment", "environmentId")
      .column("ID", "id")
      .action("disable", "Disable", (who, id, _) => p.modules.disable(who.tenantId, id, who.userId))
      .action("enable", "Enable", (who, id, _) => p.modules.enable(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(KymaApplication, ApplicationId, RegisterApplicationRequest, UpdateApplicationRequest)(
      p.applications, "applications", "Applications", "Application", "Applications", "environmentId")
      .column("Name", "name").column("Type", "registrationType").column("Status", "status")
      .column("Bound Namespaces", "boundNamespaces").column("Connector", "connectorUrl").column("ID", "id")
      .action("connect", "Connect", (who, id, _) => p.applications.connect(who.tenantId, id, who.userId))
      .action("disconnect", "Disconnect", (who, id, _) => p.applications.disconnect(who.tenantId, id, who.userId))
      .action("bind", "Bind Namespace", (who, id, params) => p.applications.bindNamespace(who.tenantId, id,
          fieldString(params, "namespace"), who.userId), ["namespace"])
      .action("unbind", "Unbind Namespace", (who, id, params) => p.applications.unbindNamespace(who.tenantId, id,
          fieldString(params, "namespace"), who.userId), ["namespace"]);
  }

  IResourceAdapter[] adapters() {
    return _adapters;
  }

  /// Adapter by REST path / CLI command (null if unknown).
  IResourceAdapter byPath(string path) {
    foreach (a; _adapters)
      if (a.path == path)
        return a;
    return null;
  }

  /// Adapter by OData entity set (null if unknown).
  IResourceAdapter bySet(string setName) {
    foreach (a; _adapters)
      if (a.setName == setName)
        return a;
    return null;
  }

  /// Adapter owning an OData action name (null if unknown); `action` receives the action.
  IResourceAdapter byODataAction(string odataName, out ResourceAction action) {
    foreach (a; _adapters)
      foreach (act; a.actions)
        if (act.odataName == odataName) {
          action = act;
          return a;
        }
    return null;
  }

  /// An id, or the id of the unique resource of `adapter` with that name.
  string resolve(IResourceAdapter adapter, TenantId tenantId, string idOrName) {
    if (adapter.get(tenantId, idOrName).type != Json.Type.null_)
      return idOrName;
    auto matches = adapter.list(tenantId, ["name": idOrName]);
    if (matches.length == 1)
      return matches[0]["id"].get!string;
    if (matches.length > 1)
      throw new ResourceError(400, "Ambiguous", "'" ~ idOrName ~ "' matches " ~ matches.length.to!string
          ~ " " ~ adapter.path ~ " — use the id");
    throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ idOrName ~ "' not found");
  }

  /// Resolve the value of a parent field (environmentId, namespaceId, serviceInstanceId).
  string resolveParent(string field, TenantId tenantId, string idOrName) {
    switch (field) {
    case "environmentId":
      return resolve(byPath("environments"), tenantId, idOrName);
    case "namespaceId":
      return resolve(byPath("namespaces"), tenantId, idOrName);
    case "serviceInstanceId":
      return resolve(byPath("service-instances"), tenantId, idOrName);
    default:
      return idOrName;
    }
  }

  /// Statistics payload.
  Json statistics(TenantId tenantId) {
    return encode(ports.statistics.statistics(tenantId), true);
  }

  /// Reconcile and return the report payload.
  Json reconcile(TenantId tenantId) {
    return encode(ports.reconciler.reconcile(tenantId), true);
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  KymaConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");

  auto envs = registry.byPath("environments");
  auto env = envs.create(who, parseJsonString(`{"name": "dev", "plan": "gcp"}`));
  assert(env["status"].get!string == "provisioning");
  assert(env["region"].get!string == "europe-west3");
  auto envId = env["id"].get!string;

  auto ns = registry.byPath("namespaces").create(who, parseJsonString(`{"environmentId": "` ~ envId
      ~ `", "name": "shop", "labels": {"team": "orders"}}`));
  assert(ns["labels"][0]["key"].get!string == "team");

  // PATCH keeps unspecified fields
  auto patched = registry.byPath("namespaces").update(who, ns["id"].get!string, parseJsonString(`{"cpuLimit": "2"}`));
  assert(patched["cpuLimit"].get!string == "2" && patched["labels"].length == 1);

  // business errors become ResourceErrors with HTTP status
  int status;
  try registry.byPath("namespaces").create(who, parseJsonString(`{"environmentId": "` ~ envId ~ `", "name": "kyma-system"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 422);

  ResourceAction stop;
  assert(registry.byODataAction("StopEnvironment", stop) is envs && stop.name == "stop");
  registry.reconcile(who.tenantId);
  assert(envs.invoke(who, envId, "stop", Json.emptyObject)["status"].get!string == "stopping");

  assert(registry.byPath("environments").list(who.tenantId, ["plan": "gcp"]).length == 1);
  assert(registry.byPath("environments").list(who.tenantId, ["plan": "aws"]).length == 0);
  assert(registry.statistics(who.tenantId)["environments"].get!long == 1);
  assert(registry.bySet("Functions").inputFields[0].name == "namespaceId");
}
