/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.services.logistics_planner;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
/**
 * Domain service responsible for logistics planning business rules:
 * - validating carrier assignments on freight orders
 * - determining whether a delivery can progress to the next status
 * - assigning warehouse tasks to orders
 */
class LogisticsPlanner {
private:
  CarrierRepository _carriers;

public:
  this(CarrierRepository carriers) {
    _carriers = carriers;
  }

  /// Check that the carrier exists and is active for the given tenant.
  bool isCarrierAvailable(string tenantId, CarrierId carrierId) {
    auto existing = _carriers.findById(tenantId, carrierId);
    if (existing == Carrier.init) return false;
    return existing.status == CarrierStatus.active;
  }

  /// Determine the next allowed status for a delivery transition.
  bool canTransitionDelivery(DeliveryStatus current, DeliveryStatus next) {
    final switch (current) {
      case DeliveryStatus.created:   return next == DeliveryStatus.picking;
      case DeliveryStatus.picking:   return next == DeliveryStatus.packed || next == DeliveryStatus.cancelled;
      case DeliveryStatus.packed:    return next == DeliveryStatus.shipped || next == DeliveryStatus.cancelled;
      case DeliveryStatus.shipped:   return next == DeliveryStatus.delivered;
      case DeliveryStatus.delivered: return false;
      case DeliveryStatus.cancelled: return false;
    }
  }

  /// Determine the next allowed status for a freight order.
  bool canTransitionFreightOrder(FreightOrderStatus current, FreightOrderStatus next) {
    final switch (current) {
      case FreightOrderStatus.draft:      return next == FreightOrderStatus.planned || next == FreightOrderStatus.cancelled;
      case FreightOrderStatus.planned:    return next == FreightOrderStatus.inTransit || next == FreightOrderStatus.cancelled;
      case FreightOrderStatus.inTransit:  return next == FreightOrderStatus.delivered;
      case FreightOrderStatus.delivered:  return false;
      case FreightOrderStatus.cancelled:  return false;
    }
  }

  /// Determine the next allowed status for a warehouse task.
  bool canTransitionTask(WarehouseTaskStatus current, WarehouseTaskStatus next) {
    final switch (current) {
      case WarehouseTaskStatus.created:    return next == WarehouseTaskStatus.queued || next == WarehouseTaskStatus.cancelled;
      case WarehouseTaskStatus.queued:     return next == WarehouseTaskStatus.inProgress || next == WarehouseTaskStatus.cancelled;
      case WarehouseTaskStatus.inProgress: return next == WarehouseTaskStatus.confirmed || next == WarehouseTaskStatus.cancelled;
      case WarehouseTaskStatus.confirmed:  return false;
      case WarehouseTaskStatus.cancelled:  return false;
    }
  }
}
