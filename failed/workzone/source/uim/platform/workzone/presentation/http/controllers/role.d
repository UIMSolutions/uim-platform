module uim.platform.identity.authentication.presentation.http.role;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class RoleController : ManageHttpController {
  private ManageRolesUseCase useCase;

  this(ManageRolesUseCase useCase) {
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
