/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.scenario;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.integration.automation.application.usecases.manage.scenarios;
import uim.platform.integration.automation.application.dto;
import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.integration_scenario;
import uim.platform.integration.automation.presentation.http.json_utils;

class ScenarioController {
  private ManageScenariosUseCase useCase;

  this(ManageScenariosUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/scenarios", &handleCreate);
    router.get("/api/v1/scenarios", &handleList);
    router.get("/api/v1/scenarios/*", &handleGetById);
    router.put("/api/v1/scenarios/*", &handleUpdate);
    router.delete_("/api/v1/scenarios/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateScenarioRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = parseScenarioCategory(j.getString("category"));
      r.version_ = j.getString("version");
      r.sourceSystemType = parseSystemType(j.getString("sourceSystemType"));
      r.targetSystemType = parseSystemType(j.getString("targetSystemType"));
      r.prerequisites = jsonStrArray(j, "prerequisites");
      r.stepTemplates = parseStepTemplates(j);
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createScenario(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto scenarios = useCase.listScenarios(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; scenarios)
        arr ~= serializeScenario(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) scenarios.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto scenario = useCase.getScenario(tenantId, id);
      if (scenario is null) {
        writeError(res, 404, "Scenario not found");
        return;
      }
      res.writeJsonBody(serializeScenario(*scenario), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateScenarioRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = parseScenarioCategory(j.getString("category"));
      r.version_ = j.getString("version");
      r.status = parseScenarioStatus(j.getString("status"));
      r.sourceSystemType = parseSystemType(j.getString("sourceSystemType"));
      r.targetSystemType = parseSystemType(j.getString("targetSystemType"));
      r.prerequisites = jsonStrArray(j, "prerequisites");
      r.stepTemplates = parseStepTemplates(j);

      auto result = useCase.updateScenario(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteScenario(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeScenario(ref const IntegrationScenario s) {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["tenantId"] = Json(s.tenantId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["category"] = Json(s.category.to!string);
    j["version"] = Json(s.version_);
    j["status"] = Json(s.status.to!string);
    j["sourceSystemType"] = Json(s.sourceSystemType.to!string);
    j["targetSystemType"] = Json(s.targetSystemType.to!string);
    j["prerequisites"] = toJsonArray(s.prerequisites);
    j["createdBy"] = Json(s.createdBy);
    j["createdAt"] = Json(s.createdAt);
    j["updatedAt"] = Json(s.updatedAt);

    if (s.stepTemplates.length > 0) {
      auto steps = Json.emptyArray;
      foreach (ref t; s.stepTemplates) {
        auto sj = Json.emptyObject;
        sj["name"] = Json(t.name);
        sj["description"] = Json(t.description);
        sj["type"] = Json(t.type_.to!string);
        sj["priority"] = Json(t.priority.to!string);
        sj["sequenceNumber"] = Json(t.sequenceNumber);
        sj["assignedRole"] = Json(t.assignedRole);
        sj["instructions"] = Json(t.instructions);
        sj["automationEndpoint"] = Json(t.automationEndpoint);
        sj["estimatedDurationMinutes"] = Json(t.estimatedDurationMinutes);
        steps ~= sj;
      }
      j["stepTemplates"] = steps;
    }

    return j;
  }

  private static ScenarioStepTemplate[] parseStepTemplates(Json j) {
    ScenarioStepTemplate[] result;
    auto v = "stepTemplates" in j;
    if (v is null || (*v).type != Json.Type.array)
      return result;
    foreach (item; *v) {
      if (item.type == Json.Type.object) {
        ScenarioStepTemplate t;
        t.name = item.getString("name");
        t.description = item.getString("description");
        t.type_ = parseStepType(item.getString("type"));
        t.priority = parseStepPriority(item.getString("priority"));
        t.sequenceNumber = jsonInt(item, "sequenceNumber");
        t.assignedRole = item.getString("assignedRole");
        t.instructions = item.getString("instructions");
        t.automationEndpoint = item.getString("automationEndpoint");
        t.automationPayload = item.getString("automationPayload");
        t.requiresSourceSystem item.getBoolean("requiresSourceSystem");
        t.requiresTargetSystem item.getBoolean("requiresTargetSystem");
        t.estimatedDurationMinutes = jsonInt(item, "estimatedDurationMinutes");
        result ~= t;
      }
    }
    return result;
  }
}

ScenarioCategory parseScenarioCategory(string s) {
  switch (s) {
  case "leadToCash":
    return ScenarioCategory.leadToCash;
  case "sourceToPay":
    return ScenarioCategory.sourceToPay;
  case "recruitToRetire":
    return ScenarioCategory.recruitToRetire;
  case "designToOperate":
    return ScenarioCategory.designToOperate;
  case "btpServices":
    return ScenarioCategory.btpServices;
  case "s4HanaIntegration":
    return ScenarioCategory.s4HanaIntegration;
  case "communicationManagement":
    return ScenarioCategory.communicationManagement;
  case "custom":
    return ScenarioCategory.custom;
  default:
    return ScenarioCategory.custom;
  }
}

ScenarioStatus parseScenarioStatus(string s) {
  switch (s) {
  case "draft":
    return ScenarioStatus.draft;
  case "active":
    return ScenarioStatus.active;
  case "deprecated":
    return ScenarioStatus.deprecated_;
  case "archived":
    return ScenarioStatus.archived;
  default:
    return ScenarioStatus.draft;
  }
}

SystemType parseSystemType(string s) {
  switch (s) {
  case "sapS4Hana":
    return SystemType.sapS4Hana;
  case "sapS4HanaCloud":
    return SystemType.sapS4HanaCloud;
  case "sapBtp":
    return SystemType.sapBtp;
  case "sapSuccessFactors":
    return SystemType.sapSuccessFactors;
  case "sapAriba":
    return SystemType.sapAriba;
  case "sapConcur":
    return SystemType.sapConcur;
  case "sapFieldglass":
    return SystemType.sapFieldglass;
  case "sapIntegratedBusinessPlanning":
    return SystemType.sapIntegratedBusinessPlanning;
  case "sapBuildWorkZone":
    return SystemType.sapBuildWorkZone;
  case "onPremise":
    return SystemType.onPremise;
  case "thirdParty":
    return SystemType.thirdParty;
  default:
    return SystemType.thirdParty;
  }
}

StepType parseStepType(string s) {
  switch (s) {
  case "manual":
    return StepType.manual;
  case "automated":
    return StepType.automated;
  case "approval":
    return StepType.approval;
  case "notification":
    return StepType.notification;
  default:
    return StepType.manual;
  }
}

StepPriority parseStepPriority(string s) {
  switch (s) {
  case "low":
    return StepPriority.low;
  case "medium":
    return StepPriority.medium;
  case "high":
    return StepPriority.high;
  case "critical":
    return StepPriority.critical;
  default:
    return StepPriority.medium;
  }
}
