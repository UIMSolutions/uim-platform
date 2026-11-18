/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the provisioning service: which kinds exist, how
/// they are named per protocol, their table columns and actions — plus the
/// non-resource operations (run due jobs, preview a transformation, purge logs).
module uim.platform.identity_provisioning.presentation.resources.registry;

import uim.platform.identity_provisioning;
import uim.platform.identity_provisioning.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference another resource by id or unique name.
string referencePath(string field) pure {
  switch (field) {
  case "sourceSystemId":
    return "source-systems";
  case "targetSystemId":
    return "target-systems";
  case "jobId":
    return "provisioning-jobs";
  default:
    return "";
  }
}

/// Run `action`; business exceptions become ResourceErrors with their status.
T provisioning(T)(scope T delegate() @safe action) {
  try
    return action();
  catch (ProvisioningException e) {
    auto code = e.status == 404 ? "NotFound" : e.status == 409 ? "Conflict"
      : e.status == 422 ? "BusinessRuleViolation" : "BadRequest";
    throw new ResourceError(e.status, code, e.msg);
  }
}

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  ProvisioningPorts ports;

  this(ProvisioningPorts ports) {
    this.ports = ports;
    auto p = ports;

    _adapters ~= systemAdapter!(SourceSystem, SourceSystemId)(p.sourceSystems, "source-systems", "SourceSystems",
      "SourceSystem", "Source Systems");
    _adapters ~= systemAdapter!(TargetSystem, TargetSystemId)(p.targetSystems, "target-systems", "TargetSystems",
      "TargetSystem", "Target Systems");
    _adapters ~= systemAdapter!(ProxySystem, ProxySystemId)(p.proxySystems, "proxy-systems", "ProxySystems",
      "ProxySystem", "Proxy Systems");

    _adapters ~= new ResourceAdapter!(Transformation, TransformationId, CreateTransformationRequest,
      UpdateTransformationRequest)(p.transformations, "transformations", "Transformations", "Transformation",
      "Transformations", "")
      .column("Name", "name").column("Role", "systemRole").column("System", "systemName").column("Scope", "scope")
      .column("Seq", "sequence").column("Active", "active").column("Mappings", "mappings")
      .column("Conditions", "conditions").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.transformations.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.transformations.deactivate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ProvisioningJob, ProvisioningJobId, CreateJobRequest, UpdateJobRequest)(
      p.jobs, "provisioning-jobs", "ProvisioningJobs", "ProvisioningJob", "Jobs", "")
      .column("Name", "name").column("Type", "jobType").column("Status", "status")
      .column("Every (min)", "intervalMinutes").column("Runs", "runCount").column("Last Run", "completedAt")
      .column("Next Run", "nextRunAt").column("Result", "statusMessage").column("ID", "id")
      .action("run", "Run Now", (who, id, _) => p.jobs.run(who.tenantId, id, who.userId))
      .action("cancel", "Cancel", (who, id, _) => p.jobs.cancel(who.tenantId, id, who.userId))
      .action("resume", "Resume", (who, id, _) => p.jobs.resume(who.tenantId, id, who.userId))
      .action("reset", "Reset Delta", (who, id, _) => p.jobs.reset(who.tenantId, id, who.userId));

    _adapters ~= new QueryAdapter!(ProvisioningLog, ProvisioningLogId)(p.logs, "provisioning-logs",
      "ProvisioningLogs", "ProvisioningLog", "Logs")
      .column("Time", "createdAt").column("Job", "jobName").column("Run", "runNumber").column("Operation", "operation")
      .column("Type", "entityType").column("Entity", "entityName").column("Status", "status")
      .column("Message", "message").column("ID", "id");

    _adapters ~= new QueryAdapter!(ProvisionedEntity, ProvisionedEntityId)(p.entities, "provisioned-entities",
      "ProvisionedEntities", "ProvisionedEntity", "Provisioned Entities")
      .column("Name", "name").column("Type", "entityType").column("Target", "targetSystemName")
      .column("Target ID", "targetId").column("Status", "status").column("Last Operation", "lastOperation")
      .column("Last Sync", "lastSyncAt").column("ID", "id");

    _adapters ~= new CatalogAdapter!SystemTypeInfo(() => p.catalog.systemTypes, "system-types", "SystemTypes",
      "SystemType", "System Types")
      .column("ID", "id").column("Name", "name").column("Source", "sourceSupported").column("Target", "targetSupported")
      .column("Proxy", "proxySupported").column("Authentication", "defaultAuthentication").column("URL", "urlPattern");
  }

  /// Adapter of a source / target / proxy system kind.
  protected IResourceAdapter systemAdapter(TEntity, TId)(IManageSystemsUseCase!(TEntity, TId) port, string path,
      string setName, string typeName, string title) {
    return new ResourceAdapter!(TEntity, TId, CreateSystemRequest, UpdateRequest!(TId, SystemSpec))(port, path,
      setName, typeName, title, "")
      .column("Name", "name").column("Type", "systemType").column("URL", "url").column("Status", "status")
      .column("Authentication", "authenticationType").column("Entities", "entityCount")
      .column("Last Sync", "lastSyncAt").column("Message", "statusMessage").column("ID", "id")
      .secret("password")
      .action("activate", "Activate", (who, id, _) => port.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => port.deactivate(who.tenantId, id, who.userId))
      .action("test-connection", "Test Connection", (who, id, _) => port.testConnection(who.tenantId, id, who.userId));
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

  /// The system adapter of a transformation's systemId: by systemRole if given,
  /// otherwise the first kind (target, source, proxy) that knows the id or name.
  protected string resolveSystem(TenantId tenantId, string role, string idOrName) {
    if (role.length > 0) {
      auto adapter = byPath(parseEnum!SystemRole(role, SystemRole.target).enumText ~ "-systems");
      return resolve(adapter, tenantId, idOrName);
    }
    foreach (path; ["target-systems", "source-systems", "proxy-systems"]) {
      try
        return resolve(byPath(path), tenantId, idOrName);
      catch (ResourceError e)
        if (e.status != 404)
          throw e;
    }
    return idOrName; // the use case reports "not found"
  }

  /// A copy of `body` with every reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string])) {
      auto text = jsonText(v);
      auto path = referencePath(k);
      if (path.length > 0 && text.length > 0)
        result[k] = resolve(byPath(path), tenantId, text);
      else if (k == "systemId" && text.length > 0)
        result[k] = resolveSystem(tenantId, fieldString(body, "systemRole"), text);
      else
        result[k] = v;
    }
    return result;
  }

  /// Statistics payload.
  Json statistics(TenantId tenantId) {
    return encode(ports.statistics.statistics(tenantId), true);
  }

  /// Run the due scheduled jobs now.
  Json runDueJobs(TenantId tenantId, int limit = 0) {
    return encode(ports.jobs.runDue(tenantId, 0, limit), true);
  }

  /// Preview a transformation. Body: id (or name), entityType, attributes
  /// ([{key, value}], {"k": "v"} or "k=v,k2=v2").
  Json previewTransformation(RequestIdentity who, Json body) {
    auto id = resolve(byPath("transformations"), who.tenantId, fieldString(body, "id"));
    auto type = parseEnum!EntityType(fieldString(body, "entityType"), EntityType.user);
    auto attributes = decodeKeyValues!Attribute(member(body, "attributes"));
    return provisioning(() => encode(ports.transformations.preview(who.tenantId, TransformationId(id), type, attributes), true));
  }

  /// Delete log entries older than `olderThanDays` (0 = all).
  Json purgeLogs(TenantId tenantId, int olderThanDays) {
    return Json.emptyObject.set("purged", ports.logs.purge(tenantId, olderThanDays));
  }

  /// Create the demo landscape in an empty tenant.
  Json seedDemo(TenantId tenantId, UserId actor) {
    return Json.emptyObject.set("seeded", provisioning(() => new DemoDataSeeder(ports).seed(tenantId, actor)));
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  ProvisioningConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");

  auto sources = registry.byPath("source-systems");
  auto hr = sources.create(who, parseJsonString(`{"name": "HR", "systemType": "sap_hr", "url": "https://hr.acme.com",
    "user": "admin", "password": "secret", "properties": "sim.users=3,sim.groups=1"}`));
  assert(hr["systemType"].get!string == "sapHr" && hr["status"].get!string == "configuring");
  assert(hr["password"].get!string == secretMask && hr["properties"].length == 2);
  auto activated = sources.invoke(who, hr["id"].get!string, "activate", Json.emptyObject);
  assert(activated["status"].get!string == "active", activated.toString);

  // PATCH keeps the stored secret when the mask is sent back
  auto patched = sources.update(who, hr["id"].get!string, parseJsonString(
      `{"description": "SAP HCM", "password": "********"}`));
  assert(patched["description"].get!string == "SAP HCM" && patched["status"].get!string == "active");

  auto targets = registry.byPath("target-systems");
  auto ias = targets.create(who, parseJsonString(`{"name": "IAS", "systemType": "ias", "url": "https://x.accounts.ondemand.com",
    "authenticationType": "oauth2ClientCredentials", "user": "client", "password": "s"}`));
  targets.invoke(who, ias["id"].get!string, "activate", Json.emptyObject);

  // references by name
  auto transformation = registry.byPath("transformations").create(who, registry.withReferences(who.tenantId,
      parseJsonString(`{"name": "IAS users", "systemRole": "target", "systemId": "IAS", "scope": "user",
      "mappings": [{"sourcePath": "email", "targetPath": "emails[0].value", "mandatory": true}]}`)));
  assert(transformation["systemId"].get!string == ias["id"].get!string && transformation["systemName"].get!string == "IAS");
  assert(transformation["mappings"][0]["function"].get!string == "none");

  auto jobs = registry.byPath("provisioning-jobs");
  auto job = jobs.create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"sourceSystemId": "HR", "targetSystemId": "IAS", "jobType": "full"}`)));
  assert(job["name"].get!string == "HR → IAS (full)");
  auto ran = jobs.invoke(who, job["id"].get!string, "run", Json.emptyObject);
  assert(ran["status"].get!string == "completed" && ran["createdCount"].get!long == 4, ran.toString);

  // read-only run results
  auto logs = registry.byPath("provisioning-logs");
  assert(logs.list(who.tenantId, ["jobId": job["id"].get!string]).length == 4);
  int status;
  try logs.create(who, Json.emptyObject);
  catch (ResourceError e) status = e.status;
  assert(status == 405);
  assert(registry.bySet("ProvisionedEntities").list(who.tenantId, ["entityType": "group"]).length == 1);

  // business errors become ResourceErrors with HTTP status
  status = 0;
  try sources.create(who, parseJsonString(`{"name": "HR", "systemType": "csv", "url": "file:///x.csv", "authenticationType": "none"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 409);
  status = 0;
  try registry.withReferences(who.tenantId, parseJsonString(`{"sourceSystemId": "nope"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 404);

  auto preview = registry.previewTransformation(who, parseJsonString(`{"id": "IAS users", "attributes": {"email": "a@b.c"}}`));
  assert(preview["accepted"].get!bool && preview["attributes"][0]["value"].get!string == "a@b.c");

  ResourceAction action;
  assert(registry.byODataAction("RunProvisioningJob", action) is jobs && action.name == "run");
  assert(registry.byODataAction("TestConnectionTargetSystem", action) is targets);
  assert(registry.statistics(who.tenantId)["provisionedUsers"].get!long == 3);
  assert(registry.runDueJobs(who.tenantId)["processed"].get!long == 0);
  assert(registry.purgeLogs(who.tenantId, 0)["purged"].get!long == 4);
  assert(registry.byPath("system-types").list(who.tenantId).length == 8);
  assert(registry.seedDemo(TenantId("demo"), who.userId)["seeded"].get!bool);
}
