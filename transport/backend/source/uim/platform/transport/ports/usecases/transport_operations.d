/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.usecases.transport_operations;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: the transport workflow (export → import → forward).
interface ITransportOperationsUseCase {
  /// Add a request to the import queues of the follow-on nodes of its source node.
  UsecaseResult exportRequest(ExportInput input);
  /// Import (deploy) the selected / given entries of a node's queue.
  /// UsecaseResult.data holds an ImportRunSummary.
  UsecaseResult importNode(ImportInput input);
  /// Forward a request from a node to the follow-on nodes.
  UsecaseResult forwardRequest(ForwardInput input);
  /// Check the deployment endpoint of a node and store the connection status.
  UsecaseResult checkConnection(TenantId tenantId, TransportNodeId nodeId);
}
