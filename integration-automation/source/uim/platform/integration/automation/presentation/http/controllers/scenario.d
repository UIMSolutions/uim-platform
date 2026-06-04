/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.scenario;




// import uim.platform.integration.automation.application.usecases.manage.scenarios;
// import uim.platform.integration.automation.application.dto;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.integration_scenario;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class ScenarioController : ManageHttpController {
  private ManageScenariosUseCase useCase;

  this(ManageScenariosUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/scenarios", &handleCreate);
    router.get("/api/v1/scenarios", &handleList);
    router.get("/api/v1/scenarios/*", &handleGet);
    router.put("/api/v1/scenarios/*", &handleUpdate);
    router.delete_("/api/v1/scenarios/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateScenarioRequest();
      r.tenantId = precheck.tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.category = parseScenarioCategory(data.getString("category"));
      r.version_ = data.getString("version");
      r.sourceSystemType = parseSystemType(data.getString("sourceSystemType"));
      r.targetSystemType = parseSystemType(data.getString("targetSystemType"));
      r.prerequisites = data.getStrings("prerequisites");
      r.stepTemplates = parseStepTemplates(j);
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createScenario(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario created");

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

      auto items = useCase.listScenarios(tenantId);
      auto arr = items.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Scenarios retrieved successfully");
        
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
      auto scenario = useCase.getScenario(tenantId, id);
      if (scenario.isNull) {
        writeError(res, 404, "Scenario not found");
        return;
      }
      res.writeJsonBody(scenario.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateScenarioRequest();
      r.id = id;
      r.tenantId = precheck.tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.category = parseScenarioCategory(data.getString("category"));
      r.version_ = data.getString("version");
      r.status = parseScenarioStatus(data.getString("status"));
      r.sourceSystemType = parseSystemType(data.getString("sourceSystemType"));
      r.targetSystemType = parseSystemType(data.getString("targetSystemType"));
      r.prerequisites = data.getStrings("prerequisites");
      r.stepTemplates = parseStepTemplates(j);

      auto result = useCase.updateScenario(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteScenario(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  private static ScenarioStepTemplate[] parseStepTemplates(Json j) {
    ScenarioStepTemplate[] result;
    auto v = "stepTemplates" in j;
    if (v.isNull || (v).type != Json.Type.array.toJson)
      return result;
    foreach (item; *v) {
      if (item.isObject) {
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
        t.requiresSourceSystem = item.getBoolean("requiresSourceSystem");
        t.requiresTargetSystem = item.getBoolean("requiresTargetSystem");
        t.estimatedDurationMinutes = jsonInt(item, "estimatedDurationMinutes");
        result ~= t;
      }
    }
    return result;
  }
}

