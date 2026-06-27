module uim.platform.service.mixins.repositories.id;
import uim.platform.service;

mixin(ShowModule!());

@safe:

template IdRepositoryTemplate(alias Repository, TEntity, TId) {
    this() {
        super();
    }

    this(ITenantStore!(TEntity, TId) store) {
        super(store);
    }
}
