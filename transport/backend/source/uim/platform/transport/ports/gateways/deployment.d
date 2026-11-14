/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.gateways.deployment;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Outcome of deploying a transport request to a node.
struct DeploymentResult {
  ImportStatus status = ImportStatus.success; /// success, warning or failed
  string log;
  string error;

  static DeploymentResult ok(string log) {
    return DeploymentResult(ImportStatus.success, log, "");
  }

  static DeploymentResult warn(string log, string message) {
    return DeploymentResult(ImportStatus.warning, log, message);
  }

  static DeploymentResult fail(string log, string message) {
    return DeploymentResult(ImportStatus.failed, log, message);
  }
}

/// Driven port: the technical deployment of content into the target runtime
/// (Cloud Foundry deploy service, ABAP CTS, Kyma, ...).
interface IDeploymentGateway {
  DeploymentResult deploy(const TransportNode node, const TransportRequest request);

  /// Connectivity check of a node's deployment endpoint.
  bool ping(const TransportNode node);
}
