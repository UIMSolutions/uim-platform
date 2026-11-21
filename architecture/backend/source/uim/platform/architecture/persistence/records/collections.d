/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections and the record schema version.
///
/// Records are flat JSON objects; times are std time numbers (hnsecs),
/// enumerations their string value. Unknown fields are ignored on read,
/// missing fields take their defaults — records stay readable across
/// versions.
module uim.platform.architecture.persistence.records.collections;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum Collections : string {
  blocks = "buildingBlocks",
  relationships = "relationships"
}

enum long recordSchemaVersion = 2;
