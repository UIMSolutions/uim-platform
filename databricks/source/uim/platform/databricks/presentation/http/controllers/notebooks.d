module uim.platform.databricks.presentation.http.controllers.notebooks;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class NotebookController : ManageHttpController {
private:
  ManageNotebooksUseCase _usecase;

public:
  this(ManageNotebooksUseCase usecase) { _usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    router.post   ("/api/v1/databricks/notebooks",   &handleCreate);
    router.get    ("/api/v1/databricks/notebooks",   &handleList);
    router.get    ("/api/v1/databricks/notebooks/*", &handleGet);
    router.put    ("/api/v1/databricks/notebooks/*", &handleUpdate);
    router.delete_("/api/v1/databricks/notebooks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      CreateNotebookRequest r;
      r.tenantId    = tenantId;
      r.id          = precheck.id;
      r.workspaceId = data.getString("workspaceId");
      r.path        = data.getString("path");
      r.name        = data.getString("name");
      r.content     = data.getString("content");
      r.format      = data.getString("format");
      r.ownerId     = data.getString("ownerId");
      auto langStr  = data.getString("language");
      if (langStr.length > 0) {
        import std.conv : to, ConvException;
        try { r.language = langStr.to!NotebookLanguage; } catch (ConvException) {}
      }
      auto result = _usecase.create(r);
      if (result.success) res.writeJsonBody(serializeToJson(result.data), 201);
      else writeError(res, 400, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto result = _usecase.list(req.getTenantId);
      res.writeJsonBody(serializeToJson(result.data));
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.get(tenantId, id);
      if (result.success) res.writeJsonBody(serializeToJson(result.data));
      else writeError(res, 404, result.message);
    } catch (Exception e) { writeError(res, 500, "Internal server error"); }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto data = precheck.data;
      UpdateNotebookRequest r;
      r.tenantId = precheck.tenantId;
      r.id       = req.requestPath.to!string.split("/")[$-1];
      r.name     = data.getString("name");
      r.content  = data.getString("content");
      r.format   = data.getString("format");
      auto result = _usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Notebook updated successfully", 200, responseData);
  }



  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      
      auto id     = req.requestPath.to!string.split("/")[$-1];
      auto result = _usecase.remove(req.getTenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Notebook deleted successfully", 200, responseData);
  }
}
