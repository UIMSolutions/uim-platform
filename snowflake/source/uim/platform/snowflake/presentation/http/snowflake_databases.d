module uim.platform.snowflake.presentation.http.snowflake_databases;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;

// mixin(ShowModule!());
@safe:
class SnowflakeDatabaseController : ManageHttpController {
  private ManageSnowflakeDatabasesUseCase usecase;
  this(ManageSnowflakeDatabasesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get   ("/api/v1/snowflake/databases",    &handleList);
    router.get   ("/api/v1/snowflake/databases/*",  &handleGet);
    router.post  ("/api/v1/snowflake/databases",    &handleCreate);
    router.put   ("/api/v1/snowflake/databases/*",  &handleUpdate);
    router.delete_("/api/v1/snowflake/databases/*", &handleDelete);
  }

 override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Database list retrieved successfully", "Retrieved", 200, responseData);
  }

 override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = item.toJson();
        return successResponse("Database retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
          auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    CreateDatabaseRequest r;
    r.tenantId      = tenantId;
    r.id            = precheck.id;
    r.accountId     = data.getString("accountId");
    r.name          = data.getString("name");
    r.comment       = data.getString("comment");
    if (j["retentionDays"].isInteger) r.retentionDays = cast(int) j["retentionDays"].get!long;
    auto result = usecase.create(r);
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Database created successfully", "Created", 201, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateDatabaseRequest r;
    r.tenantId = tenantId;
    r.id       = extractIdFromPath(req.requestPath.to!string);
    r.status   = data.getString("status");
    r.comment  = data.getString("comment");
    if (j["retentionDays"].isInteger) r.retentionDays = cast(int) j["retentionDays"].get!long;
    auto result = usecase.update(r);
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Database updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = extractIdFromPath(req.requestPath.to!string);
        if (id.isNull)
            return errorResponse("Invalid database ID", 400); 

    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse(
  }
}
