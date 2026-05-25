/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/**
 * File-based persistence (NDJSON) — stub for future implementation.
 *
 * Each repository writes one JSON object per line to a file under LOGMGMT_DATA_DIR:
 *   carriers.ndjson
 *   freight_orders.ndjson
 *   shipments.ndjson
 *   deliveries.ndjson
 *   warehouse_orders.ndjson
 *   warehouse_tasks.ndjson
 *
 * On startup the file is read line-by-line and deserialized into the in-memory store.
 * On every write (save/remove) the full file is re-written atomically via a temp file.
 *
 * Enable by setting the environment variable:
 *   LOGMGMT_DATA_DIR=/var/data/logistic-management
 */
module uim.platform.logistic_management.infrastructure.persistence.files;
public {
  // File persistence implementation goes here.
}
