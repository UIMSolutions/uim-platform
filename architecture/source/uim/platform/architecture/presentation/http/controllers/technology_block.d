module uim.platform.architecture.presentation.http.controllers.technology_block;

import std.array : array;
import std.conv : to;
import std.string : toLower;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class TechnologyBlockController : ManageHttpController {
    private ManageTechnologyBlocksUseCase usecase;

    this(ManageTechnologyBlocksUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/technology-blocks", &handleList);
        router.get("/api/v1/technology-blocks/types/*", &handleListByType);
        router.get("/api/v1/technology-blocks/*", &handleGet);
        router.post("/api/v1/technology-blocks", &handleCreate);
        router.put("/api/v1/technology-blocks/*", &handleUpdate);
        router.delete_("/api/v1/technology-blocks/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = usecase.listBlocks(tenantId).map!(item => item.toJson()).array;
        auto itemsJson = items.toJson;
        return successResponse("Technology blocks listed", 200, Json.emptyObject
            .set("count", items.length)
            .set("items", itemsJson));
    }

    private void handleListByType(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            res.writeJsonBody(precheck, precheck.code);
            return;
        }

        auto typeValue = extractTypeFromPath(precheck.path);
        auto maybeType = parseBlockType(typeValue);
        if (!maybeType.found) {
            res.writeJsonBody(errorResponse("unknown type", 400), 400);
            return;
        }

        auto tenantId = precheck.tenantId;
        auto items = usecase.listBlocks(tenantId).map!(item => item.toJson()).array.toJson;
        auto outJson = successResponse("Technology blocks by type listed", 200, Json.emptyObject
            .set("type", typeValue)
            .set("count", items.length)
            .set("items", items));

        res.writeJsonBody(outJson, 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto block = usecase.getBlock(precheck.tenantId, TechnologyBlockId(precheck .id));
        if (block.id.value.length == 0)
            return errorResponse("Technology block not found", 404);

        return successResponse("Technology block retrieved", 200, block.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        auto request = CreateTechnologyBlockRequest();
        request.tenantId = tenantId;
        request.title = data.getString("title", "");
        request.description = data.getString("description", "");
        request.owner = data.getString("owner", "");
        request.lifecycleState = data.getString("lifecycleState", "");
        request.status = data.getString("status", "");
        request.versionLabel = data.getString("versionLabel", "");
        request.tags = readTags(data);

        auto result = usecase.createBlock(request);
        if (result.hasError())
            return errorResponse(result.message, 400);

        return successResponse("Technology block created", 201, Json.emptyObject.set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TechnologyBlockId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid block ID", 400);
        
        auto data = precheck.data;
        auto request = UpdateTechnologyBlockRequest();
        request.tenantId = tenantId;
        request.blockId = id;
        request.title = data.getString("title", "");
        request.description = data.getString("description", "");
        request.owner = data.getString("owner", "");
        request.lifecycleState = data.getString("lifecycleState", "");
        request.status = data.getString("status", "");
        request.versionLabel = data.getString("versionLabel", "");
        request.tags = readTags(data);

        auto result = usecase.updateBlock(request);
        if (result.hasError())
            return errorResponse(result.message, 404);

        return successResponse("Technology block updated", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto result = usecase.deleteBlock(precheck.tenantId, TechnologyBlockId(precheck.id));
        if (result.hasError())
            return errorResponse(result.message, 404);

        return successResponse("Technology block deleted", 200, Json.emptyObject.set("id", result.id));
    }

    private struct ParseResult {
        bool found;
        BuildingBlockType value;
    }

    private ParseResult parseBlockType(string input) {
        auto normalized = input.toLower();
        switch (normalized) {
            case "architecture": return ParseResult(true, BuildingBlockType.architecture);
            case "solution": return ParseResult(true, BuildingBlockType.solution);
            case "data": return ParseResult(true, BuildingBlockType.data);
            case "business": return ParseResult(true, BuildingBlockType.business);
            case "technology": return ParseResult(true, BuildingBlockType.technology);
            default: return ParseResult(false, BuildingBlockType.architecture);
        }
    }

    private string[] readTags(Json data) {
        string[] tags;
        if (!data.hasKey("tags") || !data["tags"].isArray)
            return tags;

        foreach (index; 0 .. data["tags"].length) {
            auto item = data["tags"][index];
            if (item.type == Json.Type.string)
                tags ~= item.get!string;
        }
        return tags;
    }

    private string extractTypeFromPath(string path) {
        auto marker = "/api/v1/building-blocks/types/";
        if (path.length <= marker.length)
            return "";
        return path[marker.length .. $];
    }
}
