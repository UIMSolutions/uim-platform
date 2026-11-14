/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Low level storage port: the tenant partitioned JSON document store of uim-platform:service (memory or file).
module uim.platform.task_center.ports.storages.documents;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

public import uim.platform.service.ports.storages.documents : IDocumentStore;
