/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.shipments;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ManageShipmentsUseCase {
private:
  ShipmentRepository _repo;

public:
  this(ShipmentRepository repo) {
    _repo = repo;
  }

  CommandResult createShipment(string tenantId, CreateShipmentRequest req) {
    if (req.shipmentNumber.length == 0)
      return CommandResult(false, "Shipment number is required");

    import std.conv : to;
    Shipment s;
    s.id = ShipmentId(generateId());
    s.tenantId = tenantId;
    s.shipmentNumber = req.shipmentNumber;
    s.description = req.description;
    s.freightOrderId = FreightOrderId(req.freightOrderId);
    s.warehouseId = req.warehouseId;
    s.partnerId = req.partnerId;
    s.partnerName = req.partnerName;
    s.trackingNumber = req.trackingNumber;
    s.plannedDate = req.plannedDate;
    s.status = ShipmentStatus.created;
    if (req.direction.length > 0) {
      try { s.direction = req.direction.to!LogisticsDirection; } catch (Exception) {}
    }
    s.createdAt = currentTimeMs();
    s.updatedAt = s.createdAt;
    _repo.save(s);
    return CommandResult(true, "", s.id.value);
  }

  CommandResult updateShipment(string tenantId, ShipmentId id, UpdateShipmentRequest req) {
    auto s = _repo.findById(tenantId, id);
    if (s == Shipment.init) return CommandResult(false, "Shipment not found");

    import std.conv : to;
    Shipment updated;
    updated.id = s.id;
    updated.tenantId = s.tenantId;
    updated.shipmentNumber = s.shipmentNumber;
    updated.description = req.description.length > 0 ? req.description : s.description;
    updated.direction = s.direction;
    updated.freightOrderId = s.freightOrderId;
    updated.warehouseId = s.warehouseId;
    updated.partnerId = s.partnerId;
    updated.partnerName = s.partnerName;
    updated.trackingNumber = req.trackingNumber.length > 0 ? req.trackingNumber : s.trackingNumber;
    updated.plannedDate = s.plannedDate;
    updated.actualDate = req.actualDate > 0 ? req.actualDate : s.actualDate;
    updated.createdAt = s.createdAt;
    updated.updatedAt = currentTimeMs();
    if (req.status.length > 0) {
      try { updated.status = req.status.to!ShipmentStatus; } catch (Exception) { updated.status = s.status; }
    } else {
      updated.status = s.status;
    }
    _repo.save(updated);
    return CommandResult(true, "", id.value);
  }

  CommandResult deleteShipment(string tenantId, ShipmentId id) {
    auto s = _repo.findById(tenantId, id);
    if (s == Shipment.init) return CommandResult(false, "Shipment not found");
    _repo.remove(tenantId, id);
    return CommandResult(true);
  }

  Shipment getShipment(string tenantId, ShipmentId id) {
    return _repo.findById(tenantId, id);
  }

  Shipment[] listShipments(string tenantId) {
    return _repo.findAll(tenantId);
  }

  Shipment[] listByFreightOrder(string tenantId, FreightOrderId foId) {
    return _repo.findByFreightOrder(tenantId, foId);
  }

  Shipment[] listByDirection(string tenantId, LogisticsDirection dir) {
    return _repo.findByDirection(tenantId, dir);
  }
}
