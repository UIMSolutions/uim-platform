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
class MarketRateController : ManageHttpController {
  private ManageMarketRatesUseCase ratesUC;
  private ManageProvidersUseCase providersUC;

  this(ManageMarketRatesUseCase ratesUC, ManageProvidersUseCase providersUC) {
    this.ratesUC = ratesUC;
    this.providersUC = providersUC;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    // Upload / download
    router.post("/api/v1/marketrates/upload", &handleUpload);
    router.post("/api/v1/marketrates/download", &handleDownload);

    // Rate records
    router.get("/api/v1/marketrates/rates", &handleListRates);
    router.get("/api/v1/marketrates/rates/*", &handleGetRate);
    router.delete_("/api/v1/marketrates/rates", &handleDeleteRates);

    // Provider management
    router.get("/api/v1/marketrates/providers", &handleListProviders);
    router.post("/api/v1/marketrates/providers", &handleCreateProvider);
    router.get("/api/v1/marketrates/providers/*", &handleGetProvider);
    router.put("/api/v1/marketrates/providers/*", &handleUpdateProvider);
    router.delete_("/api/v1/marketrates/providers/*", &handleDeleteProvider);
  }

  // ------------------------------------------------------------------
  // Upload
  // ------------------------------------------------------------------
  protected Json uploadHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UploadRatesRequest ucReq;
    ucReq.tenantId = tenantId;
    ucReq.requestedBy = data.getString("requestedBy");

    foreach (r; data.getArray("records")) {
      UploadRateRecord rec;
      rec.providerCode = r.getString("providerCode");
      rec.dataSource = r.getString("dataSource");
      rec.category = r.getString("category");
      rec.key1 = r.getString("key1");
      rec.key2 = r.getString("key2");
      rec.marketDataProperty = r.getString("marketDataProperty");
      rec.effectiveDate = r.getString("effectiveDate");
      rec.effectiveTime = r.getString("effectiveTime", "000000");
      rec.marketDataValue = jsonDouble(r, "marketDataValue");
      rec.securityCurrency = r.getString("securityCurrency");
      rec.fromFactor = r.getInteger("fromFactor", 1);
      rec.toFactor = r.getInteger("toFactor", 1);
      rec.priceQuotation = r.getString("priceQuotation", "direct");
      rec.additionalKey = r.getString("additionalKey");
      ucReq.records ~= rec;
    }

    auto result = ratesUC.upload(ucReq);

    auto responseData = Json.emptyObject
      .set("status", result.status.to!string)
      .set("acceptedCount", result.acceptedCount)
      .set("rejectedCount", result.rejectedCount)
      .set("errors", result.messages.map!(e => Json(e)).array.toJson);

    int statusCode = result.status == OperationStatus.failed ? 422 : 200;
    return successResponse("Upload completed", statusCode, responseData);
  }

  mixin(HandleTemplate!("handleUpload", "uploadHandler"));

  // ------------------------------------------------------------------
  // Download
  // ------------------------------------------------------------------
  protected Json downloadHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    DownloadRatesRequest ucReq;
    ucReq.tenantId = tenantId;
    ucReq.requestedBy = data.getString("requestedBy");
    ucReq.providerCode = data.getString("providerCode");
    ucReq.fromDate = data.getString("fromDate");
    ucReq.toDate = data.getString("toDate");
    ucReq.latestOnly = jsonBool(data, "latestOnly", false);

    auto instrJson = data["instruments"];
    if (instrJson.isArray) {
      foreach (i; instrJson.byValue) {
        DownloadInstrument instr;
        instr.key1 = jsonStr(i, "key1");
        instr.key2 = jsonStr(i, "key2");
        instr.category = jsonStr(i, "category");
        ucReq.instruments ~= instr;
      }
    }

    auto result = ratesUC.download(ucReq);

    auto ratesArr = Json.emptyArray;
    foreach (r; result.rates)
      ratesArr ~= r.toJson();

    auto j = Json.emptyObject;
    j["status"] = Json(result.status.to!string);
    j["totalCount"] = Json(result.totalCount);
    j["rates"] = ratesArr;

    return successResponse("Download completed", 200, j);
  }

  mixin(HandleTemplate!("handleDownload", "downloadHandler"));

  // ------------------------------------------------------------------
  // List rates (management UI query)
  // ------------------------------------------------------------------
  protected Json listRatesHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto providerCode = req.query.get("providerCode", "");
    auto category = req.query.get("category", "");
    auto fromDate = req.query.get("fromDate", "");
    auto toDate = req.query.get("toDate", "");
    auto key1 = req.query.get("key1", "");
    auto key2 = req.query.get("key2", "");

    QueryRatesRequest ucReq;
    ucReq.tenantId = tenantId;
    ucReq.providerCode = providerCode;
    ucReq.category = category;
    ucReq.fromDate = fromDate;
    ucReq.toDate = toDate;
    ucReq.key1 = key1;
    ucReq.key2 = key2;

    auto rates = ratesUC.query(ucReq);

    auto arr = Json.emptyArray;
    foreach (r; rates)
      arr ~= r.toJson();

    auto j = Json.emptyObject;
    j["data"] = arr;
    j["count"] = Json(cast(int)rates.length);
    return successResponse(j, "Rates retrieved successfully", 200);
  }

  mixin(HandleTemplate!("handleListRates", "listRatesHandler"));

  // ------------------------------------------------------------------
  // Get single rate
  // ------------------------------------------------------------------
  protected Json getRateHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = precheck.id;
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto rate = ratesUC.getById(tenantId, MarketRateId(id));

    if (rate.isNull) {
      return errorResponse("Market rate not found", 404);
    }
    return successResponse(rate.toJson(), "Market rate retrieved successfully", 200);
  }

  mixin(HandleTemplate!("handleGetRate", "getRateHandler"));

  // ------------------------------------------------------------------
  // Delete rates
  // ------------------------------------------------------------------
  protected Json deleteRatesHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto key1 = req.query.get("key1", "");
    auto key2 = req.query.get("key2", "");
    auto category = req.query.get("category", "");
    auto fromDate = req.query.get("fromDate", "");
    auto toDate = req.query.get("toDate", "");

    DeleteRatesRequest ucReq;
    ucReq.tenantId = tenantId;
    // TODO:  ucReq.key1 = key1;
    // TODO:  ucReq.key2 = key2;
    ucReq.category = category;
    ucReq.fromDate = fromDate;
    ucReq.toDate = toDate;

    auto result = ratesUC.deleteRate(ucReq);

    if (!result.success) {
      return errorResponse(result.message, 422);
    }

    auto j = Json.emptyObject.set("deleted", true);
    return successResponse(j, "Rates deleted successfully", 200);
  }

  mixin(HandleTemplate!("handleDeleteRates", "deleteRatesHandler"));

  // ------------------------------------------------------------------
  // Provider CRUD
  // ------------------------------------------------------------------
  protected Json listProvidersHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto providers = providersUC.list(tenantId);

    auto arr = Json.emptyArray;
    foreach (p; providers)
      arr ~= p.toJson();

    auto j = Json.emptyObject;
    j["data"] = arr;
    j["count"] = Json(cast(int)providers.length);
    return successResponse(j, "Providers retrieved successfully", 200);
  }

  mixin(HandleTemplate!("handleListProviders", "listProvidersHandler"));

  protected Json createProviderHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateProviderRequest ucReq;
    ucReq.tenantId = tenantId;
    ucReq.requestedBy = data.getString("requestedBy");
    ucReq.code = data.getString("code");
    ucReq.name = data.getString("name");
    ucReq.description = data.getString("description");
    ucReq.contactEmail = data.getString("contactEmail");

    auto result = providersUC.createProvider(ucReq);
    if (!result.success) {
      return errorResponse(result.message, 422);
    }

    auto j = Json.emptyObject.set("id", result.id).set("created", true);
    return successResponse(j, "Provider created successfully", 201);
  }

  mixin(HandleTemplate!("handleCreateProvider", "createProviderHandler"));

  protected Json getProviderHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = precheck.id;
    auto tenantId = TenantId(req.query.get("tenantId", "default"));
    auto p = providersUC.getById(tenantId, ProviderId(id));

    if (p.isNull)
      return errorResponse("Provider not found", 404);

    auto responseData = p.toJson();
    return successResponse("Provider retrieved successfully", "OK", 200, responseData);
  }

  mixin(HandleTemplate!("handleGetProvider", "getProviderHandler"));

  protected Json updateProviderHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = precheck.id;
    auto data = precheck.data;

    UpdateProviderRequest ucReq;
    ucReq.tenantId = precheck.tenantId;
    ucReq.providerId = ProviderId(id);
    ucReq.name = data.getString("name");
    ucReq.description = data.getString("description");
    ucReq.contactEmail = data.getString("contactEmail");
    ucReq.isActive = jsonBool(data, "isActive", true);

    auto result = providersUC.updateProvider(ucReq);
    if (!result.success) {
      return errorResponse(result.message, 422);
    }

    auto j = Json.emptyObject.set("updated", true);
    return successResponse(j, "Provider updated successfully", 200);
  }

  mixin(HandleTemplate!("handleUpdateProvider", "updateProviderHandler"));



  protected Json deleteProviderHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto id = precheck.id;
    auto tenantId = TenantId(req.query.get("tenantId", "default"));

    auto result = providersUC.deleteProvider(tenantId, ProviderId(id));
    if (!result.success) {
      return errorResponse(result.message, 404);
    }

    auto j = Json.emptyObject.set("deleted", true);
    return successResponse(j, "Provider deleted successfully", 200);
  }

  mixin(HandleTemplate!("handleDeleteProvider", "deleteProviderHandler"));

}
