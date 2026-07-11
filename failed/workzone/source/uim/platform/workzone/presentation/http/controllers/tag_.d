module uim.platform.workzone.presentation.http.controllers.tag_;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class TagController : ManageHttpController {
  private ManageTagsUseCase useCase;

  this(ManageTagsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    return super.createHandler(req);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    return super.listHandler(req);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    return super.getHandler(req);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    return super.updateHandler(req);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    return super.deleteHandler(req);
  }
}
