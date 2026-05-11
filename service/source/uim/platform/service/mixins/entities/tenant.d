module uim.platform.service.mixins.entities.tenant;

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

  void initEntity() {
    this.id = randomUUID();
    this.createdAt = Clock.currStdTime();
    this.updatedAt = createdAt;
  }

  void initEntity(TenantId tenantId) {
    this.id = randomUUID();
    this.tenantId = tenantId;
    this.createdAt = Clock.currStdTime();
    this.updatedAt = createdAt;
  }

  void initEntity(TenantId tenantId, UserId byUser) {
    initEntity(tenantId);
    this.id = randomUUID();
    this.createdBy = byUser;
    this.updatedBy = this.createdBy;
  }

  void initEntity(TenantId tenantId, TId id) {
    initEntity(tenantId);
    this.id = id;
  }

  void initEntity(TenantId tenantId, TId id, UserId byUser) {
    initEntity(tenantId, id);
    this.createdBy = byUser;
    this.updatedBy = this.createdBy;
  }

  // Call this method when creating a new entity to initialize ID, tenantId, and timestamps
  void createEntity(TenantId tenantId) {
    id = randomUUID();
    this.tenantId = tenantId;
    createdAt = Clock.currStdTime();
    updatedAt = createdAt;
  }

  // Call this method when updating an existing entity to update timestamps
  void updatedEntity() {
    updatedAt = Clock.currStdTime();
  }

  void updateEntity(TenantId newTenantId, TId newId) {
    id = newId;
    tenantId = newTenantId;
    updatedAt = Clock.currStdTime();
  }

  void updatedEntity(UserId byUser) {
    updateEntity();
    updatedBy = byUser;
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
