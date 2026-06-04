/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.configuration;
// import uim.platform.hana.application.usecases.manage.configurations;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ConfigurationController : ManageHttpController {
  private ManageConfigurationsUseCase usecase;

  this(ManageConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/configurations", &handleList);
    router.get("/api/v1/hana/configurations/*", &handleGet);
    router.post("/api/v1/hana/configurations", &handleCreate);
    router.put("/api/v1/hana/configurations/*", &handleUpdate);
    router.delete_("/api/v1/hana/configurations/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = precheck.tenantId;
      CreateConfigurationRequest r;
      r.tenantId = precheck.tenantId;
      r.instanceId = data.getString("instanceId");
      r.id = precheck.id;
      r.section = data.getString("section");
      r.key = data.getString("key");
      r.value = data.getString("value");
      r.scope_ = data.getString("scope");
      r.dataType = data.getString("dataType");
      r.description = data.getString("description");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Configuration created");
        
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
      auto configs = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (c; configs) {
        jarr ~= Json.emptyObject
          .set("id", c.id)
          .set("instanceId", c.instanceId)
          .set("section", c.section)
          .set("key", c.key)
          .set("value", c.value)
          .set("isReadOnly", c.isReadOnly)
          .set("requiresRestart", c.requiresRestart);
      }

      auto resp = Json.emptyObject
        .set("count", configs.length)
        .set("resources", list);
        
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
      auto c = usecase.getById(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", c.id)
        .set("instanceId", c.instanceId)
        .set("section", c.section)
        .set("key", c.key)
        .set("value", c.value)
        .set("defaultValue", c.defaultValue)
        .set("description", c.description)
        .set("isReadOnly", c.isReadOnly)
        .set("requiresRestart", c.requiresRestart)
        .set("updatedAt", c.updatedAt)
        .set("updatedBy", c.updatedBy);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      

      auto data = precheck.data;
      UpdateConfigurationRequest r;
      r.tenantId = precheck.tenantId;
      r.id = precheck.id;
      r.value = data.getString("value");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Configuration updated");
          
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
      auto id = ConfigurationId(precheck.id);
      auto result = usecase.deleteConfiguration(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
