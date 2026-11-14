/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the ABAP environment service: which kinds exist,
/// how they are named per protocol, their table columns, actions and secrets.
module uim.platform.abap_environment.presentation.resources.registry;

import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference a system (accept an id or a unique system name).
enum string[] systemReferenceFields = ["systemInstanceId", "sourceSystemId", "targetSystemId"];

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  AbapPorts ports;

  this(AbapPorts ports) {
    this.ports = ports;
    auto p = ports;

    _adapters ~= new ResourceAdapter!(SystemInstance, SystemInstanceId, CreateSystemRequest, UpdateSystemRequest)(
      p.systems, "systems", "Systems", "System", "Systems", "")
      .column("Name", "name").column("SID", "sapSystemId").column("Plan", "plan").column("Region", "region")
      .column("Status", "status").column("Version", "softwareVersion").column("Service URL", "serviceUrl")
      .column("ID", "id")
      .action("suspend", "Suspend", (who, id, _) => p.systems.suspend(who.tenantId, id, who.userId))
      .action("resume", "Resume", (who, id, _) => p.systems.resume(who.tenantId, id, who.userId))
      .action("upgrade", "Upgrade", (who, id, params) => p.systems.upgrade(who.tenantId, id,
          fieldString(params, "softwareVersion"), who.userId), ["softwareVersion"]);

    _adapters ~= new ResourceAdapter!(SoftwareComponent, SoftwareComponentId, CreateSoftwareComponentRequest,
        UpdateSoftwareComponentRequest)(p.softwareComponents, "software-components", "SoftwareComponents",
        "SoftwareComponent", "Software Components", "systemInstanceId")
      .column("Name", "name").column("System", "systemName").column("Type", "componentType")
      .column("Branch", "branch").column("Commit", "currentCommitId").column("Status", "status").column("ID", "id")
      .action("clone", "Clone", (who, id, _) => p.softwareComponents.clone(who.tenantId, id, who.userId))
      .action("pull", "Pull", (who, id, _) => p.softwareComponents.pull(who.tenantId, id, who.userId))
      .action("checkout", "Checkout Branch", (who, id, params) => p.softwareComponents.checkout(who.tenantId, id,
          fieldString(params, "branch"), who.userId), ["branch"]);

    _adapters ~= new ResourceAdapter!(CommunicationArrangement, CommunicationArrangementId,
        CreateCommunicationArrangementRequest, UpdateCommunicationArrangementRequest)(p.communicationArrangements,
        "communication-arrangements", "CommunicationArrangements", "CommunicationArrangement",
        "Communication Arrangements", "systemInstanceId")
      .column("Name", "name").column("System", "systemName").column("Scenario", "scenarioId")
      .column("Partner", "communicationSystem").column("Direction", "direction").column("Auth", "authMethod")
      .column("Status", "status").column("ID", "id")
      .secret("communicationPassword").secret("clientSecret")
      .action("activate", "Activate", (who, id, _) => p.communicationArrangements.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.communicationArrangements.deactivate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest,
        UpdateServiceBindingRequest)(p.serviceBindings, "service-bindings", "ServiceBindings", "ServiceBinding",
        "Service Bindings", "systemInstanceId")
      .column("Name", "name").column("System", "systemName").column("Definition", "serviceDefinition")
      .column("Type", "bindingType").column("Status", "status").column("Service URL", "serviceUrl").column("ID", "id")
      .action("publish", "Publish", (who, id, _) => p.serviceBindings.publish(who.tenantId, id, who.userId))
      .action("unpublish", "Unpublish", (who, id, _) => p.serviceBindings.unpublish(who.tenantId, id, who.userId))
      .action("deprecate", "Deprecate", (who, id, _) => p.serviceBindings.deprecate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(BusinessRole, BusinessRoleId, CreateBusinessRoleRequest, UpdateBusinessRoleRequest)(
      p.businessRoles, "business-roles", "BusinessRoles", "BusinessRole", "Business Roles", "systemInstanceId")
      .column("Name", "name").column("System", "systemName").column("Type", "roleType")
      .column("Catalogs", "businessCatalogs").column("Restrictions", "restrictionTypes").column("ID", "id")
      .action("add-catalog", "Add Catalog", (who, id, params) => p.businessRoles.addCatalog(who.tenantId, id,
          fieldString(params, "catalog"), who.userId), ["catalog"])
      .action("remove-catalog", "Remove Catalog", (who, id, params) => p.businessRoles.removeCatalog(who.tenantId, id,
          fieldString(params, "catalog"), who.userId), ["catalog"]);

    _adapters ~= new ResourceAdapter!(BusinessUser, BusinessUserId, CreateBusinessUserRequest, UpdateBusinessUserRequest)(
      p.businessUsers, "business-users", "BusinessUsers", "BusinessUser", "Business Users", "systemInstanceId")
      .column("User", "name").column("First Name", "firstName").column("Last Name", "lastName")
      .column("E-Mail", "email").column("System", "systemName").column("Roles", "roles").column("Status", "status")
      .column("ID", "id")
      .action("lock", "Lock", (who, id, _) => p.businessUsers.lock(who.tenantId, id, who.userId))
      .action("unlock", "Unlock", (who, id, _) => p.businessUsers.unlock(who.tenantId, id, who.userId))
      .action("reset-password", "Reset Password", (who, id, _) => p.businessUsers.resetPassword(who.tenantId, id, who.userId))
      .action("assign-role", "Assign Role", (who, id, params) => p.businessUsers.assignRole(who.tenantId, id,
          fieldString(params, "role"), who.userId), ["role"])
      .action("unassign-role", "Unassign Role", (who, id, params) => p.businessUsers.unassignRole(who.tenantId, id,
          fieldString(params, "role"), who.userId), ["role"]);

    _adapters ~= new ResourceAdapter!(TransportRequest, TransportRequestId, CreateTransportRequestRequest,
        UpdateTransportRequestRequest)(p.transportRequests, "transports", "TransportRequests", "TransportRequest",
        "Transport Requests", "sourceSystemId")
      .column("Number", "name").column("Description", "description").column("Owner", "owner")
      .column("Type", "transportType").column("Source", "sourceSystemName").column("Target", "targetSystemName")
      .column("Tasks", "tasks").column("Status", "status").column("ID", "id")
      .action("add-task", "Add Task", (who, id, params) => p.transportRequests.addTask(who.tenantId, id,
          fieldString(params, "owner"), fieldString(params, "description"), fieldStrings(params, "objects"),
          who.userId), ["objects", "owner", "description"])
      .action("release-task", "Release Task", (who, id, params) => p.transportRequests.releaseTask(who.tenantId, id,
          fieldString(params, "task"), who.userId), ["task"])
      .action("release", "Release", (who, id, _) => p.transportRequests.release(who.tenantId, id, who.userId))
      .action("import", "Import", (who, id, _) => p.transportRequests.import_(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ApplicationJob, ApplicationJobId, CreateApplicationJobRequest,
        UpdateApplicationJobRequest)(p.applicationJobs, "application-jobs", "ApplicationJobs", "ApplicationJob",
        "Application Jobs", "systemInstanceId")
      .column("Name", "name").column("System", "systemName").column("Template", "jobTemplateName")
      .column("Frequency", "frequency").column("Next Run", "scheduledAt").column("Runs", "runCount")
      .column("Status", "status").column("ID", "id")
      .action("run", "Run Now", (who, id, _) => p.applicationJobs.run(who.tenantId, id, who.userId))
      .action("cancel", "Cancel", (who, id, _) => p.applicationJobs.cancel(who.tenantId, id, who.userId))
      .action("reactivate", "Reactivate", (who, id, _) => p.applicationJobs.reactivate(who.tenantId, id, who.userId));
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

  /// Resolve a system reference field (systemInstanceId, sourceSystemId, targetSystemId).
  string resolveParent(string field, TenantId tenantId, string idOrName) {
    if (systemReferenceFields.canFind(field) && idOrName.length > 0)
      return resolve(byPath("systems"), tenantId, idOrName);
    return idOrName;
  }

  /// A copy of `body` with every system reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      result[k] = systemReferenceFields.canFind(k) && jsonText(v).length > 0
        ? Json(resolveParent(k, tenantId, jsonText(v))) : v;
    return result;
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

  AbapConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");

  auto systems = registry.byPath("systems");
  auto system = systems.create(who, parseJsonString(`{"name": "dev", "adminEmail": "a@example.com", "plan": "development"}`));
  assert(system["status"].get!string == "provisioning");
  assert(system["sapSystemId"].get!string == "DEV");
  registry.reconcile(who.tenantId);

  // parents by name, lenient input, secrets masked
  auto arrangements = registry.byPath("communication-arrangements");
  auto body = registry.withReferences(who.tenantId, parseJsonString(`{"systemInstanceId": "dev",
    "name": "Travel", "scenarioId": "SAP_COM_0510", "communicationUser": "COMM", "communicationPassword": "s3cret"}`));
  auto a = arrangements.create(who, body);
  assert(a["systemInstanceId"].get!string == system["id"].get!string);
  assert(a["communicationPassword"].get!string == secretMask);
  // PATCH with the mask keeps the secret; the password check still passes on activate
  auto patched = arrangements.update(who, a["id"].get!string, parseJsonString(`{"description": "x", "communicationPassword": "********"}`));
  assert(patched["description"].get!string == "x" && patched["communicationPassword"].get!string == secretMask);
  assert(registry.ports.communicationArrangements.get(who.tenantId,
      CommunicationArrangementId(a["id"].get!string)).communicationPassword == "s3cret");

  // business errors become ResourceErrors with HTTP status
  int status;
  try systems.create(who, parseJsonString(`{"name": "dev", "adminEmail": "a@example.com"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 409);

  ResourceAction release;
  assert(registry.byODataAction("ReleaseTaskTransportRequest", release) is registry.byPath("transports"));
  assert(release.name == "release-task" && release.parameters == ["task"]);
  assert(systems.invoke(who, system["id"].get!string, "suspend", Json.emptyObject)["status"].get!string == "suspended");

  assert(systems.list(who.tenantId, ["plan": "development"]).length == 1);
  assert(systems.list(who.tenantId, ["plan": "production"]).length == 0);
  assert(registry.statistics(who.tenantId)["systems"].get!long == 1);
  assert(registry.bySet("BusinessUsers").inputFields[0].name == "systemInstanceId");
  assert(registry.bySet("TransportRequests").parentField == "sourceSystemId");
}
