/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.presentation.http.controllers.key_entry;

import uim.platform.keystore;

@safe:

class KeyEntryController : PlatformController {
  private ManageKeyEntriesUseCase uc;

  this(ManageKeyEntriesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    // Entries are scoped under a keystore
    router.post("/api/v1/keystores/*/entries",       &handleImport);
    router.get("/api/v1/keystores/*/entries",        &handleList);
    router.get("/api/v1/keystores/*/entries/*",      &handleGet);
    router.delete_("/api/v1/keystores/*/entries/*",  &handleDelete);
  }

  // POST /api/v1/keystores/{keystoreId}/entries
  private void handleImport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto path      = req.requestPath.to!string;
      auto keystoreId = extractSegment(path, 4); // /api/v1/keystores/{id}/entries
      auto j          = req.json;
      ImportKeyEntryRequest r;
      r.keystoreId  = keystoreId;
      r.alias_      = j.getString("alias");
      r.entryType   = j.getString("entryType");
      r.content     = j.getString("content");
      r.format      = j.getString("format");
      r.subject     = j.getString("subject");
      r.issuer      = j.getString("issuer");
      r.serialNumber = j.getString("serialNumber");
      r.notBefore   = j.getInt("notBefore");
      r.notAfter    = j.getInt("notAfter");

      auto result = uc.importEntry(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores/{keystoreId}/entries
  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto path       = req.requestPath.to!string;
      auto keystoreId = extractSegment(path, 4);
      auto entries    = uc.listByKeystore(keystoreId);

      auto jarr = Json.emptyArray;
      foreach (e; entries) {
        jarr ~= Json.emptyObject
          .set("id",           e.id)
          .set("alias",        e.alias_)
          .set("entryType",    keyEntryTypeToString(e.entryType))
          .set("format",       e.format)
          .set("subject",      e.subject)
          .set("issuer",       e.issuer)
          .set("serialNumber", e.serialNumber)
          .set("notBefore",    e.notBefore)
          .set("notAfter",     e.notAfter)
          .set("createdAt",    e.createdAt);
      }

      auto resp = Json.emptyObject;
      resp["items"]      = jarr;
      resp["totalCount"] = Json(cast(long)entries.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/keystores/{keystoreId}/entries/{id}
  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id    = extractIdFromPath(req);
      auto entry = uc.getById(id);
      if (entry.id.length == 0) {
        writeError(res, 404, "Key entry not found");
        return;
      }
      auto j = Json.emptyObject
        .set("id",           entry.id)
        .set("keystoreId",   entry.keystoreId)
        .set("alias",        entry.alias_)
        .set("entryType",    keyEntryTypeToString(entry.entryType))
        .set("content",      entry.content)
        .set("format",       entry.format)
        .set("subject",      entry.subject)
        .set("issuer",       entry.issuer)
        .set("serialNumber", entry.serialNumber)
        .set("notBefore",    entry.notBefore)
        .set("notAfter",     entry.notAfter)
        .set("createdAt",    entry.createdAt);
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // DELETE /api/v1/keystores/{keystoreId}/entries/{id}
  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id     = extractIdFromPath(req);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private string keyEntryTypeToString(KeyEntryType t) @safe {
    final switch (t) {
      case KeyEntryType.privateKey:          return "privateKey";
      case KeyEntryType.certificate:         return "certificate";
      case KeyEntryType.secretKey:           return "secretKey";
      case KeyEntryType.trustedCertificate:  return "trustedCertificate";
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
