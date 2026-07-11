module uim.platform.workzone.presentation.http.controllers.card;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class CardController : ManageHttpController {
  private ManageCardsUseCase useCase;

  this(ManageCardsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/cards", &handleList);
    router.get("/api/v1/cards/*", &handleGet);
    router.post("/api/v1/cards", &handleCreate);
    router.put("/api/v1/cards/*", &handleUpdate);
    router.delete_("/api/v1/cards/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateCardRequest r;
    r.tenantId = precheck.tenantId;
    r.title = data.getString("title");
    r.subtitle = data.getString("subtitle");
    r.description = data.getString("description");
    r.icon = data.getString("icon");
    r.cardType = toCardType(data.getString("cardType", "list"));

    auto result = useCase.createCard(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Card created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto resources = useCase.listCards(precheck.tenantId).map!(c => c.toJson()).array.toJson;

    return successResponse("Cards retrieved successfully", "Retrieved", 200,
      Json.emptyObject
        .set("count", resources.length)
        .set("resources", resources));

  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getCard(precheck.tenantId, CardId(precheck.id));
    if (entity.isNull)
      return errorResponse("Card not found", 404);

    return successResponse("Card retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateCardRequest r;
    r.id = CardId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.title = precheck.data.getString("title");
    r.subtitle = precheck.data.getString("subtitle");
    r.description = precheck.data.getString("description");
    r.icon = precheck.data.getString("icon");
    r.active = precheck.data.getLong("active", 1) != 0;

    auto result = useCase.updateCard(r);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Card updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteCard(precheck.tenantId, CardId(precheck.id));
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Card deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
  }
}
