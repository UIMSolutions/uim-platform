/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_process;
// import uim.platform.data.privacy.application.usecases.manage.business_processes;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_process;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BusinessProcessController : ManageController {
  private ManageBusinessProcessesUseCase usecase;

  this(ManageBusinessProcessesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-processes", &handleCreate);
    router.get("/api/v1/business-processes", &handleList);
    router.get("/api/v1/business-processes/*", &handleGet);
    router.put("/api/v1/business-processes/*", &handleUpdate);
    router.delete_("/api/v1/business-processes/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateBusinessProcessRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.controllerId = data.getString("controllerId");
      r.purposes = data.getStrings("purposes");
      r.legalBases = data.getStrings("legalBases");
      r.owner = data.getString("owner");

      auto result = usecase.createProcess(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Business process created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto items = usecase.listProcesses(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Business processes retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = BusinessProcessId(precheck.id);

      auto entry = usecase.getProcess(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Business process not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      UpdateBusinessProcessRequest r;
      r.processId = BusinessProcessId(precheck.id);
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.purposes = data.getStrings("purposes");
      r.legalBases = data.getStrings("legalBases");
      r.owner = data.getString("owner");

      auto result = usecase.updateProcess(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Business process updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = BusinessProcessId(precheck.id);

      usecase.deleteProcess(tenantId, id);

      auto resp = Json.emptyObject
        .set("message", "Business process deleted successfully");

      res.writeJsonBody(resp, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const BusinessProcess e) {
    auto purps = e.purposes.map!(p => p.to!string).array.toJson;

    auto bases = e.legalBases.map!(b => b.to!string).array.toJson;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("name", e.name)
      .set("description", e.description)
      .set("controllerId", e.controllerId)
      .set("owner", e.owner)
      .set("isActive", e.isActive)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("purposes", purps)
      .set("legalBases", bases);
  }
}
