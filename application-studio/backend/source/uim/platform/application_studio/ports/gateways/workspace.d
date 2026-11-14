/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.gateways.workspace;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Outcome of an operation of the workspace runtime ("" error = success).
struct WorkspaceOutcome {
  string error;
  string url; /// workspace / preview URL
  string artifact; /// build artifact or deployment target
  string message;

  bool ok() const {
    return error.length == 0;
  }
}

/// Driven port: the runtime behind the service — the container cluster that hosts
/// dev spaces, the process runner for run configurations, the build service
/// (mbt, npm, maven) and the deployers (cf, helm, HTML5 repository), plus the
/// connectivity check for service bindings.
interface IWorkspaceGateway {
  WorkspaceOutcome startDevSpace(const DevSpace ds);
  void stopDevSpace(const DevSpace ds);
  void hibernateDevSpace(const DevSpace ds);
  void deleteDevSpace(const DevSpace ds);
  WorkspaceOutcome testConnection(const ServiceBinding binding);
  WorkspaceOutcome startRun(const RunConfiguration run, const DevSpace ds);
  void stopRun(const RunConfiguration run);
  WorkspaceOutcome build(const BuildConfiguration bc, const Project project);
  WorkspaceOutcome deploy(const BuildConfiguration bc, const Project project);
}
