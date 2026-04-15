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
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}
struct ObjectId {
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}
struct ObjectVersionId {
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}
struct AccessPolicyId {
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}
struct LifecycleRuleId {
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}
struct CorsRuleId {
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}
struct ServiceBindingId {
    string value;
  
    this(string value) {
        this.value = value;
    }
  
    mixin DomainId;
}

