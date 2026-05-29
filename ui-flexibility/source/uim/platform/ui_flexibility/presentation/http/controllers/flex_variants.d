/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_variants;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Routes: /keyuser/v2/variants
class FlexVariantsController : ManageController {
  private ManageFlexVariantsUseCase usecase;

  this(ManageFlexVariantsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/keyuser/v2/variants",    &handleList);
    router.get("/keyuser/v2/variants/*",  &handleGet);
    router.post("/keyuser/v2/variants",   &handleCreate);
    router.put("/keyuser/v2/variants/*",  &handleUpdate);
    router.delete_("/keyuser/v2/variants/*", &handleDelete);
  }

  private static void writeError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(Json.emptyObject.set("error", msg).set("status", status), status);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateFlexVariantRequest request;
      request.tenantId    = tenantId;
      request.variantId   = FlexVariantId(precheck.id);
      request.appId       = data.getString("appId");
      request.variantType_ = data.getString("variantType");
      request.variantName_ = data.getString("variantName");
      request.content_     = data.getString("content");
      request.isDefault_   = j.get("isDefault", Json(false)).get!bool;
      request.isPublic_    = j.get("isPublic", Json(false)).get!bool;
      request.layer_       = data.getString("layer") == "user" ? ChangeLayer.user_ : ChangeLayer.customer_;
      request.author_      = data.getString("author");
      auto result = usecase.createVariant(request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      FlexVariant[] variants;
      auto appParam = req.query.get("appId", "");
      auto publicParam = req.query.get("public", "");
      if (publicParam == "true" && appParam.length > 0)
        variants = usecase.listPublicVariants(tenantId, appParam);
      else if (appParam.length > 0)
        variants = usecase.listVariantsByApp(tenantId, appParam);
      else
        variants = usecase.listVariants(tenantId);
      auto arr = Json.emptyArray;
      foreach (v; variants) arr ~= v.toJson();
      res.writeJsonBody(Json.emptyObject.set("variants", arr).set("count", variants.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = FlexVariantId(precheck.id);
      auto v = usecase.getVariant(tenantId, id);
      if (v.isNull) { writeError(res, 404, "FlexVariant not found"); return; }
      res.writeJsonBody(v.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = FlexVariantId(precheck.id);
      auto data = precheck.data;
      
      UpdateFlexVariantRequest request;
      request.tenantId    = tenantId;
      request.variantId   = id;
      request.variantName_ = data.getString("variantName");
      request.content_     = data.getString("content");
      request.isDefault_   = j.get("isDefault", Json(false)).get!bool;
      request.isPublic_    = j.get("isPublic", Json(false)).get!bool;
      auto result = usecase.updateVariant(request);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = FlexVariantId(precheck.id);
      auto result = usecase.deleteVariant(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
