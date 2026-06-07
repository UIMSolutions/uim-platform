/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.enumerations;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

enum InstanceStatus : string {
    provisioning = "provisioning",
    active       = "active",
    failed       = "failed",
    updating     = "updating",
    deleting     = "deleting",
    deleted_     = "deleted"
}

enum BindingStatus : string {
    active  = "active",
    failed  = "failed",
    deleted_ = "deleted"
}

enum PlanTier : string {
    free     = "free",
    basic    = "basic",
    standard = "standard",
    premium  = "premium"
}

enum Hyperscaler : string {
    aws      = "aws",
    azure    = "azure",
    gcp      = "gcp",
    alicloud = "alicloud"
}

enum RedisVersion : string {
    v6  = "6.x",
    v7  = "7.x"
}

enum MaxMemoryPolicy : string {
    volatile_lru    = "volatile-lru",
    allkeys_lru     = "allkeys-lru",
    volatile_lfu    = "volatile-lfu",
    allkeys_lfu     = "allkeys-lfu",
    volatile_random = "volatile-random",
    allkeys_random  = "allkeys-random",
    volatile_ttl    = "volatile-ttl",
    noeviction      = "noeviction"
}

enum PersistenceMode : string {
    none = "none",
    rdb  = "rdb",
    aof  = "aof",
    both = "both"
}

enum CacheEntryType : string {
    string_     = "string",
    hash        = "hash",
    list        = "list",
    set         = "set",
    sorted_set  = "sorted_set",
    stream      = "stream",
    bitmap      = "bitmap"
}

enum BackupStatus : string {
    enabled  = "enabled",
    disabled_ = "disabled",
    running  = "running",
    failed   = "failed"
}

enum AccessControlStatus : string {
    active   = "active",
    inactive_ = "inactive"
}
