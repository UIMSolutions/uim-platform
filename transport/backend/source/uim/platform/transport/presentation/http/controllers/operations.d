/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.operations;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// REST: workflow and read models.
///   POST /api/v1/transport/nodes-import      {"nodeId", "entryIds"?: [...], "performedBy"?}
///   GET  /api/v1/transport/statistics
///   GET  /api/v1/transport/landscape         {"nodes", "routes", "text"}
/// Tenant: XSUAA token (zid) or X-Tenant-Id header, else the default tenant.
class TransportOperationsController {
  protected TransportPorts ports;
  protected string defaultTenant;

  this(TransportPorts ports, string defaultTenant) {
    this.ports = ports;
    this.defaultTenant = defaultTenant;
  }

  void registerRoutes(URLRouter router) {
    router.post(restBase ~ "/nodes-import", &handleImport);
    router.get(restBase ~ "/statistics", &handleStatistics);
    router.get(restBase ~ "/landscape", &handleLandscape);
  }

  protected RequestIdentity identityOf(HTTPServerRequest req) {
    return resolveIdentity(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
      req.headers.get("X-User-Id", ""), defaultTenant);
  }

  void handleImport(HTTPServerRequest req, HTTPServerResponse res) {
    auto identity = identityOf(req);
    Json body;
    try
      body = req.json;
    catch (Exception)
      body = Json.emptyObject;
    ImportInput input;
    input.tenantId = identity.tenantId;
    input.nodeId = TransportNodeId(fieldString(body, "nodeId"));
    foreach (id; fieldStrings(body, "entryIds"))
      input.entryIds ~= ImportQueueEntryId(id);
    input.performedBy = fieldString(body, "performedBy", identity.userName);
    if (input.nodeId.isEmpty)
      return write(res, errorResponse("'nodeId' is required", 400), 400);
    auto r = ports.operations.importNode(input);
    write(res, usecaseResponse(r, "Imported"), r.isSuccess ? 200 : (r.code > 0 ? cast(int) r.code : 400));
  }

  void handleStatistics(HTTPServerRequest req, HTTPServerResponse res) {
    write(res, ports.statistics.statistics(identityOf(req).tenantId).toJson, 200);
  }

  void handleLandscape(HTTPServerRequest req, HTTPServerResponse res) {
    auto l = ports.landscape.landscape(identityOf(req).tenantId);
    auto nodes = Json.emptyArray;
    foreach (n; l.nodes)
      nodes ~= n.toJson;
    auto routes = Json.emptyArray;
    foreach (r; l.routes)
      routes ~= r.toJson;
    write(res, Json.emptyObject.set("nodes", nodes).set("routes", routes).set("text", l.render), 200);
  }

  protected static void write(HTTPServerResponse res, Json payload, int status) {
    res.writeBody(payload.toString, status, "application/json; charset=UTF-8");
  }
}
