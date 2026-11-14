/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_nodes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportNodesUseCase : IManageTransportNodesUseCase {
  protected ITransportNodeRepository nodes;
  protected ITransportRouteRepository routes;
  protected IImportQueueEntryRepository queue;

  this(ITransportNodeRepository nodes, ITransportRouteRepository routes, IImportQueueEntryRepository queue) {
    this.nodes = nodes;
    this.routes = routes;
    this.queue = queue;
  }

  UsecaseResult createNode(CreateNodeInput input) {
    auto node = TransportNode(input.tenantId);
    if (input.id.length > 0)
      node.id = TransportNodeId(input.id);
    if (nodes.existsById(input.tenantId, node.id))
      return errorResult(409, "Transport node '" ~ node.id.value ~ "' already exists");

    NodeType type = NodeType.cloudFoundry;
    if (input.nodeType.length > 0 && !tryParseEnum!NodeType(input.nodeType, type))
      return errorResult(400, "Invalid nodeType '" ~ input.nodeType ~ "' (" ~ enumNames!NodeType.join(", ") ~ ")");

    node.name = input.name.strip;
    node.description = input.description;
    node.nodeType = type;
    node.environment = input.environment;
    node.region = input.region;
    node.globalAccount = input.globalAccount;
    node.subaccountId = SubaccountId(input.subaccountId);
    node.spaceId = SpaceId(input.spaceId);
    node.serviceKey = input.serviceKey;
    node.isForwardEnabled = input.isForwardEnabled;
    node.autoImport = input.autoImport;
    node.autoImportSchedule = input.autoImportSchedule;
    node.createdBy = input.createdBy;
    node.updatedBy = input.createdBy;

    auto invalid = TransportValidator.validateNode(node);
    if (invalid.length > 0)
      return errorResult(400, "Invalid node: " ~ invalid);
    if (!nodes.findByName(input.tenantId, node.name).isNull)
      return errorResult(409, "A transport node named '" ~ node.name ~ "' already exists");

    nodes.save(node);
    return okResult(node.id.value, "Transport node '" ~ node.name ~ "' created");
  }

  UsecaseResult updateNode(UpdateNodeInput input) {
    auto node = nodes.findById(input.tenantId, input.nodeId);
    if (node.isNull)
      return notFoundResult("Transport node", input.nodeId.value);

    NodeType type = node.nodeType;
    if (input.nodeType.length > 0 && !tryParseEnum!NodeType(input.nodeType, type))
      return errorResult(400, "Invalid nodeType '" ~ input.nodeType ~ "'");

    auto name = input.name.strip;
    if (name.length > 0 && name != node.name) {
      auto other = nodes.findByName(input.tenantId, name);
      if (!other.isNull && other.id != node.id)
        return errorResult(409, "A transport node named '" ~ name ~ "' already exists");
      node.name = name;
    }
    node.description = input.description;
    node.nodeType = type;
    node.environment = input.environment;
    node.region = input.region;
    node.globalAccount = input.globalAccount;
    node.subaccountId = SubaccountId(input.subaccountId);
    node.spaceId = SpaceId(input.spaceId);
    if (input.serviceKey.length > 0)
      node.serviceKey = input.serviceKey;
    node.isForwardEnabled = input.isForwardEnabled;
    node.autoImport = input.autoImport;
    node.autoImportSchedule = input.autoImportSchedule;
    node.touch(input.updatedBy);

    auto invalid = TransportValidator.validateNode(node);
    if (invalid.length > 0)
      return errorResult(400, "Invalid node: " ~ invalid);
    nodes.update(node);
    return okResult(node.id.value, "Transport node '" ~ node.name ~ "' updated");
  }

  UsecaseResult enableNode(TenantId tenantId, TransportNodeId id) {
    return setStatus(tenantId, id, true);
  }

  UsecaseResult disableNode(TenantId tenantId, TransportNodeId id) {
    return setStatus(tenantId, id, false);
  }

  protected UsecaseResult setStatus(TenantId tenantId, TransportNodeId id, bool enabled) {
    auto node = nodes.findById(tenantId, id);
    if (node.isNull)
      return notFoundResult("Transport node", id.value);
    if (enabled)
      node.enable();
    else
      node.disable();
    nodes.update(node);
    return okResult(id.value, "Transport node '" ~ node.name ~ "' " ~ (enabled ? "enabled" : "disabled"));
  }

  UsecaseResult deleteNode(TenantId tenantId, TransportNodeId id) {
    auto node = nodes.findById(tenantId, id);
    if (node.isNull)
      return notFoundResult("Transport node", id.value);

    auto used = routes.findByNode(tenantId, id);
    if (used.length > 0)
      return errorResult(422, "Transport node '" ~ node.name ~ "' is used by %d route(s): %s"
          .format(used.length, used.map!(r => r.name).join(", ")));

    auto entries = queue.findByNode(tenantId, id);
    if (entries.any!(e => e.status == ImportStatus.running))
      return errorResult(422, "An import is running on node '" ~ node.name ~ "'");
    queue.remove(entries);
    nodes.remove(node);
    return okResult(id.value, "Transport node '" ~ node.name ~ "' deleted");
  }

  bool hasNode(TenantId tenantId, TransportNodeId id) {
    return nodes.existsById(tenantId, id);
  }

  TransportNode getNode(TenantId tenantId, TransportNodeId id) {
    return nodes.findById(tenantId, id);
  }

  TransportNode findNode(TenantId tenantId, string idOrName) {
    auto byId = nodes.findById(tenantId, TransportNodeId(idOrName));
    return byId.isNull ? nodes.findByName(tenantId, idOrName) : byId;
  }

  TransportNode[] listNodes(TenantId tenantId) {
    return nodes.findByTenant(tenantId).sort!((a, b) => a.name < b.name).array;
  }

  TransportNode[] listNodesByStatus(TenantId tenantId, NodeStatus status) {
    return nodes.findByStatus(tenantId, status);
  }

  TransportNode[] listNodesByType(TenantId tenantId, NodeType nodeType) {
    return nodes.findByType(tenantId, nodeType);
  }
}
