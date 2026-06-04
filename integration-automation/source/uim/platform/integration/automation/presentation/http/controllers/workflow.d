/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.workflow;




// import uim.platform.integration.automation.application.usecases.manage.workflows;
// import uim.platform.integration.automation.application.dto;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class WorkflowController : ManageHttpController {
  private ManageWorkflowsUseCase useCase;

  this(ManageWorkflowsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/workflows", &handleCreate);
    router.get("/api/v1/workflows", &handleList);
    router.get("/api/v1/workflows/*", &handleGet);
    router.post("/api/v1/workflows/start/*", &handleStart);
    router.post("/api/v1/workflows/suspend/*", &handleSuspend);
    router.post("/api/v1/workflows/resume/*", &handleResume);
    router.post("/api/v1/workflows/terminate/*", &handleTerminate);
    router.delete_("/api/v1/workflows/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateWorkflowRequest();
      r.tenantId = precheck.tenantId;
      r.scenarioId = data.getString("scenarioId");
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.sourceSystemConnectionId = data.getString("sourceSystemConnectionId");
      r.targetSystemConnectionId = data.getString("targetSystemConnectionId");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createWorkflow(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

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

      auto items = useCase.listWorkflows(tenantId);
      auto arr = items.map!(w => w.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Workflows retrieved successfully");

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
      auto wf = useCase.getWorkflow(tenantId, id);
      if (wf.isNull) {
        writeError(res, 404, "Workflow not found");
        return;
      }
      res.writeJsonBody(wf.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleStart(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.startWorkflow(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "inProgress");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlepend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.suspendWorkflow(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "suspended");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleResume(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.resumeWorkflow(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "inProgress");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleTerminate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.terminateWorkflow(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "terminated");

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
      auto result = useCase.deleteWorkflow(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
