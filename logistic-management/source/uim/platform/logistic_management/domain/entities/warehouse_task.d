/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.entities.warehouse_task;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
/// A single executable warehouse task: pick, pack, put-away, transfer, or count.
struct WarehouseTask {
  mixin TenantEntity!(WarehouseTaskId);

  string taskNumber;
  WarehouseTaskType taskType = WarehouseTaskType.picking;
  WarehouseTaskStatus status = WarehouseTaskStatus.created;
  WarehouseOrderId warehouseOrderId;
  string warehouseId;
  string sourceStorageBin;
  string destinationStorageBin;
  string productId;
  string productDescription;
  double quantity;
  string unit;
  string assignedTo;
  long confirmedAt;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("taskNumber", taskNumber)
        .set("taskType", taskType.to!string)
        .set("status", status.to!string)
        .set("warehouseOrderId", warehouseOrderId.value)
        .set("warehouseId", warehouseId)
        .set("sourceStorageBin", sourceStorageBin)
        .set("destinationStorageBin", destinationStorageBin)
        .set("productId", productId)
        .set("productDescription", productDescription)
        .set("quantity", Json(quantity))
        .set("unit", unit)
        .set("assignedTo", assignedTo)
        .set("confirmedAt", Json(confirmedAt))
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
