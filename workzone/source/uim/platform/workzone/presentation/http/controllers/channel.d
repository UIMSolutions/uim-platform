/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.channel;

// import uim.platform.workzone.application.usecases.manage.channels;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.channel;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ChannelController : ManageController {
  private ManageChannelsUseCase useCase;

  this(ManageChannelsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGet);
    router.put("/api/v1/channels/*", &handleUpdate);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateChannelRequest();
      r.workspaceId = data.getString("workspaceId");
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");

      auto ctStr = data.getString("channelType");
      if (ctStr == "notification")
        r.channelType = ChannelType.notification;
      else if (ctStr == "custom")
        r.channelType = ChannelType.custom;
      else if (ctStr == "external")
        r.channelType = ChannelType.external;
      else
        r.channelType = ChannelType.activity;

      r.config = parseChannelConfig(j);

      auto result = useCase.createChannel(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Channel created");

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
      auto workspaceId = WorkspaceId(req.params.get("workspaceId", ""));
      auto channels = useCase.listByWorkspace(tenantId, workspaceId);
      auto arr = channels.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", channels.length)
        .set("message", "Channels retrieved successfully");

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
      auto ch = useCase.getChannel(tenantId, id);
      if (ch.isNull) {
        writeError(res, 404, "Channel not found");
        return;
      }
      res.writeJsonBody(ch.toJson, 200);
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
      auto r = UpdateChannelRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.active = data.getBoolean("active", true);
      r.config = parseChannelConfig(j);

      auto result = useCase.updateChannel(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "updated")
          .set("message", "Channel updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
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
      useCase.deleteChannel(tenantId, id);
      res.writeBody("", 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private ChannelConfig parseChannelConfig(Json j) {
  import uim.platform.workzone.domain.entities.channel : ChannelConfig;

  ChannelConfig cfg;
  auto v = "config" in j;
  if (v !is null && (v).isObject) {
    auto c = *v;
    cfg.sourceUrl = c.getString("sourceUrl");
    cfg.pollIntervalSec = jsonInt(c, "pollIntervalSec");
    cfg.authType = c.getString("authType");
    cfg.authToken = c.getString("authToken");
    cfg.maxItems = jsonInt(c, "maxItems");
  }
  return cfg;
}

private Json serializeChannel(Channel c) {
  auto cfg = Json.emptyObject
    .set("sourceUrl", c.config.sourceUrl)
    .set("pollIntervalSec", c.config.pollIntervalSec)
    .set("authType", c.config.authType)
    .set("maxItems", c.config.maxItems);

  auto j = Json.emptyObject
    .set("id", c.id)
    .set("workspaceId", c.workspaceId)
    .set("tenantId", c.tenantId)
    .set("name", c.name)
    .set("description", c.description)
    .set("channelType", c.channelType.to!string)
    .set("active", c.active)
    .set("createdAt", c.createdAt)
    .set("updatedAt", c.updatedAt)
    .set("config", cfg);

  return j;
}
