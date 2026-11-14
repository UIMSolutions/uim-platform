/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the Application Studio service: which kinds exist,
/// how they are named per protocol, their table columns, actions, secrets and references.
module uim.platform.application_studio.presentation.resources.registry;

import uim.platform.application_studio;
import uim.platform.application_studio.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference another resource (accept an id or a unique name),
/// mapped to the REST path of the referenced resource.
enum string[string] referenceFields = [
  "devSpaceId": "dev-spaces",
  "devSpaceTypeId": "dev-space-types",
  "projectId": "projects",
  "templateId": "project-templates",
];

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  StudioPorts ports;

  this(StudioPorts ports) {
    this.ports = ports;
    auto p = ports;

    // ── catalogue ──────────────────────────────────────────────────────────
    _adapters ~= new ResourceAdapter!(DevSpaceType, DevSpaceTypeId, CreateDevSpaceTypeRequest, UpdateDevSpaceTypeRequest)(
      p.devSpaceTypes, "dev-space-types", "DevSpaceTypes", "DevSpaceType", "Dev Space Types", "")
      .column("Name", "name").column("Category", "category").column("Runtime", "runtimeStack")
      .column("Extensions", "predefinedExtensions").column("Project Types", "supportedProjectTypes").column("ID", "id");

    _adapters ~= new ResourceAdapter!(Extension, ExtensionId, CreateExtensionRequest, UpdateExtensionRequest)(
      p.extensions, "extensions", "Extensions", "Extension", "Extensions", "")
      .column("Name", "name").column("Display Name", "displayName").column("Scope", "scope")
      .column("Version", "version").column("Category", "category").column("Depends On", "dependencies")
      .column("Status", "status").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.extensions.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.extensions.deactivate(who.tenantId, id, who.userId))
      .action("deprecate", "Deprecate", (who, id, _) => p.extensions.deprecate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ProjectTemplate, ProjectTemplateId, CreateProjectTemplateRequest,
        UpdateProjectTemplateRequest)(p.projectTemplates, "project-templates", "ProjectTemplates", "ProjectTemplate",
        "Project Templates", "")
      .column("Name", "name").column("Title", "title").column("Category", "category")
      .column("Project Type", "targetProjectType").column("Requires", "requiredExtensions").column("Version", "version")
      .column("ID", "id");

    // ── dev spaces and their content ──────────────────────────────────────
    _adapters ~= new ResourceAdapter!(DevSpace, DevSpaceId, CreateDevSpaceRequest, UpdateDevSpaceRequest)(
      p.devSpaces, "dev-spaces", "DevSpaces", "DevSpace", "Dev Spaces", "")
      .column("Name", "name").column("Type", "devSpaceTypeName").column("Plan", "plan").column("Owner", "owner")
      .column("Region", "region").column("Extensions", "extensions").column("Status", "status").column("URL", "url")
      .column("ID", "id")
      .action("start", "Start", (who, id, _) => p.devSpaces.start(who.tenantId, id, who.userId))
      .action("stop", "Stop", (who, id, _) => p.devSpaces.stop(who.tenantId, id, who.userId))
      .action("touch", "Open", (who, id, _) => p.devSpaces.touch(who.tenantId, id, who.userId))
      .action("add-extension", "Add Extension", (who, id, params) => p.devSpaces.addExtension(who.tenantId, id,
          fieldString(params, "extension"), who.userId), ["extension"])
      .action("remove-extension", "Remove Extension", (who, id, params) => p.devSpaces.removeExtension(who.tenantId, id,
          fieldString(params, "extension"), who.userId), ["extension"]);

    _adapters ~= new ResourceAdapter!(Project, ProjectId, CreateProjectRequest, UpdateProjectRequest)(
      p.projects, "projects", "Projects", "Project", "Projects", "devSpaceId")
      .column("Name", "name").column("Dev Space", "devSpaceName").column("Type", "projectType")
      .column("Template", "templateName").column("Git", "gitRepositoryUrl").column("Status", "status").column("ID", "id")
      .action("archive", "Archive", (who, id, _) => p.projects.archive(who.tenantId, id, who.userId))
      .action("restore", "Restore", (who, id, _) => p.projects.restore(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest,
        UpdateServiceBindingRequest)(p.serviceBindings, "service-bindings", "ServiceBindings", "ServiceBinding",
        "Service Bindings", "devSpaceId")
      .column("Name", "name").column("Dev Space", "devSpaceName").column("Provider", "providerType")
      .column("Destination", "systemAlias").column("URL", "serviceUrl").column("Auth", "authType")
      .column("Status", "status").column("ID", "id")
      .secret("credentials")
      .action("connect", "Connect", (who, id, _) => p.serviceBindings.connect(who.tenantId, id, who.userId))
      .action("disconnect", "Disconnect", (who, id, _) => p.serviceBindings.disconnect(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(RunConfiguration, RunConfigurationId, CreateRunConfigurationRequest,
        UpdateRunConfigurationRequest)(p.runConfigurations, "run-configurations", "RunConfigurations",
        "RunConfiguration", "Run Configurations", "projectId")
      .column("Name", "name").column("Project", "projectName").column("Mode", "mode").column("Entry Point", "entryPoint")
      .column("Port", "port").column("Bindings", "serviceBindings").column("Status", "status").column("URL", "url")
      .column("ID", "id")
      .action("start", "Start", (who, id, _) => p.runConfigurations.start(who.tenantId, id, who.userId))
      .action("stop", "Stop", (who, id, _) => p.runConfigurations.stop(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(BuildConfiguration, BuildConfigurationId, CreateBuildConfigurationRequest,
        UpdateBuildConfigurationRequest)(p.buildConfigurations, "build-configurations", "BuildConfigurations",
        "BuildConfiguration", "Build Configurations", "projectId")
      .column("Name", "name").column("Project", "projectName").column("Target", "deployTarget")
      .column("Build", "buildCommand").column("Artifact", "artifactPath").column("Last Build", "lastBuildAt")
      .column("Status", "status").column("ID", "id")
      .action("build", "Build", (who, id, _) => p.buildConfigurations.build(who.tenantId, id, who.userId))
      .action("deploy", "Deploy", (who, id, _) => p.buildConfigurations.deploy(who.tenantId, id, who.userId))
      .action("cancel", "Cancel", (who, id, _) => p.buildConfigurations.cancel(who.tenantId, id, who.userId));
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

  /// Resolve a reference field (devSpaceId, devSpaceTypeId, projectId, templateId).
  string resolveReference(string field, TenantId tenantId, string idOrName) {
    if (auto target = field in referenceFields)
      if (idOrName.length > 0)
        return resolve(byPath(*target), tenantId, idOrName);
    return idOrName;
  }

  /// A copy of `body` with every reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      result[k] = (k in referenceFields) !is null && jsonText(v).length > 0
        ? Json(resolveReference(k, tenantId, jsonText(v))) : v;
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

  /// Install the predefined catalogue and return the report payload.
  Json seedCatalog(RequestIdentity who) {
    return encode(ports.catalog.seed(who.tenantId, who.userId), true);
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  StudioConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");
  assert(registry.seedCatalog(who)["created"].get!long == 29);

  // references by name, lenient input
  auto spaces = registry.byPath("dev-spaces");
  auto ds = spaces.create(who, registry.withReferences(who.tenantId, parseJsonString(`{"name": "FullStack",
    "devSpaceTypeId": "Full-Stack Cloud Application", "owner": "jane@example.com", "plan": "professional",
    "memoryLimitMb": "8192", "extensions": "sap.kyma-tools"}`)));
  assert(ds["status"].get!string == "starting" && ds["devSpaceTypeName"].get!string == "Full-Stack Cloud Application");
  assert(ds["memoryLimitMb"].get!long == 8192 && ds["extensions"][0].get!string == "sap.kyma-tools");
  registry.reconcile(who.tenantId);

  auto project = registry.byPath("projects").create(who, registry.withReferences(who.tenantId,
      parseJsonString(`{"devSpaceId": "FullStack", "name": "bookshop", "templateId": "cap-project"}`)));
  assert(project["projectType"].get!string == "capNodeJs" && project["templateName"].get!string == "cap-project");

  // secrets are masked; a masked value in a PATCH keeps the stored secret
  auto bindings = registry.byPath("service-bindings");
  auto b = bindings.create(who, registry.withReferences(who.tenantId, parseJsonString(`{"devSpaceId": "FullStack",
    "name": "Northwind", "providerType": "externalOData", "serviceUrl": "https://services.odata.org",
    "servicePath": "/V4/Northwind/Northwind.svc/", "authType": "basicAuthentication", "user": "demo", "credentials": "s3cret"}`)));
  assert(b["credentials"].get!string == secretMask);
  auto patched = bindings.update(who, b["id"].get!string, parseJsonString(`{"description": "x", "credentials": "********"}`));
  assert(patched["description"].get!string == "x" && patched["credentials"].get!string == secretMask);
  assert(registry.ports.serviceBindings.get(who.tenantId, ServiceBindingId(b["id"].get!string)).credentials == "s3cret");

  // business errors become ResourceErrors with HTTP status
  int status;
  try spaces.create(who, registry.withReferences(who.tenantId, parseJsonString(`{"name": "FullStack",
    "devSpaceTypeId": "Basic", "owner": "jane@example.com"}`)));
  catch (ResourceError e) status = e.status;
  assert(status == 409);
  status = 0;
  try registry.withReferences(who.tenantId, parseJsonString(`{"devSpaceTypeId": "Nope"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 404);

  ResourceAction stop;
  assert(registry.byODataAction("StopDevSpace", stop) is spaces);
  assert(registry.byODataAction("AddExtensionDevSpace", stop) is spaces && stop.parameters == ["extension"]);
  assert(spaces.invoke(who, ds["id"].get!string, "stop", Json.emptyObject)["status"].get!string == "stopping");
  assert(spaces.list(who.tenantId, ["plan": "professional"]).length == 1);
  assert(spaces.list(who.tenantId, ["plan": "free"]).length == 0);
  assert(registry.statistics(who.tenantId)["devSpaces"].get!long == 1);
  assert(registry.bySet("RunConfigurations").parentField == "projectId");
  assert(registry.bySet("Projects").inputFields[0].name == "devSpaceId");
}
