/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.archive_request;
// import uim.platform.data.privacy.application.usecases.manage.archive_requests;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.archive_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ArchiveRequestController : ManageController {
  private ManageArchiveRequestsUseCase usecase;

  this(ManageArchiveRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/archive-requests", &handleCreate);
    router.get("/api/v1/archive-requests", &handleList);
    router.get("/api/v1/archive-requests/*", &handleGet);
    router.put("/api/v1/archive-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/archive-requests/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateArchiveRequest r;
      r.tenantId = tenantId;
      r.subjectId = data.getString("dataSubjectId");
      r.requestedBy = data.getString("requestedBy");
      r.targetSystems = j.getStrings("targetSystems");
      r.categories = j.getStrings("categories");
      r.archiveLocation = data.getString("archiveLocation");
      r.reason = data.getString("reason");
      r.isTestMode = data.getBoolean("isTestMode", false);
      r.scheduledAt = data.getLong("scheduledAt");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Archive request created");

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

      auto items = usecase.listRequests(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Archive requests retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = ArchiveRequestId(precheck.id);

      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Archive request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      UpdateArchiveStatusRequest r;
      r.tenantId = tenantId;
      r.requestId = ArchiveRequestId(precheck.id);
      r.status = data.getString("status");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Archive request status updated");

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
      auto id = ArchiveRequestId(precheck.id);

      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static ArchiveStatus parseArchiveStatus(string status) {
    switch (status) {
    case "inProgress":
      return ArchiveStatus.inProgress;
    case "completed":
      return ArchiveStatus.completed;
    case "failed":
      return ArchiveStatus.failed;
    default:
      return ArchiveStatus.scheduled;
    }
  }
}
