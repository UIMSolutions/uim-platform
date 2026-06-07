/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.presentation.http.controllers.carrier;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
class CarrierController : ManageHttpController {
private:
  ManageCarriersUseCase _useCase;

public:
  this(ManageCarriersUseCase useCase) {
    super("/api/v1/carriers");
    _useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get(basePath, &listHandler);
    router.post(basePath, &createHandler);
    router.get(basePath ~ "/*", &getHandler);
    router.put(basePath ~ "/*", &updateHandler);
    router.delete_(basePath ~ "/*", &deleteHandler);
  }

protected:
  override Json listHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto carriers = _useCase.listCarriers(tenantId);
    import std.algorithm : map;
    import std.array : array;
    return jsonArray(carriers.map!(c => c.toJson).array);
  }

  override Json createHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto body_ = req.json;
    CreateCarrierRequest dto;
    dto.name = jsonStr(body_, "name");
    dto.description = jsonStr(body_, "description");
    dto.contactEmail = jsonStr(body_, "contactEmail");
    dto.contactPhone = jsonStr(body_, "contactPhone");
    dto.addressStreet = jsonStr(body_, "addressStreet");
    dto.addressCity = jsonStr(body_, "addressCity");
    dto.addressCountry = jsonStr(body_, "addressCountry");
    dto.taxId = jsonStr(body_, "taxId");
    auto modes = body_["supportedModes"];
    if (modes.isArray) {
      foreach (m; modes.byValue) dto.supportedModes ~= m.get!string;
    }
    auto result = _useCase.createCarrier(tenantId, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.created;
    return Json(["id": Json(result.id), "statusCode": Json(201)]);
  }

  override Json getHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractIdFromPath(req.requestPath.to!string));
    auto carrier = _useCase.getCarrier(tenantId, id);
    if (carrier == Carrier.init) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError("Carrier not found");
    }
    return carrier.toJson;
  }

  override Json updateHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractIdFromPath(req.requestPath.to!string));
    auto body_ = req.json;
    UpdateCarrierRequest dto;
    dto.description = jsonStr(body_, "description");
    dto.contactEmail = jsonStr(body_, "contactEmail");
    dto.contactPhone = jsonStr(body_, "contactPhone");
    dto.addressStreet = jsonStr(body_, "addressStreet");
    dto.addressCity = jsonStr(body_, "addressCity");
    dto.addressCountry = jsonStr(body_, "addressCountry");
    dto.status = jsonStr(body_, "status");
    auto modes = body_["supportedModes"];
    if (modes.isArray) {
      foreach (m; modes.byValue) dto.supportedModes ~= m.get!string;
    }
    auto result = _useCase.updateCarrier(tenantId, id, dto);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.badRequest;
      return writeError(result.message);
    }
    return Json(["id": Json(result.id), "statusCode": Json(200)]);
  }

  override Json deleteHandler(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = getTenantId(req);
    auto id = CarrierId(extractIdFromPath(req.requestPath.to!string));
    auto result = _useCase.deleteCarrier(tenantId, id);
    if (!result.success) {
      res.statusCode = cast(int) HTTPStatus.notFound;
      return writeError(result.message);
    }
    res.statusCode = cast(int) HTTPStatus.noContent;
    return Json(["statusCode": Json(204)]);
  }
}
