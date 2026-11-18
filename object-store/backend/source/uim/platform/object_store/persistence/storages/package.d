/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Technical storage drivers (snapshots, blobs).
module uim.platform.object_store.persistence.storages;

public {
  import uim.platform.object_store.persistence.storages.blobs;
  import uim.platform.object_store.persistence.storages.json_file;
  import uim.platform.object_store.persistence.storages.memory;
  import uim.platform.object_store.persistence.storages.snapshot_store;
}
