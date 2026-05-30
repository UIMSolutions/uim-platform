/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.card;



// import uim.platform.workzone.application.usecases.manage.cards;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.card;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class CardController : ManageController {
  private ManageCardsUseCase useCase;

  this(ManageCardsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cards", &handleCreate);
    router.get("/api/v1/cards", &handleList);
    router.get("/api/v1/cards/*", &handleGet);
    router.put("/api/v1/cards/*", &handleUpdate);
    router.delete_("/api/v1/cards/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateCardRequest();
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.subtitle = data.getString("subtitle");
      r.description = data.getString("description");
      r.icon = data.getString("icon");
      r.cardType = parseCardType(data.getString("cardType"));
      r.dataSource = parseDataSource(j);
      r.manifest = parseManifest(j);

      auto result = useCase.createCard(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Card created");

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
      auto cards = useCase.listCards(tenantId);
      auto arr = cards.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", cards.length)
        .set("items", arr)
        .set("message", "Cards retrieved successfully");

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
      
      auto c = useCase.getCard(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "Card not found");
        return;
      }
      res.writeJsonBody(c.toJson, 200);
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
      auto r = UpdateCardRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.subtitle = data.getString("subtitle");
      r.description = data.getString("description");
      r.icon = data.getString("icon");
      r.active = data.getBoolean("active", true);
      r.dataSource = parseDataSource(j);
      r.manifest = parseManifest(j);

      auto result = useCase.updateCard(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Card updated");

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
      useCase.deleteCard(tenantId, id);
      res.writeBody("", 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private CardType parseCardType(string s) {
  switch (s) {
  case "adaptive":
    return CardType.adaptive;
  case "analytical":
    return CardType.analytical;
  case "list":
    return CardType.list;
  case "table":
    return CardType.table_;
  case "object":
    return CardType.object_;
  case "timeline":
    return CardType.timeline;
  case "component":
    return CardType.component;
  case "calendar":
    return CardType.calendar;
  default:
    return CardType.list;
  }
}

private CardDataSource parseDataSource(Json j) {
  CardDataSource ds;
  auto v = "dataSource" in j;
  if (v !is null && (v).isObject) {
    auto d = *v;
    ds.url = d.getString("url");
    ds.method = d.getString("method");
    ds.path = d.getString("path");
    ds.refreshIntervalSec = jsonInt(d, "refreshIntervalSec");
    ds.authType = d.getString("authType");
    ds.authToken = d.getString("authToken");
  }
  return ds;
}

private CardManifest parseManifest(Json j) {
  CardManifest m;
  auto v = "manifest" in j;
  if (v !is null && (v).isObject) {
    auto d = *v;
    m.type = d.getString("type");
    m.version_ = d.getString("version");
    m.minVersion = d.getString("minVersion");
    m.headerTitle = d.getString("headerTitle");
    m.headerSubtitle = d.getString("headerSubtitle");
    m.headerIcon = d.getString("headerIcon");
    m.headerStatus = d.getString("headerStatus");
    m.maxItems = jsonInt(d, "maxItems");
  }
  return m;
}

private Json serializeCard(Card c) {
  // Data source
  auto ds = Json.emptyObject
    .set("url", c.dataSource.url)
    .set("method", c.dataSource.method)
    .set("path", c.dataSource.path)
    .set("refreshIntervalSec", c.dataSource.refreshIntervalSec)
    .set("authType", c.dataSource.authType);

  // Manifest
  auto mj = Json.emptyObject
    .set("type", c.manifest.type)
    .set("version", c.manifest.version_)
    .set("headerTitle", c.manifest.headerTitle)
    .set("maxItems", c.manifest.maxItems);

  
  return Json.emptyObject
    .set("id", c.id)
    .set("tenantId", c.tenantId)
    .set("title", c.title)
    .set("subtitle", c.subtitle)
    .set("description", c.description)
    .set("icon", c.icon)
    .set("cardType", c.cardType.to!string)
    .set("active", c.active)
    .set("createdAt", c.createdAt)
    .set("updatedAt", c.updatedAt)
    .set("dataSource", ds)
    .set("manifest", mj);
}
