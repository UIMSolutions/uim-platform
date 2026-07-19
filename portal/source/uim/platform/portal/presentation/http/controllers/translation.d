/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.translation;

// import uim.platform.portal.application.usecases.manage.translations;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.translation;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.application.usecases.manage;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class TranslationController : ManageHttpController {
  private ManageTranslationsUseCase useCase;

  this(ManageTranslationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/translations", &handleCreate);
    router.get("/api/v1/translations", &handleList);
    router.get("/api/v1/translations/*", &handleGet);
    router.put("/api/v1/translations/*", &handleUpdate);
    router.delete_("/api/v1/translations/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateTranslationRequest(tenantId,
      data.getString("resourceType"), data.getString("resourceId"),
      data.getString("fieldName"), data.getString("language"), data.getString("value"),);

    auto result = useCase.createTranslation(createReq);
    if (result.hasError) 
      return errorResponse(result.message, 400);
    
      auto response = Json.emptyObject
        .set("id", result.translationId);

        return successResponse("Translation created successfully", "Created", 201, response);
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto language = req.headers.get("X-Language", "");
  auto resourceType = req.headers.get("X-Resource-Type", "");
  auto resourceId = req.headers.get("X-Resource-Id", "");

  Translation[] translations = resourceType.length > 0 && !resourceId.isEmpty
    ? useCase.listTranslations(tenantId, resourceType, resourceId, language)
    : useCase.listTranslations(tenantId, language);

  auto response = Json.emptyObject;
  response["totalResults"] = Json(translations.length);
  response["resources"] = toJsonArray(translations);

  return successResponse("Translations retrieved successfully", "Retrieved", 200, response);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto translationId = precheck.id;
  auto translation = useCase.getTranslation(tenantId, translationId);
  if (translation.isNull)
    return errorResponse("Translation not found", 404);

  return successReponse("Translation retrieved successfully", "Retrieved", 200, translation.toJson());
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto translationId = precheck.id;
  auto data = precheck.data;
  auto updateReq = UpdateTranslationRequest(translationId, data.getString("value"),);

  auto result = useCase.updateTranslation(tenantId, updateReq);
  if (result.hasError)
    return errorResponse(result.message, 400);

  return successResponse("Translation updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
    // writeApiError(res, 404, error);
  // else
    // res.writeJsonBody(Json.emptyObject, 200);
// }
//  catch (Exception e) {
  // writeApiError(res, 500, "Internal server error");
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = TranslationId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid translation ID", 400);

  auto result = useCase.deleteTranslation(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  return successResponse("Translation deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
    // writeApiError(res, 404, error);

//   if (error.length > 0)
//     writeApiError(res, 404, error);
//   else
//     res.writeJsonBody(Json.emptyObject, 204);
// }
//  catch (Exception e) {
//   writeApiError(res, 500, "Internal server error");

}
