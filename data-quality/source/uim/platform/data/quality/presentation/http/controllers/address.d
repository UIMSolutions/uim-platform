/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.controllers.address;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.quality.application.usecases.cleanse_addresses;
// import uim.platform.data.quality.application.dto;
// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.address_record;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class AddressController : PlatformController {
  private CleanseAddressesUseCase uc;

  this(CleanseAddressesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/addresses/cleanse", &handleCleanse);
    router.post("/api/v1/addresses/cleanse/batch", &handleCleanseBatch);
    router.get("/api/v1/addresses", &handleList);
  }

  private void handleCleanse(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CleanseAddressRequest();
      r.tenantId = req.getTenantId;
      r.sourceRecordId = j.getString("sourceRecordId");
      r.line1 = j.getString("line1");
      r.line2 = j.getString("line2");
      r.city = j.getString("city");
      r.region = j.getString("region");
      r.postalCode = j.getString("postalCode");
      r.country = j.getString("country");

      auto result = uc.cleanse(r);
      res.writeJsonBody(result.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCleanseBatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto batchReq = CleanseBatchAddressRequest();
      batchReq.tenantId = req.getTenantId;

      if ("addresses" in j && j["addresses"].isArray) {
        foreach (item; j["addresses"].toArray) {
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
      }

      auto results = uc.cleanseBatch(batchReq);
      auto arr = results.map!(r => serializeAddress(r)).array.toJson;

      auto resp = Json.emptyObject
            .set("results", arr)
            .set("totalCount", Json(results.length))
            .set("message", "Address cleansing results retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto records = uc.getByTenant(tenantId);
      auto arr = records.map!(r => serializeAddress(r)).array;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(records.length))
            .set("message", "Address records retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeAddress(const AddressRecord r) {
    // Input
    auto input = Json.emptyObject;
    input["line1"] = Json(r.inputLine1);
    input["line2"] = Json(r.inputLine2);
    input["city"] = Json(r.inputCity);
    input["region"] = Json(r.inputRegion);
    input["postalCode"] = Json(r.inputPostalCode);
    input["country"] = Json(r.inputCountry);

    // Cleansed output
    auto output = Json.emptyObject
      .set("line1", r.line1)
      .set("line2", r.line2)
      .set("city", r.city)
      .set("region", r.region)
      .set("postalCode", r.postalCode)
      .set("country", r.country)
      .set("countryIso2", r.countryIso2);

    // Geocoding
    auto geo = Json.emptyObject
      .set("latitude", r.latitude)
      .set("longitude", r.longitude)
      .set("precision", r.geocodePrecision.to!string);

    auto j = Json.emptyObject
      .set("id", r.id)
      .set("tenantId", r.tenantId)
      .set("sourceRecordId", r.sourceRecordId)
      .set("input", input)
      .set("output", output)
      .set("addressType", r.addressType.to!string)
      .set("quality", r.quality.to!string)
      .set("geocoding", geo)
      .set("cleansedAt", r.cleansedAt);

    if (r.changeLog.length > 0) {
      auto changes = Json.emptyArray;
      foreach (ch; r.changeLog)
        changes ~= Json(ch);
      j["changeLog"] = changes;
    }

    return j;
  }
}
