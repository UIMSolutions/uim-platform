/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.enrichment_data;

import uim.platform.document_ai.application.usecases.manage.enrichment_data;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.enrichment_data : EnrichmentData;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class EnrichmentDataController : SAPController {
  private ManageEnrichmentDataUseCase uc;

  this(ManageEnrichmentDataUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/enrichment-data", &handleCreate);
    router.get("/api/v1/enrichment-data", &handleList);
    router.get("/api/v1/enrichment-data/*", &handleGet);
    router.put("/api/v1/enrichment-data/*", &handleUpdate);
    router.delete_("/api/v1/enrichment-data/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateEnrichmentDataRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentTypeId = j.getString("documentTypeId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.subtype = j.getString("subtype");
      r.fields = jsonKeyValuePairs(j, "fields");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Enrichment data created");
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto clientId = req.headers.get("X-Client-Id", "");
      auto data = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (ref ed; data) {
        jarr ~= enrichmentToJson(ed);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) data.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto ed = uc.get_(id, clientId);
      if (ed.id.isEmpty) {
        writeError(res, 404, "Enrichment data not found");
        return;
      }

      res.writeJsonBody(enrichmentToJson(ed), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      UpdateEnrichmentDataRequest r;
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.enrichmentDataId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.fields = jsonKeyValuePairs(j, "fields");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Enrichment data updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto result = uc.remove(id, clientId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json enrichmentToJson(ref EnrichmentData ed) {
    auto ej = Json.emptyObject;
    ej["id"] = Json(ed.id);
    ej["documentTypeId"] = Json(ed.documentTypeId);
    ej["name"] = Json(ed.name);
    ej["description"] = Json(ed.description);
    ej["subtype"] = Json(ed.subtype);
    ej["createdAt"] = Json(ed.createdAt);
    ej["modifiedAt"] = Json(ed.modifiedAt);

    auto fArr = Json.emptyArray;
    foreach (ref f; ed.fields) {
      auto fj = Json.emptyObject;
      fj["key"] = Json(f.key);
      fj["value"] = Json(f.value);
      fArr ~= fj;
    }
    ej["fields"] = fArr;

    return ej;
  }
}
