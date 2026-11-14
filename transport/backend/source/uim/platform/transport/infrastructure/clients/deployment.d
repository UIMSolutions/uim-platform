/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Technical clients for the deployment endpoints of transport nodes.
module uim.platform.transport.infrastructure.clients.deployment;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Deployment gateway that simulates the deployment of content.
///
/// Rules (deterministic, useful for demos and tests):
///   * disabled node                      → failed
///   * storageUrl starting with "fail:"   → failed (archive cannot be retrieved)
///   * no storageUrl (metadata only)      → warning (nothing deployed)
///   * otherwise                          → success
///
/// Replace it with a real client (CF Deploy Service / MTA deployer, ABAP CTS,
/// Kyma Helm) by implementing IDeploymentGateway and wiring it in the Container.
class SimulatedDeploymentGateway : IDeploymentGateway {
  DeploymentResult deploy(const TransportNode node, const TransportRequest request) {
    string[] log;
    log ~= "Target node '%s' (%s%s)".format(node.name, enumName(node.nodeType),
      node.region.length ? ", " ~ node.region : "");
    log ~= "Content: %s '%s'%s".format(enumName(request.contentType), request.name,
      request.version_.length ? " version " ~ request.version_ : "");

    if (!node.isEnabled)
      return DeploymentResult.fail(log.join("\n"), "Target node '" ~ node.name ~ "' is disabled");
    if (request.storageUrl.startsWith("fail:"))
      return DeploymentResult.fail((log ~ "Retrieving archive " ~ request.storageUrl ~ " … failed").join("\n"),
        "Content archive could not be retrieved from " ~ request.storageUrl);
    if (!request.hasContent)
      return DeploymentResult.warn((log ~ "No content archive attached — nothing deployed").join("\n"),
        "Metadata-only transport request; nothing was deployed");

    log ~= "Retrieving archive " ~ request.storageUrl ~ (request.checksum.length ? " (checksum " ~ request.checksum ~ ")" : "");
    log ~= deployStep(node);
    log ~= "Deployment finished successfully";
    return DeploymentResult.ok(log.join("\n"));
  }

  bool ping(const TransportNode node) {
    return node.isEnabled;
  }

  protected static string deployStep(const TransportNode node) {
    final switch (node.nodeType) {
    case NodeType.cloudFoundry:
      return "Deploying MTA to Cloud Foundry space " ~ (node.spaceId.value.length ? node.spaceId.value : node.name);
    case NodeType.abap:
      return "Importing into ABAP system " ~ node.name ~ " via CTS";
    case NodeType.neo:
      return "Deploying to Neo subaccount " ~ (node.subaccountId.value.length ? node.subaccountId.value : node.name);
    case NodeType.kyma:
      return "Applying release to Kyma cluster " ~ node.name;
    case NodeType.other:
      return "Handing content over to the external deployment endpoint of " ~ node.name;
    }
  }
}

///
unittest {
  mixin(ShowTest!("SimulatedDeploymentGateway"));

  auto g = new SimulatedDeploymentGateway();
  TransportNode node;
  node.name = "QA";
  TransportRequest req;
  req.name = "app";
  assert(g.deploy(node, req).status == ImportStatus.warning);
  req.storageUrl = "https://store/app.mtar";
  assert(g.deploy(node, req).status == ImportStatus.success);
  req.storageUrl = "fail://missing";
  assert(g.deploy(node, req).status == ImportStatus.failed);
  node.disable();
  assert(!g.ping(node));
}
