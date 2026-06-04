/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.profile;





// import uim.platform.data_quality.application.usecases.profile_data;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.data_profile;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class ProfileController : HttpController {
  private ProfileDataUseCase usecase;

  this(ProfileDataUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/profiles", &handleProfile);
    router.get("/api/v1/profiles", &handleList);
    router.get("/api/v1/profiles/*", &handleGet);
  }

  protected void handleProfile(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = ProfileDatasetRequest();
      r.tenantId = tenantId;
      r.datasetId = data.getString("datasetId");
      r.datasetName = data.getString("datasetName");

      auto recordsJson = "records" in j;
      if (recordsJson !is null && (recordsJson).isArray) {
        foreach (item; *recordsJson) {
          if (item.isObject) {
            ProfileRecordInput pri;
            pri.recordId = item.getString("recordId");
            pri.fieldValues = jsonStrMap(item, "fieldValues");
            r.records ~= pri;
          }
        }
      }

      auto profile = usecase.profile(r);
      res.writeJsonBody(profile.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto profiles = usecase.listByTenant(tenantId);
      auto arr = profiles.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(profiles.length))
        .set("message", "Data profiles retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto profile = usecase.getById(tenantId, id);
      if (profile.isNull) {
        writeError(res, 404, "Data profile not found");
        return;
      }
      res.writeJsonBody(profile.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
