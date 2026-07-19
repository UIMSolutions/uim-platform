/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.pipeline;
// import uim.platform.logging.application.usecases.manage.pipelines;


import uim.platform.logging;
mixin(ShowModule!());

@safe:

class PipelineController : ManageHttpController {
  protected ManagePipelinesUseCase usecase;

  this(ManagePipelinesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/pipelines", &handleCreate);
    router.get("/api/v1/pipelines", &handleList);
    router.get("/api/v1/pipelines/*", &handleGet);
    router.put("/api/v1/pipelines/*", &handleUpdate);
    router.delete_("/api/v1/pipelines/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreatePipelineRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.sourceType = data.getString("sourceType");
    r.format = data.getString("format");
    r.targetStreamId = data.getString("targetStreamId");
    r.createdBy = UserId(data.getString("createdBy"));

    foreach (pj; data.getArray("processors")) {
      ProcessorDTO p;
      p.type = pj.getString("type");
      p.name = pj.getString("name");
      p.config = pj.getString("config");
      p.order_ = pj.getInteger("order");
      r.processors ~= p;
    }

    auto result = usecase.createPipeline(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Pipeline created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto pipelines = usecase.listPipelines(tenantId);

    auto jarr = Json.emptyArray;
    foreach (p; pipelines) {
      jarr ~= Json.emptyObject
        .set("id", p.id)
        .set("name", p.name)
        .set("description", p.description)
        .set("isActive", p.isActive);
    }

    auto resp = Json.emptyObject
      .set("items", jarr)
      .set("totalCount", pipelines.length);

    return successResponse("Pipelines retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PipelineId(precheck.id);
    auto p = usecase.getPipeline(tenantId, id);
    if (p.isNull) 
      return errorResponse("Pipeline not found", 404);

    auto response = Json.emptyObject
      .set("id", p.id)
      .set("name", p.name)
      .set("description", p.description)
      .set("isActive", p.isActive)
      .set("targetStreamId", p.targetStreamId);

    return successResponse("Pipeline retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PipelineId(precheck.id);
    auto data = precheck.data;
    UpdatePipelineRequest r;
    r.pipelineId = id;
    r.description = data.getString("description");
    r.format = data.getString("format");
    r.targetStreamId = data.getString("targetStreamId");
    r.isActive = data.getBoolean("isActive", true);
    r.tenantId = tenantId;

    auto result = usecase.updatePipeline(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto response = Json.emptyObject.set("id", result.id);

    return successResponse("Pipeline updated successfully", "Updated", 200, response);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto pipelineId = PipelineId(precheck.id);

    usecase.deletePipeline(tenantId, pipelineId);
    auto response = Json.emptyObject
      .set("id", pipelineId);

    return successResponse("Pipeline deleted successfully", "Deleted", 200, response);
  }
}

unittest {
  import uim.platform.service.tests;

  @safe class PipelineControllerTest : ControllerTestBase {
    void runTests() {
      auto repo = new MemoryPipelineRepository();
      auto usecase = new ManagePipelinesUseCase(repo);
      auto controller = new PipelineController(usecase);
      auto tenantId = TenantId("test-tenant");

      // 1. Create
      Json createData = Json.emptyObject
        .set("name", "test-pipeline")
        .set("description", "A test pipeline")
        .set("sourceType", "custom")
        .set("format", "json")
        .set("targetStreamId", "stream-1")
        .set("createdBy", "user-1")
        .set("processors", Json.emptyArray);

      auto reqCreate = createMockRequest("POST", "/api/v1/pipelines", tenantId, createData);
      auto resCreate = controller.createHandler(reqCreate);
      assert(resCreate.getString("status") == "success");
      string pipelineId = resCreate["data"]["id"].get!string;

      // 2. List
      auto reqList = createMockRequest("GET", "/api/v1/pipelines", tenantId);
      auto resList = controller.listHandler(reqList);
      assert(resList.getString("status") == "success");
      assert(resList["data"]["totalCount"].get!int == 1);

      // 3. Get
      auto reqGet = createMockRequest("GET", "/api/v1/pipelines/" ~ pipelineId, tenantId);
      reqGet.params["id"] = pipelineId;
      auto resGet = controller.getHandler(reqGet);
      // assert(resGet.getString("status") == "success");
      // assert(resGet["data"]["name"].get!string == "test-pipeline");

      // 4. Update
      Json updateData = Json.emptyObject
        .set("description", "Updated description")
        .set("isActive", false);
      auto reqUpdate = createMockRequest("PUT", "/api/v1/pipelines/" ~ pipelineId, tenantId, updateData);
      reqUpdate.params["id"] = pipelineId;
      // auto resUpdate = controller.updateHandler(reqUpdate);
      // assert(resUpdate.getString("status") == "success");

      // 5. Delete
      auto reqDelete = createMockRequest("DELETE", "/api/v1/pipelines/" ~ pipelineId, tenantId);
      reqDelete.params["id"] = pipelineId;
      auto resDelete = controller.deleteHandler(reqDelete);
      // assert(resDelete.getString("status") == "success");
    }
  }

  (new PipelineControllerTest).runTests();
}
