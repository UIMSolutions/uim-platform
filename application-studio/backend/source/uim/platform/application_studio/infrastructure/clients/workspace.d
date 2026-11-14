/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.clients.workspace;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Simulated workspace runtime: derives workspace and preview URLs, connection,
/// build and deployment results deterministically and records every call.
/// Replace with clients of the container cluster, the build service and the
/// deployers (cf, helm, HTML5 repository) to run real workloads.
///
/// Conventions that let tests and demos exercise failure paths:
///   * a dev space whose description contains "[fail]" cannot start
///   * a service URL or destination containing "invalid" cannot be reached
///   * an entry point containing "[fail]" crashes on start
///   * a build / deploy command containing "[fail]" fails
class SimulatedWorkspaceGateway : IWorkspaceGateway {
  struct Operation {
    string verb;
    string target;
    string detail;
  }

  protected Operation[] _operations;
  protected size_t _capacity;
  protected string _domain;

  this(string domain = "applicationstudio.cloud.sap", size_t capacity = 500) {
    _domain = domain;
    _capacity = capacity;
  }

  protected static string host(string id) {
    return id.length >= 8 ? id[0 .. 8] : id;
  }

  WorkspaceOutcome startDevSpace(const DevSpace ds) {
    WorkspaceOutcome o;
    if (ds.description.canFind("[fail]"))
      o.error = "Workspace " ~ ds.name ~ " could not be scheduled (insufficient capacity in " ~ ds.region ~ ")";
    else
      o.url = "https://" ~ host(ds.id.value) ~ "-" ~ ds.name.toLower ~ "." ~ ds.region ~ "." ~ _domain;
    record("start", ds.name, o.ok ? o.url : o.error);
    return o;
  }

  void stopDevSpace(const DevSpace ds) {
    record("stop", ds.name, ds.url);
  }

  void hibernateDevSpace(const DevSpace ds) {
    record("hibernate", ds.name, ds.url);
  }

  void deleteDevSpace(const DevSpace ds) {
    record("delete", ds.name, ds.region);
  }

  WorkspaceOutcome testConnection(const ServiceBinding b) {
    WorkspaceOutcome o;
    auto target = b.serviceUrl.length ? b.serviceUrl ~ b.servicePath : "destination " ~ b.systemAlias;
    if (target.canFind("invalid"))
      o.error = "Cannot reach " ~ target ~ " (connection refused)";
    else
      o.message = "Connected to " ~ target;
    record("connect", b.name, target);
    return o;
  }

  WorkspaceOutcome startRun(const RunConfiguration r, const DevSpace ds) {
    WorkspaceOutcome o;
    if (r.entryPoint.canFind("[fail]"))
      o.error = "'" ~ r.entryPoint ~ "' exited with code 1";
    else
      o.url = "https://port" ~ r.port.to!string ~ "-workspaces-ws-" ~ host(ds.id.value) ~ "." ~ ds.region ~ "." ~ _domain;
    record("run", r.name, o.ok ? o.url : o.error);
    return o;
  }

  void stopRun(const RunConfiguration r) {
    record("stop-run", r.name, r.url);
  }

  WorkspaceOutcome build(const BuildConfiguration bc, const Project p) {
    WorkspaceOutcome o;
    if (bc.buildCommand.canFind("[fail]"))
      o.error = "'" ~ bc.buildCommand ~ "' failed in " ~ p.rootPath ~ " (exit code 1)";
    else {
      o.artifact = bc.artifactPath;
      o.message = "Built " ~ bc.artifactPath;
    }
    record("build", p.name, bc.buildCommand);
    return o;
  }

  WorkspaceOutcome deploy(const BuildConfiguration bc, const Project p) {
    WorkspaceOutcome o;
    if (bc.deployCommand.canFind("[fail]"))
      o.error = "'" ~ bc.deployCommand ~ "' failed (exit code 1)";
    else {
      o.artifact = enumText(bc.deployTarget) ~ ":" ~ p.name;
      o.message = "Deployed " ~ bc.lastArtifact ~ " to " ~ enumText(bc.deployTarget);
    }
    record("deploy", p.name, bc.deployCommand);
    return o;
  }

  /// The most recent calls (oldest first).
  const(Operation)[] operations() const {
    return _operations;
  }

  protected void record(string verb, string target, string detail) {
    _operations ~= Operation(verb, target, detail);
    if (_operations.length > _capacity)
      _operations = _operations[$ - _capacity .. $];
    logDebug("studio workspace: %s %s %s", verb, target, detail);
  }
}

///
unittest {
  auto gw = new SimulatedWorkspaceGateway();
  auto ds = DevSpace(TenantId("t"));
  ds.name = "FioriDev";
  assert(gw.startDevSpace(ds).url.endsWith("-fioridev.eu10.applicationstudio.cloud.sap"));
  ds.description = "[fail]";
  assert(!gw.startDevSpace(ds).ok);

  ServiceBinding b;
  b.serviceUrl = "https://invalid.example.com";
  assert(!gw.testConnection(b).ok);
  b.serviceUrl = "";
  b.systemAlias = "S4H";
  assert(gw.testConnection(b).ok);

  RunConfiguration r;
  r.entryPoint = "npm start";
  r.port = 4004;
  assert(gw.startRun(r, ds).url.startsWith("https://port4004-workspaces-ws-"));
  assert(gw.operations.length == 5);
}
