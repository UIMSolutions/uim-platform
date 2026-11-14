/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.repositories.transport_nodes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of transport nodes.
interface ITransportNodeRepository : ITenantRepository!(TransportNode, TransportNodeId) {
  size_t countByStatus(TenantId tenantId, NodeStatus status);
  TransportNode[] findByStatus(TenantId tenantId, NodeStatus status);
  TransportNode[] findByType(TenantId tenantId, NodeType nodeType);
  TransportNode findByName(TenantId tenantId, string name);
}
