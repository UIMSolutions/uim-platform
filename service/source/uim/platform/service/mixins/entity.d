module uim.platform.service.mixins.entity;

import uim.platform.service;

mixin(ShowModule!());
@safe:

mixin template TenantEntity(TId) {
    TenantId tenantId; // required for multi-tenancy support
    TId id; // unique identifier for the entity
    UserId createdBy; // user who created the entity
    long createdAt; // timestamp of when the entity was created
    UserId updatedBy; // user who last updated the entity
    long updatedAt; // timestamp of when the entity was last updated

    // Helper method to check if the entity is new (i.e. has no ID assigned yet)
    bool isNull() const {
        return id.isEmpty;
    }

    // Call this method when creating a new entity to initialize ID, tenantId, and timestamps
    void createEntity(TenantId tenantId) {
        id = randomUUID();
        this.tenantId = tenantId;
        createdAt = Clock.currStdTime();
        updatedAt = createdAt;
    }

    // Call this method when updating an existing entity to update timestamps
    void updateEntity(TenantId newTenantId, TId newId) {
        id = newId;
        tenantId = newTenantId;
        updatedAt = Clock.currStdTime();
    }

    // Convert the entity to a JSON object, excluding internal fields like createdBy/createdAt
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
