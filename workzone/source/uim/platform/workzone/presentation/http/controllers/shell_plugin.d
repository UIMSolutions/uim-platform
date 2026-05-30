/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.shell_plugin;



// import uim.platform.workzone.application.usecases.manage.manage.shell_plugins;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.shell_plugin;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ShellPluginController : ManageController {
  private ManageShellPluginsUseCase useCase;

  this(ManageShellPluginsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/shell-plugins", &handleCreate);
    router.get("/api/v1/shell-plugins", &handleList);
    router.get("/api/v1/shell-plugins/*", &handleGet);
    router.put("/api/v1/shell-plugins/*", &handleUpdate);
    router.delete_("/api/v1/shell-plugins/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateShellPluginRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.version_ = data.getString("version");
      r.vendor = data.getString("vendor");
      r.scriptUrl = data.getString("scriptUrl");
      r.configSchemaUrl = data.getString("configSchemaUrl");
      r.hookPoints = data.getStrings("hookPoints");

      auto result = useCase.createPlugin(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Plugin created");

        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto plugins = useCase.listPlugins(tenantId);
      auto arr = plugins.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(plugins.length))
        .set("message", "Plugins retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
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
      auto p = useCase.getPlugin(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "Plugin not found");
        return;
      }
      res.writeJsonBody(p.toJson, 200);
    }
    catch (Exception e) {
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
      auto r = UpdateShellPluginRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.scriptUrl = data.getString("scriptUrl");

      auto result = useCase.updatePlugin(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
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
      auto result = useCase.deletePlugin(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
