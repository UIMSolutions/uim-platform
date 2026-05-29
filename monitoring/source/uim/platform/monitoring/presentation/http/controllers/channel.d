/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.channel;




// import uim.platform.monitoring.application.usecases.manage.notification_channels;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class ChannelController : ManageController {
  private ManageNotificationChannelsUseCase usecase;

  this(ManageNotificationChannelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGet);
    router.put("/api/v1/channels/*", &handleUpdate);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateNotificationChannelRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.channelType = data.getString("channelType");
      r.emailRecipients = data.getStrings("emailRecipients");
      r.emailSubjectPrefix = data.getString("emailSubjectPrefix");
      r.webhookUrl = data.getString("webhookUrl");
      r.webhookSecret = data.getString("webhookSecret");
      r.webhookMethod = data.getString("webhookMethod");
      r.onPremiseHost = data.getString("onPremiseHost");
      r.onPremisePort = data.getInteger("onPremisePort");
      r.onPremiseProtocol = data.getString("onPremiseProtocol");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.createChannel(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Notification channel created");

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
      auto channels = usecase.listChannels(tenantId);
      auto arr = channels.map!(channel => channel.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(channels.length))
        .set("message", "Notification channels retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = NotificationChannelId(precheck.id);
      auto ch = usecase.getChannel(tenantId, id);
      if (ch.isNull) {
        writeError(res, 404, "Notification channel not found");
        return;
      }
      res.writeJsonBody(ch.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = NotificationChannelId(precheck.id);
      auto data = precheck.data;
      
      UpdateNotificationChannelRequest r;
      r.tenantId = tenantId;
      r.id = id;
      r.description = data.getString("description");
      r.state = data.getString("state");
      r.emailRecipients = data.getStrings("emailRecipients");
      r.emailSubjectPrefix = data.getString("emailSubjectPrefix");
      r.webhookUrl = data.getString("webhookUrl");
      r.webhookSecret = data.getString("webhookSecret");
      r.onPremiseHost = data.getString("onPremiseHost");
      r.onPremisePort = data.getInteger("onPremisePort");
      r.onPremiseProtocol = data.getString("onPremiseProtocol");

      auto result = usecase.updateChannel(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto response = Json.emptyObject
          .set("id", result.id)
          .set("message", "Notification channel updated successfully");

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, result.message == "Notification channel not found" ? 404 : 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = NotificationChannelId(precheck.id);

      auto result = usecase.deleteChannel(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto response = Json.emptyObject
          .set("deleted", true)
          .set("message", "Notification channel deleted successfully");

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
