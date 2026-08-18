module uim.platform.authorization.presentation.web.controller;

import std.algorithm : map;
import std.array : array;
import std.conv : to;
import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationWebController : ManageHttpController {
  protected AuthorizationWebModel model;
  private AuthorizationWebView view;

  this(AuthorizationWebModel model, AuthorizationWebView view) {
    this.model = model;
    this.view = view;
  }

  private void respond(scope HTTPServerResponse res, Json payload) {
    res.writeJsonBody(payload, payload.code);
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/web", &handleDashboard);

    router.post("/api/v1/applications", &handleCreateApplication);
    router.get("/api/v1/applications", &handleListApplications);
    router.get("/api/v1/applications/*", &handleGetApplication);
    router.put("/api/v1/applications/*", &handleUpdateApplication);
    router.delete_("/api/v1/applications/*", &handleDeleteApplication);

    router.post("/api/v1/application-apis", &handleCreateApi);
    router.get("/api/v1/application-apis", &handleListApis);
    router.get("/api/v1/application-apis/*", &handleGetApi);
    router.put("/api/v1/application-apis/*", &handleUpdateApi);
    router.delete_("/api/v1/application-apis/*", &handleDeleteApi);

    router.post("/api/v1/policies", &handleCreatePolicy);
    router.post("/api/v1/policies/seed-base", &handleSeedBasePolicies);
    router.get("/api/v1/policies", &handleListPolicies);
    router.get("/api/v1/policies/base", &handleListBasePolicies);
    router.get("/api/v1/policies/*", &handleGetPolicy);
    router.put("/api/v1/policies/*", &handleUpdatePolicy);
    router.delete_("/api/v1/policies/*", &handleDeletePolicy);

    router.post("/api/v1/policy-assignments", &handleCreateAssignment);
    router.get("/api/v1/policy-assignments", &handleListAssignments);
    router.get("/api/v1/policy-assignments/*", &handleGetAssignment);
    router.delete_("/api/v1/policy-assignments/*", &handleDeleteAssignment);

    router.post("/api/v1/authorization/evaluate", &handleEvaluateAuthorization);
  }

  void handleDashboard(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto tenantId = precheck.tenantId.to!string;
    auto html = view.renderDashboard(tenantId,
      model.listApplications(tenantId).length,
      model.listPolicies(tenantId).length,
      model.listAssignments(tenantId).length
    );

    res.headers["content-type"] = "text/html; charset=utf-8";
    res.writeBody(html);
  }

  void handleListApplications(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto tenantId = precheck.tenantId.to!string;
    auto items = model.listApplications(tenantId).map!(a => a.toJson()).array.toJson();
    respond(res, view.listResponse("Application", items));
  }

  void handleCreateApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    CreateApplicationRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.name = data.getString("name");
    r.organizationId = data.getString("organizationId");
    r.description = data.getString("description");

    auto result = model.appsUseCase().createApplication(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Application", result.id, 201));
  }

  void handleGetApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto app = model.appsUseCase().getApplication(precheck.tenantId.to!string, precheck.id);
    if (app.id.isEmpty) {
      respond(res, errorResponse("Application not found", 404));
      return;
    }
    respond(res, view.singleResponse("Application", app.toJson()));
  }

  void handleUpdateApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    UpdateApplicationRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.applicationId = precheck.id;
    r.name = data.getString("name");
    r.organizationId = data.getString("organizationId");
    r.description = data.getString("description");

    auto result = model.appsUseCase().updateApplication(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Application", result.id));
  }

  void handleDeleteApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto result = model.appsUseCase().deleteApplication(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 404));
      return;
    }
    respond(res, successResponse("Application deleted", "Deleted", 200, Json(
        ["id": Json(result.id)])));
  }

  void handleListApis(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto items = model.listApis(precheck.tenantId.to!string).map!(a => a.toJson()).array.toJson();
    respond(res, view.listResponse("Application API", items));
  }

  void handleCreateApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    CreateApplicationApiRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.applicationId = data.getString("applicationId");
    r.name = data.getString("name");
    r.endpoint = data.getString("endpoint");
    r.operations = data.getArray("operations").map!(e => e.getString).array;

    auto result = model.appsUseCase().createApplicationApi(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Application API", result.id, 201));
  }

  void handleGetApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto item = model.appsUseCase().getApplicationApi(precheck.tenantId.to!string, precheck.id);
    if (item.id.isEmpty) {
      respond(res, errorResponse("Application API not found", 404));
      return;
    }
    respond(res, view.singleResponse("Application API", item.toJson()));
  }

  void handleUpdateApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    UpdateApplicationApiRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.apiId = precheck.id;
    r.name = data.getString("name");
    r.endpoint = data.getString("endpoint");
    r.operations = data.getArray("operations").map!(e => e.getString).array;

    auto result = model.appsUseCase().updateApplicationApi(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Application API", result.id));
  }

  void handleDeleteApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto result = model.appsUseCase()
      .deleteApplicationApi(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 404));
      return;
    }
    respond(res, successResponse("Application API deleted", "Deleted", 200, Json(
        ["id": Json(result.id)])));
  }

  void handleListPolicies(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto items = model.listPolicies(precheck.tenantId.to!string)
      .map!toJson.array.toJson();
    respond(res, view.listResponse("Policy", items));
  }

  void handleListBasePolicies(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto items = model.listBasePolicies(precheck.tenantId.to!string)
      .map!(p => p.toJson()).array.toJson();
    respond(res, view.listResponse("Base policy", items));
  }

  void handleCreatePolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    CreatePolicyRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.applicationId = data.getString("applicationId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.resource = data.getString("resource");
    r.action = data.getString("action");
    r.isBasePolicy = data.getBoolean("isBasePolicy", false);

    foreach (c; data.getArray("conditions")) {
      PolicyConditionDto dto;
      dto.attribute = c["attribute"].get!string;
      dto.op = c["op"].get!string;
      dto.value = c["value"].get!string;
      r.conditions ~= dto;
    }

    auto result = model.policiesUseCase().createPolicy(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Policy", result.id, 201));
  }

  void handleSeedBasePolicies(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto tenantId = precheck.tenantId.to!string;
    auto data = precheck.data;

    auto applicationId = data.getString("applicationId");
    if (applicationId.length == 0) {
      auto appName = data.getString("applicationName");
      if (appName.length == 0)
        appName = "authorization-management";

      foreach (app; model.appsUseCase().listApplications(tenantId)) {
        if (app.name == appName) {
          applicationId = app.id;
          break;
        }
      }

      if (applicationId.length == 0) {
        CreateApplicationRequest createReq;
        createReq.tenantId = tenantId;
        createReq.name = appName;
        createReq.organizationId = data.getString("organizationId");
        if (createReq.organizationId.length == 0)
          createReq.organizationId = "global";
        createReq.description = "Auto-created during base policy seeding";

        auto created = model.appsUseCase().createApplication(createReq);
        if (!created.ok) {
          respond(res, errorResponse(created.message, 400));
          return;
        }
        applicationId = created.id;
      }
    }

    auto seeded = model.policiesUseCase().seedBasePolicies(tenantId, applicationId);
    auto items = seeded.map!(p => p.toJson()).array.toJson();

    auto payload = Json.emptyObject
      .set("applicationId", applicationId)
      .set("items", items)
      .set("totalCount", seeded.length);

    respond(res, successResponse("Base policies seeded", "Created", 201, payload));
  }

  void handleGetPolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto item = model.policiesUseCase().getPolicy(precheck.tenantId.to!string, precheck.id);
    if (item.id.isEmpty) {
      respond(res, errorResponse("Policy not found", 404));
      return;
    }
    respond(res, view.singleResponse("Policy", item.toJson()));
  }

  void handleUpdatePolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    UpdatePolicyRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.policyId = precheck.id;
    r.description = data.getString("description");
    r.resource = data.getString("resource");
    r.action = data.getString("action");

    foreach (c; data.getArray("conditions")) {
      PolicyConditionDto dto;
      dto.attribute = c["attribute"].get!string;
      dto.op = c["op"].get!string;
      dto.value = c["value"].get!string;
      r.conditions ~= dto;
    }

    auto result = model.policiesUseCase().updatePolicy(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Policy", result.id));
  }

  void handleDeletePolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto result = model.policiesUseCase().deletePolicy(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 404));
      return;
    }
    respond(res, successResponse("Policy deleted", "Deleted", 200, Json([
          "id": Json(result.id)
        ])));
  }

  void handleListAssignments(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto items = model.listAssignments(precheck.tenantId.to!string)
      .map!(a => a.toJson()).array.toJson();
    respond(res, view.listResponse("Policy assignment", items));
  }

  void handleCreateAssignment(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    CreatePolicyAssignmentRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.policyId = data.getString("policyId");
    r.principalType = data.getString("principalType");
    r.principalId = data.getString("principalId");

    auto result = model.assignmentsUseCase().createAssignment(r);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 400));
      return;
    }
    respond(res, view.idResponse("Policy assignment", result.id, 201));
  }

  void handleGetAssignment(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto item = model.assignmentsUseCase().getAssignment(precheck.tenantId.to!string, precheck.id);
    if (item.id.isEmpty) {
      respond(res, errorResponse("Assignment not found", 404));
      return;
    }
    respond(res, view.singleResponse("Policy assignment", item.toJson()));
  }

  void handleDeleteAssignment(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }
    auto result = model.assignmentsUseCase()
      .deleteAssignment(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) {
      respond(res, errorResponse(result.message, 404));
      return;
    }
    respond(res, successResponse("Assignment deleted", "Deleted", 200, Json([
          "id": Json(result.id)
        ])));
  }

  void handleEvaluateAuthorization(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) {
      respond(res, precheck);
      return;
    }

    auto data = precheck.data;
    EvaluateAuthorizationRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.principalId = data.getString("principalId");
    r.applicationId = data.getString("applicationId");
    r.resource = data.getString("resource");
    r.action = data.getString("action");

    if ("attributes" in data && data["attributes"].isObject) {
      foreach (kv; data["attributes"].byKeyValue()) {
        r.attributes[kv.key] = kv.value.get!string;
      }
    }

    auto result = model.evaluate(r);
    respond(res, successResponse("Authorization evaluated", "Retrieved", 200, result.toJson()));
  }
}
