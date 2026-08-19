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
    auto data = req.json;
    CreateCarrierRequest dto;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.contactEmail = data.getString("contactEmail");
    dto.contactPhone = data.getString("contactPhone");
    dto.addressStreet = data.getString("addressStreet");
    dto.addressCity = data.getString("addressCity");
    dto.addressCountry = data.getString("addressCountry");
    dto.taxId = data.getString("taxId");
    auto modes = data["supportedModes"];
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
    auto id = CarrierId(extractId(req.requestPath.to!string));
    auto carrier = _useCase.getCarrier(tenantId, id);
    if (carrier.isNull)
      return errorResponse("Carrier not found", cast(int) HTTPStatus.notFound);

    auto responseData = carrier.toJson;
    return successResponse("Carrier retrieved successfully", cast(int) HTTPStatus.ok, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractId(req.requestPath.to!string));
    auto data = req.json;
    UpdateCarrierRequest dto;
    dto.description = data.getString("description");
    dto.contactEmail = data.getString("contactEmail");
    dto.contactPhone = data.getString("contactPhone");
    dto.addressStreet = data.getString("addressStreet");
    dto.addressCity = data.getString("addressCity");
    dto.addressCountry = data.getString("addressCountry");
    dto.status = data.getString("status");
    auto modes = data["supportedModes"];
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
    auto id = CarrierId(extractId(req.requestPath.to!string));
    auto result = _useCase.deleteCarrier(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, cast(int) HTTPStatus.notFound);
    
    return successResponse(null, cast(int) HTTPStatus.noContent);
  }
}
