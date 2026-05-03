/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.survey;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.workzone.application.usecases.manage.surveys;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.survey;
// import uim.platform.identity_authentication.presentation.http;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class SurveyController : PlatformController {
  private ManageSurveysUseCase useCase;

  this(ManageSurveysUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/surveys", &handleCreate);
    router.get("/api/v1/surveys", &handleList);
    router.get("/api/v1/surveys/*", &handleGet);
    router.put("/api/v1/surveys/*", &handleUpdate);
    router.delete_("/api/v1/surveys/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateSurveyRequest();
      r.tenantId = req.getTenantId;
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.creatorId = j.getString("creatorId");
      r.creatorName = j.getString("creatorName");
      r.anonymous = j.getBoolean("anonymous");
      r.allowMultipleResponses = j.getBoolean("allowMultipleResponses");
      r.startsAt = jsonLong(j, "startsAt");
      r.endsAt = jsonLong(j, "endsAt");

      auto result = useCase.createSurvey(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Survey created");

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
      TenantId tenantId = req.getTenantId;
      auto workspaceId = WorkspaceId(req.params.get("workspaceId", ""));
      auto surveys = useCase.listByWorkspace(workspaceId, tenantId);
      auto arr = surveys.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", surveys.length)
        .set("message", "Surveys retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = SurveyId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      auto s = useCase.getSurvey(tenantId, id);
      if (s.isNull) {
        writeError(res, 404, "Survey not found");
        return;
      }
      res.writeJsonBody(s.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateSurveyRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.description = j.getString("description");

      auto result = useCase.updateSurvey(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Survey updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = SurveyId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteSurvey(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Survey deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
