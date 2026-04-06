/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.address;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.data.quality.application.usecases.cleanse_addresses;
import uim.platform.data.quality.application.dto;
import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.address_record;

class AddressController {
  private CleanseAddressesUseCase uc;

  this(CleanseAddressesUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/addresses/cleanse", &handleCleanse);
    router.post("/api/v1/addresses/cleanse/batch", &handleCleanseBatch);
    router.get("/api/v1/addresses", &handleList);
  }

  private void handleCleanse(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CleanseAddressRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.sourceRecordId = j.getString("sourceRecordId");
      r.line1 = j.getString("line1");
      r.line2 = j.getString("line2");
      r.city = j.getString("city");
      r.region = j.getString("region");
      r.postalCode = j.getString("postalCode");
      r.country = j.getString("country");

      auto result = uc.cleanse(r);
      res.writeJsonBody(serializeAddress(result), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCleanseBatch(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto batchReq = CleanseBatchAddressRequest();
      batchReq.tenantId = req.headers.get("X-Tenant-Id", "");

      auto addrJson = "addresses" in j;
      if (addrJson !is null && (*addrJson).type == Json.Type.array)
      {
        foreach (item; *addrJson)
        {
          if (item.type == Json.Type.object)
          {
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
      auto arr = Json.emptyArray;
      foreach (ref r; results)
        arr ~= serializeAddress(r);

      auto resp = Json.emptyObject;
      resp["results"] = arr;
      resp["totalCount"] = Json(cast(long) results.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto records = uc.getByTenant(tenantId);
      auto arr = Json.emptyArray;
      foreach (ref r; records)
        arr ~= serializeAddress(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) records.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeAddress(ref const AddressRecord r)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["sourceRecordId"] = Json(r.sourceRecordId);

    // Input
    auto input = Json.emptyObject;
    input["line1"] = Json(r.inputLine1);
    input["line2"] = Json(r.inputLine2);
    input["city"] = Json(r.inputCity);
    input["region"] = Json(r.inputRegion);
    input["postalCode"] = Json(r.inputPostalCode);
    input["country"] = Json(r.inputCountry);
    j["input"] = input;

    // Cleansed output
    auto output = Json.emptyObject;
    output["line1"] = Json(r.line1);
    output["line2"] = Json(r.line2);
    output["city"] = Json(r.city);
    output["region"] = Json(r.region);
    output["postalCode"] = Json(r.postalCode);
    output["country"] = Json(r.country);
    output["countryIso2"] = Json(r.countryIso2);
    j["output"] = output;

    j["addressType"] = Json(r.addressType.to!string);
    j["quality"] = Json(r.quality.to!string);

    // Geocoding
    auto geo = Json.emptyObject;
    geo["latitude"] = Json(r.latitude);
    geo["longitude"] = Json(r.longitude);
    geo["precision"] = Json(r.geocodePrecision.to!string);
    j["geocoding"] = geo;

    j["cleansedAt"] = Json(r.cleansedAt);

    if (r.changeLog.length > 0)
    {
      auto changes = Json.emptyArray;
      foreach (ch; r.changeLog)
        changes ~= Json(ch);
      j["changeLog"] = changes;
    }

    return j;
  }
}
