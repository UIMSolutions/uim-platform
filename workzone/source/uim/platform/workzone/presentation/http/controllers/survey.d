/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.presentation.http.survey;



// import uim.platform.workzone.application.usecases.manage.surveys;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.survey;
// import uim.platform.identity.authentication.presentation.http;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class SurveyController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateSurveyRequest();
      r.tenantId = tenantId;
      r.workspaceId = data.getString("workspaceId");
      r.title = data.getString("title");
      r.description = data.getString("description");
      r.creatorId = data.getString("creatorId");
      r.creatorName = data.getString("creatorName");
      r.anonymous = data.getBoolean("anonymous");
      r.allowMultipleResponses = data.getBoolean("allowMultipleResponses");
      r.startsAt = jsonLong(j, "startsAt");
      r.endsAt = jsonLong(j, "endsAt");

      auto result = useCase.createSurvey(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Survey created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto workspaceId = WorkspaceId(req.params.get("workspaceId", ""));
      auto surveys = useCase.listByWorkspace(tenantId, workspaceId);
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = SurveyId(precheck.id);
      auto tenantId = precheck.tenantId;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = UpdateSurveyRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.description = data.getString("description");

      auto result = useCase.updateSurvey(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Survey updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = SurveyId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteSurvey(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Survey deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
