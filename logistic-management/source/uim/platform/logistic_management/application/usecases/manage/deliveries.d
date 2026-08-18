/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.deliveries;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ManageDeliveriesUseCase {
private:
  IDeliveryRepository _repo;
  IWarehouseOrderRepository _warehouseOrders;
  LogisticsPlanner _planner;

public:
  this(IDeliveryRepository repo, IWarehouseOrderRepository warehouseOrders, LogisticsPlanner planner) {
    _repo = repo;
    _warehouseOrders = warehouseOrders;
    _planner = planner;
  }

  UsecaseResult createDelivery(TenantId tenantId, CreateDeliveryRequest req) {
    if (req.deliveryNumber.length == 0)
      return UsecaseResult(false, "Delivery number is required");

    
    Delivery d;
    d.id = DeliveryId(generateId());
    d.tenantId = tenantId;
    d.deliveryNumber = req.deliveryNumber;
    d.description = req.description;
    d.shipmentId = ShipmentId(req.shipmentId);
    d.warehouseId = req.warehouseId;
    d.partnerId = req.partnerId;
    d.partnerName = req.partnerName;
    d.deliveryAddress = req.deliveryAddress;
    d.plannedDate = req.plannedDate;
    d.status = DeliveryStatus.created;
    if (req.direction.length > 0) {
      try { d.direction = req.direction.to!LogisticsDirection; } catch (Exception) {}
    }
    foreach (ir; req.items) {
      DeliveryItem item;
      item.itemNumber = ir.itemNumber;
      item.productId = ir.productId;
      item.productDescription = ir.productDescription;
      item.quantity = ir.quantity;
      item.unit = ir.unit;
      item.weightKg = ir.weightKg;
      item.volumeM3 = ir.volumeM3;
      d.items ~= item;
    }
    d.createdAt = currentTimestamp();
    d.updatedAt = d.createdAt;
    _repo.save(d);
    return UsecaseResult(true, "", d.id.value);
  }

  UsecaseResult updateDeliveryStatus(TenantId tenantId, DeliveryId id, UpdateDeliveryRequest req) {
    auto d = _repo.findById(tenantId, id);
    if (d.isNull) return UsecaseResult(false, "Delivery not found");

    
    DeliveryStatus newStatus;
    if (req.status.length > 0) {
      try { newStatus = req.status.to!DeliveryStatus; } catch (Exception) { return UsecaseResult(false, "Invalid status value"); }
      if (!_planner.canTransitionDelivery(d.status, newStatus))
        return UsecaseResult(false, "Invalid status transition for delivery");
    } else {
      newStatus = d.status;
    }

    Delivery updated;
    updated.id = d.id;
    updated.tenantId = d.tenantId;
    updated.deliveryNumber = d.deliveryNumber;
    updated.description = req.description.length > 0 ? req.description : d.description;
    updated.direction = d.direction;
    updated.shipmentId = d.shipmentId;
    updated.warehouseId = d.warehouseId;
    updated.partnerId = d.partnerId;
    updated.partnerName = d.partnerName;
    updated.deliveryAddress = req.deliveryAddress.length > 0 ? req.deliveryAddress : d.deliveryAddress;
    updated.items = d.items;
    updated.plannedDate = d.plannedDate;
    updated.actualDate = req.actualDate > 0 ? req.actualDate : d.actualDate;
    updated.status = newStatus;
    updated.createdAt = d.createdAt;
    updated.updatedAt = currentTimestamp();
    _repo.save(updated);
    return UsecaseResult(true, "", id.value);
  }

  UsecaseResult deleteDelivery(TenantId tenantId, DeliveryId id) {
    auto d = _repo.findById(tenantId, id);
    if (d.isNull) return UsecaseResult(false, "Delivery not found");
    // Cascade: remove warehouse orders
    _warehouseOrders.removeByDelivery(tenantId, id);
    _repo.remove(tenantId, id);
    return UsecaseResult(true);
  }

  Delivery getDelivery(TenantId tenantId, DeliveryId id) {
    return _repo.findById(tenantId, id);
  }

  Delivery[] listDeliveries(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  Delivery[] listByShipment(TenantId tenantId, ShipmentId shipmentId) {
    return _repo.findByShipment(tenantId, shipmentId);
  }

  Delivery[] listByDirection(TenantId tenantId, LogisticsDirection dir) {
    return _repo.findByDirection(tenantId, dir);
  }
}
