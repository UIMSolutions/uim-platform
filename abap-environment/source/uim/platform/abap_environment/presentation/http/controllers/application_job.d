/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.application_job;
// import uim.platform.abap_environment.application.usecases.manage.application_jobs;

// import uim.platform.abap_environment.domain.entities.application_job;


import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:

class ApplicationJobController : ManageHttpController {
  private ManageApplicationJobsUseCase usecase;

  this(ManageApplicationJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/application-jobs", &handleCreate);
    router.get("/api/v1/application-jobs", &handleList);
    router.get("/api/v1/application-jobs/*", &handleGet);
    router.put("/api/v1/application-jobs/*", &handleUpdate);
    router.post("/api/v1/application-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/application-jobs/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) 
      return precheck;
    

    auto data = precheck.data;
    auto tenantId = precheck.tenantId;
    auto systemId = SystemInstanceId(data.getString("systemInstanceId"));

    auto jobs = usecase.listApplicationJobs(tenantId, systemId);
    auto list = jobs.map!(job => job.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Application job list retrieved successfully", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) 
      return precheck;
    

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateApplicationJobRequest r;
    r.tenantId = tenantId;
    r.systemInstanceId = SystemInstanceId(data.getString("systemInstanceId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.jobTemplateName = data.getString("jobTemplateName");
    r.frequency = data.getString("frequency");
    r.scheduledAt = data.getLong("scheduledAt");
    r.cronExpression = data.getString("cronExpression");

    auto result = usecase.createApplicationJob(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application job created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) 
      return precheck;
    
    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);

    auto job = usecase.getApplicationJob(tenantId, id);
    if (job.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = job.toJson();
    return successResponse("Application job retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) 
      return precheck;
    

    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);
    auto data = req.json;

    UpdateApplicationJobRequest r;
    r.tenantId = tenantId;
    r.applicationJobId = id;
    r.description = data.getString("description");
    r.frequency = data.getString("frequency");
    r.scheduledAt = data.getLong("scheduledAt");
    r.cronExpression = data.getString("cronExpression");
    r.active = data.getBoolean("active", true);

    auto result = usecase.updateApplicationJob(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application job updated successfully", 200, responseData);
  }

  protected Json cancelHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application job ID", 400);

    auto result = usecase.cancelApplicationJob(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application job canceled successfully", 200, responseData);
  }

  mixin(HandleTemplate!("handleCancel", "cancelHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ApplicationJobId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application job ID", 400);

    auto result = usecase.deleteApplicationJob(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application job deleted successfully", 200, responseData);
  }
}
