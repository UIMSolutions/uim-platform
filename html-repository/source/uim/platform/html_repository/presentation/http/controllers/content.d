/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.content;
// import uim.platform.html_repository.application.usecases.manage.app_files;
// import uim.platform.html_repository.application.usecases.manage.content_cache;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;


import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:
class ContentController : ManageHttpController {
  private ManageAppFilesUseCase fileUc;
  private ManageContentCacheUseCase cacheUc;

  this(ManageAppFilesUseCase fileUc, ManageContentCacheUseCase cacheUc) {
    this.fileUc = fileUc;
    this.cacheUc = cacheUc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/content/*", &handleGet);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = AppFileId(precheck.id);
      if (id.isNull)
        return errorResponse("File ID is required", 400);

      auto entry = fileUc.getAppFile(tenantId, id);
      if (entry.isNull) 
      return errorResponse("Content not found", 404);
      
      // res.headers["Content-Type"] = entry.contentType;
      // res.writeBody(entry.data, 200);

      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("contentType", entry.contentType)
        .set("data", entry.data);

        return successResponse("Content retrieved successfully", 200, response);
  }
}
