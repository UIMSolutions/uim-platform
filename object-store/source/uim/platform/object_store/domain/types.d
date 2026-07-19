/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
// --- ID type aliases ---
struct BucketId {
    mixin(IdTemplate);
}
struct StorageObjectId {
    mixin(IdTemplate);
}
struct ObjectVersionId {
    mixin(IdTemplate);
}
struct AccessPolicyId {
    mixin(IdTemplate);
}
struct LifecycleRuleId {
    mixin(IdTemplate);
}
struct CorsRuleId {
    mixin(IdTemplate);
}


