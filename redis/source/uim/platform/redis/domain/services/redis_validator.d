/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.services.redis_validator;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

struct RedisValidator {
    static bool isValidServiceInstance(const ServiceInstance e) {
        return e.name.length > 0 && !e.planId.isNull;
    }

    static bool isValidServiceBinding(const ServiceBinding e) {
        return !e.instanceId.isNull && e.appId.length > 0;
    }

    static bool isValidServicePlan(const ServicePlan e) {
        return e.name.length > 0 && e.memoryMb > 0;
    }

    static bool isValidConfiguration(const Configuration e) {
        return !e.instanceId.isNull;
    }

    static bool isValidCacheEntry(const CacheEntry e) {
        return !e.instanceId.isNull && e.key.length > 0;
    }

    static bool isValidMetric(const Metric e) {
        return !e.instanceId.isNull && e.timestamp_ > 0;
    }

    static bool isValidBackupPolicy(const BackupPolicy e) {
        return !e.instanceId.isNull && e.intervalHours > 0 && e.retentionDays > 0;
    }

    static bool isValidAccessControl(const AccessControl e) {
        return !e.instanceId.isNull && e.cidr.length > 0;
    }
}
