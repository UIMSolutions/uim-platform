/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/**
 * MongoDB persistence — stub for future implementation.
 *
 * Database : logistic_management
 * Collections:
 *   carriers
 *   freight_orders
 *   shipments
 *   deliveries
 *   warehouse_orders
 *   warehouse_tasks
 *
 * Connection string is read from the environment variable:
 *   LOGMGMT_MONGO_URI=mongodb://localhost:27017/logistic_management
 *
 * All documents include a `tenantId` field and are indexed on (tenantId, _id).
 * Domain IDs are stored as the MongoDB `_id` field (string).
 *
 * Requires vibe-d/mongodb or mongo-d driver as an additional dependency.
 */
module uim.platform.logistic_management.infrastructure.persistence.mongo;
public {
  // MongoDB persistence implementation goes here.
}
