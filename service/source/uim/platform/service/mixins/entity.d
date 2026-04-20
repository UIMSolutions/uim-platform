module uim.platform.service.mixins.entity;

import uim.platform.service;

mixin(ShowModule!());
@safe:

mixin template TenantEntity(TId) {
    TenantId tenantId;
    TId id;
    UserId createdBy;
    long createdAt;
    UserId updatedBy;
    long updatedAt;

    bool isNull() const {
        return id.isEmpty;
    }

    void createEntity(TenantId tenantId) {
        id = randomUUID();
        this.tenantId = tenantId;
        createdAt = Clock.currStdTime();
        updatedAt = createdAt;
    }

    void updateEntity(TenantId tenantId, TId id) {
        id = id;
        this.tenantId = tenantId;
    }

    Json entityToJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("createdBy", createdBy)
            .set("createdAt", createdAt)
            .set("updatedBy", updatedBy)
            .set("updatedAt", updatedAt);
    }
}
