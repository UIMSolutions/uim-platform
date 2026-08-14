/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.carrier;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class CarrierController : ManageHttpController {
private:
  ManageCarriersUseCase _useCase;

public:
  this(ManageCarriersUseCase useCase) {
    super();
    _useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    string basePath = "/api/v1/carriers"; 
    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
  }

override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto carriers = _useCase.listCarriers(tenantId);
    import std.algorithm : map;
    
    return carriers.map!(c => c.toJson).array.toJson;
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateCarrierRequest dto;
    dto.name = body_.getString("name");
    dto.description = body_.getString("description");
    dto.contactEmail = body_.getString("contactEmail");
    dto.contactPhone = body_.getString("contactPhone");
    dto.addressStreet = body_.getString("addressStreet");
    dto.addressCity = body_.getString("addressCity");
    dto.addressCountry = body_.getString("addressCountry");
    dto.taxId = body_.getString("taxId");
    auto modes = body_["supportedModes"];
    if (modes.isArray) {
      foreach (m; modes.byValue) dto.supportedModes ~= m.get!string;
    }
    auto result = _useCase.createCarrier(tenantId, dto);
    if (result.hasError)
      return errorResponse(result.message, cast(int) HTTPStatus.badRequest);

    return successResponse("Carrier created successfully", cast(int) HTTPStatus.created);
  }
  //   res.statusCode = cast(int) HTTPStatus.created;
  //   return Json(["id": Json(result.id), "statusCode": Json(201)]);
  // }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractIdFromPath(req.requestPath.to!string));
    auto carrier = _useCase.getCarrier(tenantId, id);
    if (carrier.isNull)
      return errorResponse("Carrier not found", cast(int) HTTPStatus.notFound);

    auto responseData = carrier.toJson;
    return successResponse("Carrier retrieved successfully", cast(int) HTTPStatus.ok, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateCarrierRequest dto;
    dto.description = body_.getString("description");
    dto.contactEmail = body_.getString("contactEmail");
    dto.contactPhone = body_.getString("contactPhone");
    dto.addressStreet = body_.getString("addressStreet");
    dto.addressCity = body_.getString("addressCity");
    dto.addressCountry = body_.getString("addressCountry");
    dto.status = body_.getString("status");
    auto modes = body_["supportedModes"];
    if (modes.isArray) {
      foreach (m; modes.byValue) dto.supportedModes ~= m.get!string;
    }
    auto result = _useCase.updateCarrier(tenantId, id, dto);
    if (result.hasError)
      return errorResponse(result.message, cast(int) HTTPStatus.badRequest);

    return successResponse("Carrier updated successfully", cast(int) HTTPStatus.ok, Json(["id": Json(result.id)]));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractIdFromPath(req.requestPath.to!string));
    auto result = _useCase.deleteCarrier(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, cast(int) HTTPStatus.notFound);
    
    return successResponse(null, cast(int) HTTPStatus.noContent);
  }
}
