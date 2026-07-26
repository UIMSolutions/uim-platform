module uim.platform.authorization.presentation.web.controller;

import std.algorithm : map;
import std.array : array;
import std.conv : to;
import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationWebController : ManageHttpController {
  private AuthorizationWebModel model;
  private AuthorizationWebView view;

  this(AuthorizationWebModel model, AuthorizationWebView view) {
    this.model = model;
    this.view = view;
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
      responseJson(precheck, req, res);
      return;
    }

    auto tenantId = precheck.tenantId.to!string;
    auto html = view.renderDashboard(
      tenantId,
      model.listApplications(tenantId).length,
      model.listPolicies(tenantId).length,
      model.listAssignments(tenantId).length
    );

    res.headers["content-type"] = "text/html; charset=utf-8";
    res.writeBody(html);
  }

  void handleListApplications(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto tenantId = precheck.tenantId.to!string;
    auto items = model.listApplications(tenantId).map!(a => a.toJson()).array.toJson();
    responseJson(view.listResponse("Application", items), req, res);
  }

  void handleCreateApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    CreateApplicationRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.name = data.getString("name");
    r.organizationId = data.getString("organizationId");
    r.description = data.getString("description");

    auto result = model.appsUseCase().createApplication(r);
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Application", result.id, 201), req, res);
  }

  void handleGetApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto app = model.appsUseCase().getApplication(precheck.tenantId.to!string, precheck.id);
    if (app.id.isEmpty) return responseJson(errorResponse("Application not found", 404), req, res);
    responseJson(view.singleResponse("Application", app.toJson()), req, res);
  }

  void handleUpdateApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    UpdateApplicationRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.applicationId = precheck.id;
    r.name = data.getString("name");
    r.organizationId = data.getString("organizationId");
    r.description = data.getString("description");

    auto result = model.appsUseCase().updateApplication(r);
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Application", result.id), req, res);
  }

  void handleDeleteApplication(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto result = model.appsUseCase().deleteApplication(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) return responseJson(errorResponse(result.message, 404), req, res);
    responseJson(successResponse("Application deleted", "Deleted", 200, Json(["id": Json(result.id)])), req, res);
  }

  void handleListApis(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto items = model.listApis(precheck.tenantId.to!string).map!(a => a.toJson()).array.toJson();
    responseJson(view.listResponse("Application API", items), req, res);
  }

  void handleCreateApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    CreateApplicationApiRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.applicationId = data.getString("applicationId");
    r.name = data.getString("name");
    r.endpoint = data.getString("endpoint");
    r.operations = data.getArray("operations").map!(e => e.getString).array;

    auto result = model.appsUseCase().createApplicationApi(r);
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Application API", result.id, 201), req, res);
  }

  void handleGetApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto item = model.appsUseCase().getApplicationApi(precheck.tenantId.to!string, precheck.id);
    if (item.id.isEmpty) return responseJson(errorResponse("Application API not found", 404), req, res);
    responseJson(view.singleResponse("Application API", item.toJson()), req, res);
  }

  void handleUpdateApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    UpdateApplicationApiRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.apiId = precheck.id;
    r.name = data.getString("name");
    r.endpoint = data.getString("endpoint");
    r.operations = data.getArray("operations").map!(e => e.getString).array;

    auto result = model.appsUseCase().updateApplicationApi(r);
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Application API", result.id), req, res);
  }

  void handleDeleteApi(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto result = model.appsUseCase().deleteApplicationApi(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) return responseJson(errorResponse(result.message, 404), req, res);
    responseJson(successResponse("Application API deleted", "Deleted", 200, Json(["id": Json(result.id)])), req, res);
  }

  void handleListPolicies(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto items = model.listPolicies(precheck.tenantId.to!string).map!(p => p.toJson()).array.toJson();
    responseJson(view.listResponse("Policy", items), req, res);
  }

  void handleListBasePolicies(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto items = model.listBasePolicies(precheck.tenantId.to!string).map!(p => p.toJson()).array.toJson();
    responseJson(view.listResponse("Base policy", items), req, res);
  }

  void handleCreatePolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    CreatePolicyRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.applicationId = data.getString("applicationId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.resource = data.getString("resource");
    r.action = data.getString("action");
    r.isBasePolicy = data.getBool("isBasePolicy");

    foreach (c; data.getArray("conditions")) {
      PolicyConditionDto dto;
      dto.attribute = c["attribute"].get!string;
      dto.op = c["op"].get!string;
      dto.value = c["value"].get!string;
      r.conditions ~= dto;
    }

    auto result = model.policiesUseCase().createPolicy(r);
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Policy", result.id, 201), req, res);
  }

  void handleGetPolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto item = model.policiesUseCase().getPolicy(precheck.tenantId.to!string, precheck.id);
    if (item.id.isEmpty) return responseJson(errorResponse("Policy not found", 404), req, res);
    responseJson(view.singleResponse("Policy", item.toJson()), req, res);
  }

  void handleUpdatePolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

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
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Policy", result.id), req, res);
  }

  void handleDeletePolicy(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto result = model.policiesUseCase().deletePolicy(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) return responseJson(errorResponse(result.message, 404), req, res);
    responseJson(successResponse("Policy deleted", "Deleted", 200, Json(["id": Json(result.id)])), req, res);
  }

  void handleListAssignments(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto items = model.listAssignments(precheck.tenantId.to!string).map!(a => a.toJson()).array.toJson();
    responseJson(view.listResponse("Policy assignment", items), req, res);
  }

  void handleCreateAssignment(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    CreatePolicyAssignmentRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.policyId = data.getString("policyId");
    r.principalType = data.getString("principalType");
    r.principalId = data.getString("principalId");

    auto result = model.assignmentsUseCase().createAssignment(r);
    if (!result.ok) return responseJson(errorResponse(result.message, 400), req, res);
    responseJson(view.idResponse("Policy assignment", result.id, 201), req, res);
  }

  void handleGetAssignment(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto item = model.assignmentsUseCase().getAssignment(precheck.tenantId.to!string, precheck.id);
    if (item.id.isEmpty) return responseJson(errorResponse("Assignment not found", 404), req, res);
    responseJson(view.singleResponse("Policy assignment", item.toJson()), req, res);
  }

  void handleDeleteAssignment(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);
    auto result = model.assignmentsUseCase().deleteAssignment(precheck.tenantId.to!string, precheck.id);
    if (!result.ok) return responseJson(errorResponse(result.message, 404), req, res);
    responseJson(successResponse("Assignment deleted", "Deleted", 200, Json(["id": Json(result.id)])), req, res);
  }

  void handleEvaluateAuthorization(HTTPServerRequest req, HTTPServerResponse res) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) return responseJson(precheck, req, res);

    auto data = precheck.data;
    EvaluateAuthorizationRequest r;
    r.tenantId = precheck.tenantId.to!string;
    r.principalId = data.getString("principalId");
    r.applicationId = data.getString("applicationId");
    r.resource = data.getString("resource");
    r.action = data.getString("action");

    auto attrs = data.getObject("attributes");
    foreach (kv; attrs.byKeyValue()) {
      r.attributes[kv.key] = kv.value.get!string;
    }

    auto result = model.evaluate(r);
    responseJson(successResponse("Authorization evaluated", "Retrieved", 200, result.toJson()), req, res);
  }
}
