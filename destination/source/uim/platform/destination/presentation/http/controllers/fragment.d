/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.fragment;




// import uim.platform.destination.application.usecases.manage.fragments;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class FragmentController : ManageController {
  private ManageFragmentsUseCase usecase;

  this(ManageFragmentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/fragments", &handleCreate);
    router.get("/api/v1/fragments", &handleList);
    router.get("/api/v1/fragments/*", &handleGet);
    router.put("/api/v1/fragments/*", &handleUpdate);
    router.delete_("/api/v1/fragments/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateFragmentRequest r;
      r.tenantId = tenantId;
      r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.level = j.getString("level");
      r.url = j.getString("url");
      r.authenticationType = j.getString("authentication");
      r.proxyType = j.getString("proxyType");
      r.user = j.getString("user");
      r.password = j.getString("password");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenServiceUrl = j.getString("tokenServiceURL");
      r.locationId = j.getString("locationId");
      r.keystoreId = j.getString("keystoreId");
      r.truststoreId = j.getString("truststoreId");
      r.properties = jsonStrMap(j, "properties");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createFragment(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Fragment created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
      auto fragments = usecase.listBySubaccount(tenantId, subaccountId);
      auto arr = fragments.map!(f => f.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(fragments.length))
        .set("message", "Fragments retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DestinationFragmentId(precheck.id);
      auto f = usecase.getFragment(tenantId, id);
      if (f.isNull) {
        writeError(res, 404, "Fragment not found");
        return;
      }
      res.writeJsonBody(f.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DestinationFragmentId(precheck.id);
      auto j = req.json;
      UpdateFragmentRequest r;
      r.tenantId = tenantId;
      r.fragmentId = id;
      r.description = j.getString("description");
      r.url = j.getString("url");
      r.authenticationType = j.getString("authentication");
      r.proxyType = j.getString("proxyType");
      r.user = j.getString("user");
      r.password = j.getString("password");
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.tokenServiceUrl = j.getString("tokenServiceURL");
      r.locationId = j.getString("locationId");
      r.keystoreId = j.getString("keystoreId");
      r.truststoreId = j.getString("truststoreId");
      r.properties = jsonStrMap(j, "properties");

      auto result = usecase.updateFragment(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Fragment updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.message == "Fragment not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DestinationFragmentId(precheck.id);

      auto result = usecase.deleteFragment(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Fragment deleted successfully");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  
}
