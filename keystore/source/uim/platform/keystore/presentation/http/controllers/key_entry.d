/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.presentation.http.controllers.key_entry;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

class KeyEntryController : ManageController {
  private ManageKeyEntriesUseCase usecase;

  this(ManageKeyEntriesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    // Entries are scoped under a keystore
    router.post("/api/v1/keystores/*/entries", &handleImport);
    router.get("/api/v1/keystores/*/entries", &handleList);
    router.get("/api/v1/keystores/*/entries/*", &handleGet);
    router.delete_("/api/v1/keystores/*/entries/*", &handleDelete);
  }

  protected Json importHandler(HTTPServerRequest req) {
    auto path = req.requestPath.to!string;
    auto keystoreId = extractSegment(path, 4); // /api/v1/keystores/{id}/entries
    auto j = req.json;
    ImportKeyEntryRequest r;
    r.keystoreId = keystoreId;
    r.alias_ = j.getString("alias");
    r.entryType = j.getString("entryType");
    r.content = j.getString("content");
    r.format = j.getString("format");
    r.subject = j.getString("subject");
    r.issuer = j.getString("issuer");
    r.serialNumber = j.getString("serialNumber");
    r.notBefore = j.getInteger("notBefore");
    r.notAfter = j.getInteger("notAfter");

    auto result = usecase.importEntry(r);
    if (result.hasError)
      return errorResponse(result.message);

    return successResponse("Key entry imported successfully", 201, Json.emptyObject.set("id", result
        .id));
  }

  // POST /api/v1/keystores/{keystoreId}/entries
  protected void handleImport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resp = importHandler(req);
      res.writeJsonBody(resp, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = req.requestPath.to!string;
    auto keystoreId = KeystoreId(extractSegment(path, 4)); // /api/v1/keystores/{id}/entries
    auto entries = usecase.listByKeystore(tenantId, keystoreId);

    auto jarr = Json.emptyArray;
    foreach (e; entries) {
      jarr ~= Json.emptyObject
        .set("id", e.id)
        .set("alias", e.alias_)
        .set("entryType", e.entryType.to!string)
        .set("content", e.content)
        .set("format", e.format)
        .set("subject", e.subject)
        .set("issuer", e.issuer)
        .set("serialNumber", e.serialNumber)
        .set("notBefore", e.notBefore)
        .set("notAfter", e.notAfter)
        .set("createdAt", e.createdAt);
    }

    return successResponse("Key entries retrieved successfully", 200,
      Json.emptyObject
        .set("items", jarr)
        .set("totalCount", entries.length));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = req.requestPath.to!string;
    auto id = KeyEntryId(extractSegment(path, 6)); // /api/v1/keystores/{id}/entries/{entryId}
    auto entry = usecase.getById(tenantId, id);
    if (entry.isNull)
      return errorResponse("Key entry not found", 404);

    return successResponse("Key entry retrieved successfully", 200,
      Json.emptyObject
        .set("id", entry.id)
        .set("keystoreId", entry.keystoreId)
        .set("alias", entry.alias_)
        .set("entryType", entry.entryType.to!string)
        .set("content", entry.content)
        .set("format", entry.format)
        .set("subject", entry.subject)
        .set("issuer", entry.issuer)
        .set("serialNumber", entry.serialNumber)
        .set("notBefore", entry.notBefore)
        .set("notAfter", entry.notAfter)
        .set("createdAt", entry.createdAt));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (!precheck.isNull)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = KeyEntryId(extractSegment(req.requestPath.to!string, 6)); // /api/v1/keystores/{id}/entries/{entryId}
    auto result = usecase.deleteKeyEntry(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Key entry deleted successfully", 204);
  }

  // DELETE /api/v1/keystores/{keystoreId}/entries/{id}
  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deleteHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // Extract path segment at 1-based position (split by '/')
  private string extractSegment(string path, size_t pos) @safe {
    import std.string : split;

    auto parts = path.split("/");
    if (parts.length > pos)
      return parts[pos];
    return "";
  }
}
