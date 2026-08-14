module uim.platform.architecture.presentation.http.controllers.solution_block;

import std.array : array;
import std.conv : to;
import std.string : toLower;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

// class SolutionsBlockController : ManageHttpController {
//     private IManageSolutionBlocksUseCase usecase;

//     this(IManageSolutionBlocksUseCase usecase) {
//         this.usecase = usecase;
//     }

//     override void registerRoutes(URLRouter router) {
//         super.registerRoutes(router);
//         router.get("/api/v1/building-blocks", &handleList);
//         router.get("/api/v1/building-blocks/types/*", &handleListByType);
//         router.get("/api/v1/building-blocks/*", &handleGet);
//         router.post("/api/v1/building-blocks", &handleCreate);
//         router.put("/api/v1/building-blocks/*", &handleUpdate);
//         router.delete_("/api/v1/building-blocks/*", &handleDelete);
//     }

//     override protected Json listHandler(HTTPServerRequest req) {
//         auto pre = super.listHandler(req);
//         if (pre.hasError)
//             return pre;

//         auto tenantId = pre.tenantId;
//         auto items = usecase.listBlocks(tenantId).map!(item => item.toJson()).array;
//         auto itemsJson = items.toJson;
//         return successResponse("building blocks listed", 200, Json.emptyObject
//             .set("count", items.length)
//             .set("items", itemsJson));
//     }

//     private void handleListByType(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto pre = super.getHandler(req);
//         if (pre.hasError) {
//             res.writeJsonBody(pre, pre.code);
//             return;
//         }

//         auto typeValue = extractTypeFromPath(pre.path);
//         auto maybeType = parseBlockType(typeValue);
//         if (!maybeType.found) {
//             res.writeJsonBody(errorResponse("unknown type", 400), 400);
//             return;
//         }

//         auto items = usecase.listBlocksByType(pre.tenantId, maybeType.value).map!(item => item.toJson()).array;
//         auto itemsJson = items.toJson;
//         auto outJson = successResponse("building blocks by type listed", 200, Json.emptyObject
//             .set("type", typeValue)
//             .set("count", items.length)
//             .set("items", itemsJson));

//         res.writeJsonBody(outJson, 200);
//     }

//     override protected Json getHandler(HTTPServerRequest req) {
//         auto pre = super.getHandler(req);
//         if (pre.hasError)
//             return pre;

//         auto block = usecase.getBlock(pre.tenantId, BuildingBlockId(pre.id));
//         if (block.id.value.length == 0)
//             return errorResponse("building block not found", 404);

//         return successResponse("building block retrieved", 200, block.toJson());
//     }

//     override protected Json createHandler(HTTPServerRequest req) {
//         auto pre = super.createHandler(req);
//         if (pre.hasError)
//             return pre;

//         auto data = pre.data;
//         auto maybeType = parseBlockType(data.getString("type", ""));
//         if (!maybeType.found)
//             return errorResponse("type must be architecture|solution|data|business|technology", 400);

//         auto request = CreateBuildingBlockRequest();
//         request.tenantId = pre.tenantId;
//         request.blockType = maybeType.value;
//         request.name = data.getString("name", "");
//         request.description = data.getString("description", "");
//         request.owner = data.getString("owner", "");
//         request.lifecycleState = data.getString("lifecycleState", "");
//         request.status = data.getString("status", "");
//         request.versionLabel = data.getString("versionLabel", "");
//         request.tags = readTags(data);

//         auto result = usecase.createBlock(request);
//         if (result.hasError())
//             return errorResponse(result.message, 400);

//         return successResponse("building block created", 201, Json.emptyObject.set("id", result.id));
//     }

//     override protected Json updateHandler(HTTPServerRequest req) {
//         auto pre = super.updateHandler(req);
//         if (pre.hasError)
//             return pre;

//         auto data = pre.data;

//         auto request = UpdateBuildingBlockRequest();
//         request.tenantId = pre.tenantId;
//         request.blockId = BuildingBlockId(pre.id);
//         request.description = data.getString("description", "");
//         request.owner = data.getString("owner", "");
//         request.lifecycleState = data.getString("lifecycleState", "");
//         request.status = data.getString("status", "");
//         request.versionLabel = data.getString("versionLabel", "");
//         request.tags = readTags(data);

//         auto result = usecase.updateBlock(request);
//         if (result.hasError())
//             return errorResponse(result.message, 404);

//         return successResponse("building block updated", 200, Json.emptyObject.set("id", result.id));
//     }

//     override protected Json deleteHandler(HTTPServerRequest req) {
//         auto pre = super.deleteHandler(req);
//         if (pre.hasError)
//             return pre;

//         auto result = usecase.deleteBlock(pre.tenantId, BuildingBlockId(pre.id));
//         if (result.hasError())
//             return errorResponse(result.message, 404);

//         return successResponse("building block deleted", 200, Json.emptyObject.set("id", result.id));
//     }

//     private struct ParseResult {
//         bool found;
//         BuildingBlockType value;
//     }

//     private ParseResult parseBlockType(string input) {
//         auto normalized = input.toLower();
//         switch (normalized) {
//             case "architecture": return ParseResult(true, BuildingBlockType.architecture);
//             case "solution": return ParseResult(true, BuildingBlockType.solution);
//             case "data": return ParseResult(true, BuildingBlockType.data);
//             case "business": return ParseResult(true, BuildingBlockType.business);
//             case "technology": return ParseResult(true, BuildingBlockType.technology);
//             default: return ParseResult(false, BuildingBlockType.architecture);
//         }
//     }

//     private string[] readTags(Json data) {
//         string[] tags;
//         if (!data.hasKey("tags") || !data["tags"].isArray)
//             return tags;

//         foreach (index; 0 .. data["tags"].length) {
//             auto item = data["tags"][index];
//             if (item.type == Json.Type.string)
//                 tags ~= item.get!string;
//         }
//         return tags;
//     }

//     private string extractTypeFromPath(string path) {
//         auto marker = "/api/v1/building-blocks/types/";
//         if (path.length <= marker.length)
//             return "";
//         return path[marker.length .. $];
//     }
// }
