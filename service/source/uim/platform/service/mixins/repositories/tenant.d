module uim.platform.service.mixins.repositories.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:
template TenantRepositoryTemplate(alias Repository, TEntity, TId) {
	this() {
		super();
	}

	override bool initialize(Json initData = Json(null)) {
		if (!super.initialize(initData)) {
			return false;
		}

		return true;
	}
}