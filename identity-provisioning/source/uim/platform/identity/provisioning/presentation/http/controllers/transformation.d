/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.transformation;




// import uim.platform.identity.provisioning.application.usecases.manage.transformations;
// import uim.platform.identity.provisioning.application.dto;
// import uim.platform.identity.provisioning.domain.entities.transformation;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning;

mixin(ShowModule!());

@safe:
import uim.platform.identity.provisioning;
class TransformationController : ManageHttpController {
  private ManageTransformationsUseCase usecase;

  this(ManageTransformationsUseCase usecase) {
    this.usecase = usecase;
  }

    override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/transformations", &handleCreate);
    router.get("/api/v1/transformations", &handleList);
    router.get("/api/v1/transformations/*", &handleGet);
    router.put("/api/v1/transformations/*", &handleUpdate);
    router.delete_("/api/v1/transformations/*", &handleDelete);
    router.post("/api/v1/transformations/test", &handleTest);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateTransformationRequest();
      r.tenantId = tenantId;
      r.systemId = data.getString("systemId");
      r.systemRole = parseSystemRole(data.getString("systemRole"));
      r.name = data.getString("name");
      r.mappingRules = data.getString("mappingRules");
      r.conditions = data.getString("conditions");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createTransformation(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse(("", 0, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto items = usecase.listTransformations(tenantId);

      auto arr = items.map!(t => t.toJson).array.toJson;

      auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto t = usecase.getTransformation(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "Transformation not found");
        return;
      }
      res.writeJsonBody(t.toJson, 200);
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
      auto r = UpdateTransformationRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.mappingRules = data.getString("mappingRules");
      r.conditions = data.getString("conditions");

      auto result = usecase.updateTransformation(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else {
        auto status = result.message == "Transformation not found" ? 404 : 400;
        writeError(res, status, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleTest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto systemId = data.getString("systemId");
      auto inputAttributes = data.getString("inputAttributes");

      if (systemId.isEmpty || inputAttributes.length == 0) {
        writeError(res, 400, "systemId and inputAttributes are required");
        return;
      }

      auto output = usecase.testTransformation(tenantId, inputAttributes, systemId);
      auto resp = Json.emptyObject
      .set("output", output);
      res.writeJsonBody(resp, 200);
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
      auto result = usecase.deleteTransformation(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
