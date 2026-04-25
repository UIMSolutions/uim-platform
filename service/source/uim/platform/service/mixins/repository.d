module uim.platform.service.mixins.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

template TenantRepositoryTemplate(TEntity, TId) {
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
