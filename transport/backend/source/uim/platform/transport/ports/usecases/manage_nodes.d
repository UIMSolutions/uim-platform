/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.usecases.manage_nodes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: maintain the transport nodes of the landscape.
interface IManageTransportNodesUseCase {
  UsecaseResult createNode(CreateNodeInput input);
  UsecaseResult updateNode(UpdateNodeInput input);
  UsecaseResult enableNode(TenantId tenantId, TransportNodeId id);
  UsecaseResult disableNode(TenantId tenantId, TransportNodeId id);
  /// Fails (422) while routes reference the node.
  UsecaseResult deleteNode(TenantId tenantId, TransportNodeId id);

  bool hasNode(TenantId tenantId, TransportNodeId id);
  TransportNode getNode(TenantId tenantId, TransportNodeId id);
  /// Resolve a node by ID or by name.
  TransportNode findNode(TenantId tenantId, string idOrName);
  TransportNode[] listNodes(TenantId tenantId);
  TransportNode[] listNodesByStatus(TenantId tenantId, NodeStatus status);
  TransportNode[] listNodesByType(TenantId tenantId, NodeType nodeType);
}
