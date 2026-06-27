module uim.platform.service.mixins.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:
template TenantRepositoryTemplate(alias Repository, TEntity, TId) {
	this() {
		super();
	}

    this(ITenantStore!(TEntity, TId) store) {
        super(store);
    }
}