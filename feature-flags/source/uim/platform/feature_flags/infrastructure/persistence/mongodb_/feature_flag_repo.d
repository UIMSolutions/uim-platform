/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.mongodb_.feature_flag_repo;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

/// MongoDB-backed feature flag repository.
/// Connect via vibe.d's MongoClient when the "vibe-d:mongo" sub-package is added to dub.sdl.
/// This implementation falls back to the in-memory backend until a real MongoDB connection
/// is configured, making the service deployable without a running MongoDB instance.
class MongoDbFeatureFlagRepository : FeatureFlagRepository {
    private MemoryFeatureFlagRepository fallback;
    private string connectionUri;
    private string dbName;

    this(string connectionUri, string dbName) {
        this.connectionUri = connectionUri;
        this.dbName        = dbName;
        this.fallback      = new MemoryFeatureFlagRepository();
        // TODO: connect(connectionUri) and wire mongo collection
        // auto client = connectMongoDB(connectionUri);
        // this.collection = client.getDatabase(dbName)["feature_flags"];
    }

    void save(FeatureFlag flag_) {
        // TODO: collection.insert(toBson(flag_));
        fallback.save(flag_);
    }

    void update(FeatureFlag flag_) {
        // TODO: collection.update(["_id": flag_.id.value], toBson(flag_));
        fallback.update(flag_);
    }

    void remove(FeatureFlag flag_) {
        // TODO: collection.remove(["_id": flag_.id.value]);
        fallback.remove(flag_);
    }

    FeatureFlag findById(TenantId tenantId, FlagId id) {
        // TODO: return fromBson(collection.findOne(["tenantId": tenantId, "_id": id.value]));
        return fallback.find(tenantId, id);
    }

    FeatureFlag findByName(TenantId tenantId, ServiceInstanceId instanceId, string name) {
        return fallback.findByName(tenantId, instanceId, name);
    }

    FeatureFlag[] findByTenant(TenantId tenantId) {
        return fallback.find(tenantId);
    }

    FeatureFlag[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return fallback.findByInstance(tenantId, instanceId);
    }

    FeatureFlag[] findByState(TenantId tenantId, ServiceInstanceId instanceId, FlagState state_) {
        return fallback.findByState(tenantId, instanceId, state_);
    }

    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return fallback.countByInstance(tenantId, instanceId);
    }
}
