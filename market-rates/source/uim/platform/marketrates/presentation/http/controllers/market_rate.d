/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.presentation.http.controllers.market_rate;
import uim.platform.marketrates;


mixin(ShowModule!());

@safe:

// Handles upload, download, query and delete of market rates,
// and provider CRUD – the primary HTTP driving adapter.
class MarketRateController : SAPController {
  private ManageMarketRatesUseCase ratesUC;
  private ManageProvidersUseCase   providersUC;

  this(ManageMarketRatesUseCase ratesUC, ManageProvidersUseCase providersUC) {
    this.ratesUC     = ratesUC;
    this.providersUC = providersUC;
  }

  override void registerRoutes(URLRouter router) {
    // Upload / download
    router.post("/api/v1/marketrates/upload",   &handleUpload);
    router.post("/api/v1/marketrates/download", &handleDownload);

    // Rate records
    router.get ("/api/v1/marketrates/rates",    &handleListRates);
    router.get ("/api/v1/marketrates/rates/*",  &handleGetRate);
    router.delete_("/api/v1/marketrates/rates", &handleDeleteRates);

    // Provider management
    router.get   ("/api/v1/marketrates/providers",    &handleListProviders);
    router.post  ("/api/v1/marketrates/providers",    &handleCreateProvider);
    router.get   ("/api/v1/marketrates/providers/*",  &handleGetProvider);
    router.put   ("/api/v1/marketrates/providers/*",  &handleUpdateProvider);
    router.delete_("/api/v1/marketrates/providers/*", &handleDeleteProvider);
  }

  // ------------------------------------------------------------------
  // Upload
  // ------------------------------------------------------------------
  private void handleUpload(HTTPServerRequest req, HTTPServerResponse res) {
    auto body_ = req.json;
    if (body_.type == Json.Type.undefined) {
      writeError(res, 400, "Request body must be JSON");
      return;
    }

    UploadRatesRequest ucReq;
    ucReq.tenantId    = TenantId(jsonStr(body_, "tenantId", "default"));
    ucReq.requestedBy = jsonStr(body_, "requestedBy");

    auto recordsJson = body_["records"];
    if (recordsJson.isArray) {
      foreach (r; recordsJson.byValue) {
        UploadRateRecord rec;
        rec.providerCode       = jsonStr(r, "providerCode");
        rec.dataSource         = jsonStr(r, "dataSource");
        rec.category           = jsonStr(r, "category");
        rec.key1               = jsonStr(r, "key1");
        rec.key2               = jsonStr(r, "key2");
        rec.marketDataProperty = jsonStr(r, "marketDataProperty");
        rec.effectiveDate      = jsonStr(r, "effectiveDate");
        rec.effectiveTime      = jsonStr(r, "effectiveTime", "000000");
        rec.marketDataValue    = jsonDouble(r, "marketDataValue");
        rec.securityCurrency   = jsonStr(r, "securityCurrency");
        rec.fromFactor         = jsonInt(r, "fromFactor", 1);
        rec.toFactor           = jsonInt(r, "toFactor", 1);
        rec.priceQuotation     = jsonStr(r, "priceQuotation", "direct");
        rec.additionalKey      = jsonStr(r, "additionalKey");
        ucReq.records ~= rec;
      }
    }

    auto result = ratesUC.upload(ucReq);

    auto j = Json.emptyObject;
    j["status"]        = Json(result.status.to!string);
    j["acceptedCount"] = Json(result.acceptedCount);
    j["rejectedCount"] = Json(result.rejectedCount);
    auto errArr = Json.emptyArray;
    foreach (e; result.messages) errArr ~= Json(e);
    j["errors"] = errArr;

    int statusCode = result.status == OperationStatus.failed ? 422 : 200;
    res.writeJsonBody(j, cast(int) statusCode);
  }

  // ------------------------------------------------------------------
  // Download
  // ------------------------------------------------------------------
  private void handleDownload(HTTPServerRequest req, HTTPServerResponse res) {
    auto body_ = req.json;
    if (body_.type == Json.Type.undefined) {
      writeError(res, 400, "Request body must be JSON");
      return;
    }

    DownloadRatesRequest ucReq;
    ucReq.tenantId    = TenantId(jsonStr(body_, "tenantId", "default"));
    ucReq.requestedBy = jsonStr(body_, "requestedBy");
    ucReq.providerCode = jsonStr(body_, "providerCode");
    ucReq.fromDate    = jsonStr(body_, "fromDate");
    ucReq.toDate      = jsonStr(body_, "toDate");
    ucReq.latestOnly  = jsonBool(body_, "latestOnly", false);

    auto instrJson = body_["instruments"];
    if (instrJson.isArray) {
      foreach (i; instrJson.byValue) {
        DownloadInstrument instr;
        instr.key1     = jsonStr(i, "key1");
        instr.key2     = jsonStr(i, "key2");
        instr.category = jsonStr(i, "category");
        ucReq.instruments ~= instr;
      }
    }

    auto result = ratesUC.download(ucReq);

    auto ratesArr = Json.emptyArray;
    foreach (r; result.rates) ratesArr ~= r.toJson();

    auto j = Json.emptyObject;
    j["status"]     = Json(result.status.to!string);
    j["totalCount"] = Json(result.totalCount);
    j["rates"]      = ratesArr;
    res.writeJsonBody(j, 200);
  }

  // ------------------------------------------------------------------
  // List rates (management UI query)
  // ------------------------------------------------------------------
  private void handleListRates(HTTPServerRequest req, HTTPServerResponse res) {
    QueryRatesRequest ucReq;
    ucReq.tenantId     = TenantId(req.query.get("tenantId", "default"));
    ucReq.providerCode = req.query.get("providerCode", "");
    ucReq.category     = req.query.get("category", "");
    ucReq.fromDate     = req.query.get("fromDate", "");
    ucReq.toDate       = req.query.get("toDate", "");
    ucReq.key1         = req.query.get("key1", "");
    ucReq.key2         = req.query.get("key2", "");

    auto rates = ratesUC.query(ucReq);

    auto arr = Json.emptyArray;
    foreach (r; rates) arr ~= r.toJson();

    auto j = Json.emptyObject;
    j["data"]  = arr;
    j["count"] = Json(cast(int) rates.length);
    res.writeJsonBody(j, 200);
  }

  // ------------------------------------------------------------------
  // Get single rate
  // ------------------------------------------------------------------
  private void handleGetRate(HTTPServerRequest req, HTTPServerResponse res) {
    auto id       = extractIdFromPath(req);
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto rate     = ratesUC.getById(tenantId, MarketRateId(id));

    if (rate.isNull) {
      writeError(res, 404, "Market rate not found");
      return;
    }
    res.writeJsonBody(rate.toJson(), 200);
  }

  // ------------------------------------------------------------------
  // Delete rates
  // ------------------------------------------------------------------
  private void handleDeleteRates(HTTPServerRequest req, HTTPServerResponse res) {
    auto body_ = req.json;

    DeleteRatesRequest ucReq;
    ucReq.tenantId    = TenantId(jsonStr(body_, "tenantId", "default"));
    ucReq.requestedBy = jsonStr(body_, "requestedBy");
    ucReq.providerCode = jsonStr(body_, "providerCode");
    ucReq.category    = jsonStr(body_, "category");
    ucReq.fromDate    = jsonStr(body_, "fromDate");
    ucReq.toDate      = jsonStr(body_, "toDate");

    auto result = ratesUC.deleteRate(ucReq);

    if (!result.success) {
      writeError(res, 422, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject.set("deleted", true), 200);
  }

  // ------------------------------------------------------------------
  // Provider CRUD
  // ------------------------------------------------------------------
  private void handleListProviders(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto providers = providersUC.list(tenantId);

    auto arr = Json.emptyArray;
    foreach (p; providers) arr ~= p.toJson();

    auto j = Json.emptyObject;
    j["data"]  = arr;
    j["count"] = Json(cast(int) providers.length);
    res.writeJsonBody(j, 200);
  }

  private void handleCreateProvider(HTTPServerRequest req, HTTPServerResponse res) {
    auto body_ = req.json;
    if (body_.type == Json.Type.undefined) {
      writeError(res, 400, "Request body must be JSON");
      return;
    }

    CreateProviderRequest ucReq;
    ucReq.tenantId    = TenantId(jsonStr(body_, "tenantId", "default"));
    ucReq.requestedBy = jsonStr(body_, "requestedBy");
    ucReq.code        = jsonStr(body_, "code");
    ucReq.name        = jsonStr(body_, "name");
    ucReq.description = jsonStr(body_, "description");
    ucReq.contactEmail = jsonStr(body_, "contactEmail");

    auto result = providersUC.createProvider(ucReq);
    if (!result.success) {
      writeError(res, 422, result.message);
      return;
    }

    auto j = Json.emptyObject;
    j["id"]      = Json(result.id);
    j["created"] = Json(true);
    res.writeJsonBody(j, 201);
  }

  private void handleGetProvider(HTTPServerRequest req, HTTPServerResponse res) {
    auto id       = extractIdFromPath(req);
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto p        = providersUC.getById(tenantId, ProviderId(id));

    if (p.isNull) {
      writeError(res, 404, "Provider not found");
      return;
    }
    res.writeJsonBody(p.toJson(), 200);
  }

  private void handleUpdateProvider(HTTPServerRequest req, HTTPServerResponse res) {
    auto id    = extractIdFromPath(req);
    auto body_ = req.json;
    if (body_.type == Json.Type.undefined) {
      writeError(res, 400, "Request body must be JSON");
      return;
    }

    UpdateProviderRequest ucReq;
    ucReq.tenantId    = TenantId(jsonStr(body_, "tenantId", "default"));
    ucReq.providerId  = ProviderId(id);
    ucReq.name        = jsonStr(body_, "name");
    ucReq.description = jsonStr(body_, "description");
    ucReq.contactEmail = jsonStr(body_, "contactEmail");
    ucReq.isActive    = jsonBool(body_, "isActive", true);

    auto result = providersUC.updateProvider(ucReq);
    if (!result.success) {
      writeError(res, 422, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject.set("updated", true), 200);
  }

  private void handleDeleteProvider(HTTPServerRequest req, HTTPServerResponse res) {
    auto id       = extractIdFromPath(req);
    auto tenantId = TenantId(req.query.get("tenantId", "default"));

    auto result = providersUC.deleteProvider(tenantId, ProviderId(id));
    if (!result.success) {
      writeError(res, 404, result.message);
      return;
    }
    res.writeJsonBody(Json.emptyObject.set("deleted", true), 200);
  }
}
