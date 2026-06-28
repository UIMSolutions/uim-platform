/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.freight_orders;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
class ManageFreightOrdersUseCase {
private:
  FreightOrderRepository _repo;
  LogisticsPlanner _planner;

public:
  this(FreightOrderRepository repo, LogisticsPlanner planner) {
    _repo = repo;
    _planner = planner;
  }

  CommandResult createFreightOrder(TenantId tenantId, CreateFreightOrderRequest req) {
    if (req.orderNumber.length == 0)
      return CommandResult(false, "Order number is required");
    if (req.carrierId.length > 0) {
      CarrierId cid = CarrierId(req.carrierId);
      if (!_planner.isCarrierAvailable(tenantId, cid))
        return CommandResult(false, "Carrier is not available or does not exist");
    }

    FreightOrder fo;
    fo.id = FreightOrderId(generateId());
    fo.tenantId = tenantId;
    fo.orderNumber = req.orderNumber;
    fo.description = req.description;
    fo.originName = req.originName;
    fo.originAddress = req.originAddress;
    fo.destinationName = req.destinationName;
    fo.destinationAddress = req.destinationAddress;
    fo.carrierId = CarrierId(req.carrierId);
    fo.weightKg = req.weightKg;
    fo.volumeM3 = req.volumeM3;
    fo.plannedDepartureAt = req.plannedDepartureAt;
    fo.plannedArrivalAt = req.plannedArrivalAt;
    fo.status = FreightOrderStatus.draft;
    if (req.transportMode.length > 0) {
      try {
        fo.transportMode = req.transportMode.to!TransportMode;
      } catch (Exception) {
      }
    }
    fo.createdAt = currentTimeMs();
    fo.updatedAt = fo.createdAt;
    _repo.save(fo);
    return CommandResult(true, "", fo.id.value);
  }

  CommandResult updateFreightOrder(TenantId tenantId, FreightOrderId id, UpdateFreightOrderRequest req) {
    auto fo = _repo.find(tenantId, id);
    if (fo.isNull)
      return CommandResult(false, "Freight order not found");
    if (fo.status != FreightOrderStatus.draft && fo.status != FreightOrderStatus.planned)
      return CommandResult(false, "Cannot update a freight order that is in transit or completed");

    FreightOrder updated;
    updated.id = fo.id;
    updated.tenantId = fo.tenantId;
    updated.orderNumber = fo.orderNumber;
    updated.description = req.description.length > 0 ? req.description : fo.description;
    updated.originName = req.originName.length > 0 ? req.originName : fo.originName;
    updated.originAddress = req.originAddress.length > 0 ? req.originAddress : fo.originAddress;
    updated.destinationName = req.destinationName.length > 0 ? req.destinationName
      : fo.destinationName;
    updated.destinationAddress = req.destinationAddress.length > 0 ? req.destinationAddress
      : fo.destinationAddress;
    updated.carrierId = req.carrierId.length > 0 ? CarrierId(req.carrierId) : fo.carrierId;
    updated.weightKg = req.weightKg > 0 ? req.weightKg : fo.weightKg;
    updated.volumeM3 = req.volumeM3 > 0 ? req.volumeM3 : fo.volumeM3;
    updated.plannedDepartureAt = req.plannedDepartureAt > 0 ? req.plannedDepartureAt
      : fo.plannedDepartureAt;
    updated.plannedArrivalAt = req.plannedArrivalAt > 0 ? req.plannedArrivalAt : fo
      .plannedArrivalAt;
    updated.status = fo.status;
    updated.statusMessage = fo.statusMessage;
    updated.actualDepartureAt = fo.actualDepartureAt;
    updated.actualArrivalAt = fo.actualArrivalAt;
    updated.createdAt = fo.createdAt;
    updated.updatedAt = currentTimeMs();
    if (req.transportMode.length > 0) {
      try {
        updated.transportMode = req.transportMode.to!TransportMode;
      } catch (Exception) {
        updated.transportMode = fo.transportMode;
      }
    } else {
      updated.transportMode = fo.transportMode;
    }
    _repo.save(updated);
    return CommandResult(true, "", id.value);
  }

  CommandResult transitionFreightOrder(TenantId tenantId, FreightOrderId id, TransitionFreightOrderRequest req) {
    auto fo = _repo.find(tenantId, id);
    if (fo.isNull)
      return CommandResult(false, "Freight order not found");

    FreightOrderStatus newStatus;
    try {
      newStatus = req.status.to!FreightOrderStatus;
    } catch (Exception) {
      return CommandResult(false, "Invalid status value");
    }

    if (!_planner.canTransitionFreightOrder(fo.status, newStatus))
      return CommandResult(false, "Invalid status transition");

    FreightOrder updated;
    updated.id = fo.id;
    updated.tenantId = fo.tenantId;
    updated.orderNumber = fo.orderNumber;
    updated.description = fo.description;
    updated.originName = fo.originName;
    updated.originAddress = fo.originAddress;
    updated.destinationName = fo.destinationName;
    updated.destinationAddress = fo.destinationAddress;
    updated.carrierId = fo.carrierId;
    updated.transportMode = fo.transportMode;
    updated.weightKg = fo.weightKg;
    updated.volumeM3 = fo.volumeM3;
    updated.plannedDepartureAt = fo.plannedDepartureAt;
    updated.plannedArrivalAt = fo.plannedArrivalAt;
    updated.status = newStatus;
    updated.statusMessage = req.statusMessage.length > 0 ? req.statusMessage : fo.statusMessage;
    updated.actualDepartureAt = req.actualDepartureAt > 0 ? req.actualDepartureAt
      : fo.actualDepartureAt;
    updated.actualArrivalAt = req.actualArrivalAt > 0 ? req.actualArrivalAt : fo.actualArrivalAt;
    updated.createdAt = fo.createdAt;
    updated.updatedAt = currentTimeMs();
    _repo.save(updated);
    return CommandResult(true, "", id.value);
  }

  CommandResult deleteFreightOrder(TenantId tenantId, FreightOrderId id) {
    auto fo = _repo.find(tenantId, id);
    if (fo.isNull)
      return CommandResult(false, "Freight order not found");
    if (fo.status == FreightOrderStatus.inTransit)
      return CommandResult(false, "Cannot delete a freight order that is in transit");
    _repo.remove(tenantId, id);
    return CommandResult(true);
  }

  FreightOrder getFreightOrder(TenantId tenantId, FreightOrderId id) {
    return _repo.find(tenantId, id);
  }

  FreightOrder[] listFreightOrders(TenantId tenantId) {
    return _repo.findAll(tenantId);
  }

  FreightOrder[] listByStatus(TenantId tenantId, FreightOrderStatus status) {
    return _repo.findByStatus(tenantId, status);
  }

  FreightOrder[] listByCarrier(TenantId tenantId, CarrierId carrierId) {
    return _repo.findByCarrier(tenantId, carrierId);
  }
}
