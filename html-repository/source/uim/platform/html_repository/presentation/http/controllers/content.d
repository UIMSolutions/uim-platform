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

mixin(ShowModule!());

@safe:
class ContentController : ManageController {
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto path = AppFileprecheck.id);
      if (path.length == 0) {
        writeError(res, 404, "Content not found");
        return;
      }
      auto entry = fileUc.getAppFile(path, tenantId);
      if (entry.isNull) {
        writeError(res, 404, "Content not found");
        return;
      }
      res.headers["Content-Type"] = entry.contentType;
      res.writeBody(entry.data, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
