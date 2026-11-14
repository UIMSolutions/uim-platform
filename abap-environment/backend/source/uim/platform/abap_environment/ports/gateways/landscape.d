/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.gateways.landscape;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Outcome of provisioning a system.
struct ProvisionedSystem {
  string serviceUrl;
  string webSocketUrl;
  string stackVersion;
}

/// Outcome of an application job run.
struct JobRunOutcome {
  int returnCode; /// 0 = success
  string message;
}

/// Driven port: the ABAP landscape behind the service — the provisioning API of
/// the ABAP environment, gCTS (git) and the transport and job runtimes.
interface IAbapLandscapeGateway {
  ProvisionedSystem provision(const SystemInstance system);
  void deprovision(const SystemInstance system);
  /// Head commit of a branch ("" if the repository / branch cannot be read).
  string headCommit(string repositoryUrl, string branch);
  /// Import into the target system; "" on success, otherwise the error.
  string importTransport(const TransportRequest request, const SystemInstance target);
  JobRunOutcome runJob(const ApplicationJob job);
}
