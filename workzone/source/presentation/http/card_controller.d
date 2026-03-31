module uim.platform.identity_authentication.presentation.http.card;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_cards;
import application.dto;
import domain.types;
import domain.entities.card;
import uim.platform.identity_authentication.presentation.http.json_utils;

class CardController
{
    private ManageCardsUseCase useCase;

    this(ManageCardsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/cards", &handleCreate);
        router.get("/api/v1/cards", &handleList);
        router.get("/api/v1/cards/*", &handleGet);
        router.put("/api/v1/cards/*", &handleUpdate);
        router.delete_("/api/v1/cards/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateCardRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.title = jsonStr(j, "title");
            r.subtitle = jsonStr(j, "subtitle");
            r.description = jsonStr(j, "description");
            r.icon = jsonStr(j, "icon");
            r.cardType = parseCardType(jsonStr(j, "cardType"));
            r.dataSource = parseDataSource(j);
            r.manifest = parseManifest(j);

            auto result = useCase.createCard(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto cards = useCase.listCards(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref c; cards)
                arr ~= serializeCard(c);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) cards.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto c = useCase.getCard(id, tenantId);
            if (c is null)
            {
                writeError(res, 404, "Card not found");
                return;
            }
            res.writeJsonBody(serializeCard(*c), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = UpdateCardRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.title = jsonStr(j, "title");
            r.subtitle = jsonStr(j, "subtitle");
            r.description = jsonStr(j, "description");
            r.icon = jsonStr(j, "icon");
            r.active = jsonBool(j, "active", true);
            r.dataSource = parseDataSource(j);
            r.manifest = parseManifest(j);

            auto result = useCase.updateCard(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 404, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            useCase.deleteCard(id, tenantId);
            res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}

private CardType parseCardType(string s)
{
    switch (s)
    {
        case "adaptive": return CardType.adaptive;
        case "analytical": return CardType.analytical;
        case "list": return CardType.list;
        case "table": return CardType.table_;
        case "object": return CardType.object_;
        case "timeline": return CardType.timeline;
        case "component": return CardType.component;
        case "calendar": return CardType.calendar;
        default: return CardType.list;
    }
}

private CardDataSource parseDataSource(Json j)
{
    CardDataSource ds;
    auto v = "dataSource" in j;
    if (v !is null && (*v).type == Json.Type.object)
    {
        auto d = *v;
        ds.url = jsonStr(d, "url");
        ds.method = jsonStr(d, "method");
        ds.path = jsonStr(d, "path");
        ds.refreshIntervalSec = jsonInt(d, "refreshIntervalSec");
        ds.authType = jsonStr(d, "authType");
        ds.authToken = jsonStr(d, "authToken");
    }
    return ds;
}

private CardManifest parseManifest(Json j)
{
    CardManifest m;
    auto v = "manifest" in j;
    if (v !is null && (*v).type == Json.Type.object)
    {
        auto d = *v;
        m.type = jsonStr(d, "type");
        m.version_ = jsonStr(d, "version");
        m.minVersion = jsonStr(d, "minVersion");
        m.headerTitle = jsonStr(d, "headerTitle");
        m.headerSubtitle = jsonStr(d, "headerSubtitle");
        m.headerIcon = jsonStr(d, "headerIcon");
        m.headerStatus = jsonStr(d, "headerStatus");
        m.maxItems = jsonInt(d, "maxItems");
    }
    return m;
}

private Json serializeCard(ref Card c)
{
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["title"] = Json(c.title);
    j["subtitle"] = Json(c.subtitle);
    j["description"] = Json(c.description);
    j["icon"] = Json(c.icon);
    j["cardType"] = Json(c.cardType.to!string);
    j["active"] = Json(c.active);
    j["createdAt"] = Json(c.createdAt);
    j["updatedAt"] = Json(c.updatedAt);

    // Data source
    auto ds = Json.emptyObject;
    ds["url"] = Json(c.dataSource.url);
    ds["method"] = Json(c.dataSource.method);
    ds["path"] = Json(c.dataSource.path);
    ds["refreshIntervalSec"] = Json(c.dataSource.refreshIntervalSec);
    ds["authType"] = Json(c.dataSource.authType);
    j["dataSource"] = ds;

    // Manifest
    auto mj = Json.emptyObject;
    mj["type"] = Json(c.manifest.type);
    mj["version"] = Json(c.manifest.version_);
    mj["headerTitle"] = Json(c.manifest.headerTitle);
    mj["maxItems"] = Json(c.manifest.maxItems);
    j["manifest"] = mj;

    return j;
}
