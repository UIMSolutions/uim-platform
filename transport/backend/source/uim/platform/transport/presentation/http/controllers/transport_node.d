/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// REST: /api/v1/transport/nodes
///   PUT body {"action": "enable" | "disable" | "check"} triggers the state change,
///   any other PUT body updates the given fields.
class TransportNodeController : ManageHttpController {
  protected IManageTransportNodesUseCase nodes;
  protected ITransportOperationsUseCase operations;

  this(IManageTransportNodesUseCase nodes, ITransportOperationsUseCase operations) {
    this.nodes = nodes;
    this.operations = operations;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get(restBase ~ "/nodes", &handleList);
    router.get(restBase ~ "/nodes/*", &handleGet);
    router.post(restBase ~ "/nodes", &handleCreate);
    router.put(restBase ~ "/nodes/*", &handleUpdate);
    router.delete_(restBase ~ "/nodes/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;
    return successResponse("Transport nodes retrieved", "Retrieved", 200, listPayload(nodes.listNodes(precheck.tenantId)));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto node = nodes.findNode(precheck.tenantId, precheck.id);
    if (node.isNull)
      return errorResponse("Transport node not found", 404);
    return successResponse("Transport node retrieved", "Retrieved", 200, node.toJson);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;
    auto data = precheck.data;
    CreateNodeInput input;
    input.tenantId = precheck.tenantId;
    input.id = data.getString("id");
    input.name = data.getString("name");
    input.description = data.getString("description");
    input.nodeType = data.getString("nodeType");
    input.environment = data.getString("environment");
    input.region = data.getString("region");
    input.globalAccount = data.getString("globalAccount");
    input.subaccountId = data.getString("subaccountId");
    input.spaceId = data.getString("spaceId");
    input.serviceKey = data.getString("serviceKey");
    input.isForwardEnabled = pickBool(data, "isForwardEnabled", true);
    input.autoImport = pickBool(data, "autoImport", false);
    input.autoImportSchedule = data.getString("autoImportSchedule");
    input.createdBy = UserId(data.getString("createdBy"));
    return usecaseResponse(nodes.createNode(input), "Created", 201);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenant = precheck.tenantId;
    auto current = nodes.findNode(tenant, precheck.id);
    if (current.isNull)
      return errorResponse("Transport node not found", 404);

    auto data = precheck.data;
    switch (data.getString("action")) {
    case "enable":
      return usecaseResponse(nodes.enableNode(tenant, current.id), "Enabled");
    case "disable":
      return usecaseResponse(nodes.disableNode(tenant, current.id), "Disabled");
    case "check":
      return usecaseResponse(operations.checkConnection(tenant, current.id), "Checked");
    default:
      break;
    }

    auto input = UpdateNodeInput.from(current);
    input.name = pick(data, "name", input.name);
    input.description = pick(data, "description", input.description);
    input.nodeType = pick(data, "nodeType", input.nodeType);
    input.environment = pick(data, "environment", input.environment);
    input.region = pick(data, "region", input.region);
    input.globalAccount = pick(data, "globalAccount", input.globalAccount);
    input.subaccountId = pick(data, "subaccountId", input.subaccountId);
    input.spaceId = pick(data, "spaceId", input.spaceId);
    input.serviceKey = pick(data, "serviceKey", "");
    input.isForwardEnabled = pickBool(data, "isForwardEnabled", input.isForwardEnabled);
    input.autoImport = pickBool(data, "autoImport", input.autoImport);
    input.autoImportSchedule = pick(data, "autoImportSchedule", input.autoImportSchedule);
    input.updatedBy = UserId(data.getString("updatedBy"));
    return usecaseResponse(nodes.updateNode(input), "Updated");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;
    auto node = nodes.findNode(precheck.tenantId, precheck.id);
    if (node.isNull)
      return errorResponse("Transport node not found", 404);
    return usecaseResponse(nodes.deleteNode(precheck.tenantId, node.id), "Deleted");
  }
}
