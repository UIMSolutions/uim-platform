/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.address;

// import uim.platform.data_quality.application.usecases.cleanse_addresses;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.address_record;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class AddressController : HttpController {
  private CleanseAddressesUseCase usecase;

  this(CleanseAddressesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/addresses/cleanse", &handleCleanse);
    router.post("/api/v1/addresses/cleanse/batch", &handleCleanseBatch);
    router.get("/api/v1/addresses", &handleList);
  }

  protected Json cleanseHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CleanseAddressRequest();
    r.tenantId = precheck.tenantId;
    r.sourceRecordId = data.getString("sourceRecordId");
    r.line1 = data.getString("line1");
    r.line2 = data.getString("line2");
    r.city = data.getString("city");
    r.region = data.getString("region");
    r.postalCode = data.getString("postalCode");
    r.country = data.getString("country");

    auto result = usecase.cleanse(r);
    return successResponse("Address cleansed successfully", 0, result.toJson);
  }

  protected void handleCleanse(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = cleanseHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json cleanseBatchHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto batchReq = CleanseBatchAddressRequest();
    batchReq.tenantId = precheck.tenantId;

    foreach (item; data.getArray("addresses")) {
      if (item.isObject) {
        CleanseAddressRequest a;
        a.tenantId = batchReq.tenantId;
        a.sourceRecordId = item.getString("sourceRecordId");
        a.line1 = item.getString("line1");
        a.line2 = item.getString("line2");
        a.city = item.getString("city");
        a.region = item.getString("region");
        a.postalCode = item.getString("postalCode");
        a.country = item.getString("country");
        batchReq.addresses ~= a;
      }
    }

    auto results = usecase.cleanseBatch(batchReq);
    auto arr = results.map!(r => r.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("results", arr)
      .set("totalCount", Json(results.length))
      .set("message", "Address cleansing results retrieved successfully");

    return successResponse("Address cleansing batch processed successfully", 0, resp);
  }

  protected void handleCleanseBatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = cleanseBatchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto records = usecase.getByTenant(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Addresses retrieved successfully", 0, responseData);
  }
}
