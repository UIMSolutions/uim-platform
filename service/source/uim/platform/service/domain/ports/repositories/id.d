module uim.platform.service.domain.ports.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IIdRepository(TEntity, TId) {
  bool existsById(TId id);
  TEntity findById(TId id);

  void save(TEntity item);
  void update(TEntity item);
  void remove(TId id);
}
