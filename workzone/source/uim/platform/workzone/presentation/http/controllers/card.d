/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.card;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.cards;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.card;

class CardController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateCardRequest();
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.subtitle = j.getString("subtitle");
      r.description = j.getString("description");
      r.icon = j.getString("icon");
      r.cardType = parseCardType(j.getString("cardType"));
      r.dataSource = parseDataSource(j);
      r.manifest = parseManifest(j);

      auto result = useCase.createCard(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Card created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto cards = useCase.listCards(tenantId);
      auto arr = Json.emptyArray;
      foreach (c; cards)
        arr ~= serializeCard(c);
      auto resp = Json.emptyObject
        .set("count", cards.length)
        .set("items", arr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto c = useCase.getCard(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "Card not found");
        return;
      }
      res.writeJsonBody(serializeCard(*c), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateCardRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.subtitle = j.getString("subtitle");
      r.description = j.getString("description");
      r.icon = j.getString("icon");
      r.active = j.getBoolean("active", true);
      r.dataSource = parseDataSource(j);
      r.manifest = parseManifest(j);

      auto result = useCase.updateCard(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Card updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
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
  if (v !is null && (*v).isObject) {
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
  if (v !is null && (*v).isObject) {
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

  // import std.conv : to;
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
