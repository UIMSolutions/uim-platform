module uim.platform.logistic_management.application.usecases.manage.warehouse_orders;

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.warehouse_orders;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ManageWarehouseOrdersUseCase {
private:
  WarehouseOrderRepository _repo;
  WarehouseTaskRepository _tasks;

public:
  this(WarehouseOrderRepository repo, WarehouseTaskRepository tasks) {
    _repo = repo;
    _tasks = tasks;
  }

  CommandResult createWarehouseOrder(TenantId tenantId, CreateWarehouseOrderRequest req) {
    if (req.orderNumber.length == 0)
      return CommandResult(false, "Order number is required");

    WarehouseOrder wo;
    wo.id = WarehouseOrderId(generateId());
    wo.tenantId = precheck.tenantId;
    wo.orderNumber = req.orderNumber;
    wo.description = req.description;
    wo.deliveryId = DeliveryId(req.deliveryId);
    wo.warehouseId = req.warehouseId;
    wo.assignedTo = req.assignedTo;
    wo.dueAt = req.dueAt;
    wo.status = WarehouseOrderStatus.created;
    wo.createdAt = currentTimeMs();
    wo.updatedAt = wo.createdAt;
    _repo.save(wo);
    return CommandResult(true, "", wo.id.value);
  }

  CommandResult updateWarehouseOrder(TenantId tenantId, WarehouseOrderId id, UpdateWarehouseOrderRequest req) {
    auto wo = _repo.findById(tenantId, id);
    if (wo == WarehouseOrder.init) return CommandResult(false, "Warehouse order not found");

    
    WarehouseOrder updated;
    updated.id = wo.id;
    updated.tenantId = wo.tenantId;
    updated.orderNumber = wo.orderNumber;
    updated.description = req.description.length > 0 ? req.description : wo.description;
    updated.deliveryId = wo.deliveryId;
    updated.warehouseId = wo.warehouseId;
    updated.assignedTo = req.assignedTo.length > 0 ? req.assignedTo : wo.assignedTo;
    updated.dueAt = req.dueAt > 0 ? req.dueAt : wo.dueAt;
    updated.createdAt = wo.createdAt;
    updated.updatedAt = currentTimeMs();
    if (req.status.length > 0) {
      try { updated.status = req.status.to!WarehouseOrderStatus; } catch (Exception) { updated.status = wo.status; }
    } else {
      updated.status = wo.status;
    }
    _repo.save(updated);
    return CommandResult(true, "", id.value);
  }

  CommandResult deleteWarehouseOrder(TenantId tenantId, WarehouseOrderId id) {
    auto wo = _repo.findById(tenantId, id);
    if (wo == WarehouseOrder.init) return CommandResult(false, "Warehouse order not found");
    // Cascade: remove all tasks for this order
    _tasks.removeByWarehouseOrder(tenantId, id);
    _repo.remove(tenantId, id);
    return CommandResult(true);
  }

  WarehouseOrder getWarehouseOrder(TenantId tenantId, WarehouseOrderId id) {
    return _repo.findById(tenantId, id);
  }

  WarehouseOrder[] listWarehouseOrders(TenantId tenantId) {
    return _repo.findAll(tenantId);
  }

  WarehouseOrder[] listByDelivery(TenantId tenantId, DeliveryId deliveryId) {
    return _repo.findByDelivery(tenantId, deliveryId);
  }

  WarehouseOrder[] listByStatus(TenantId tenantId, WarehouseOrderStatus status) {
    return _repo.findByStatus(tenantId, status);
  }
}
