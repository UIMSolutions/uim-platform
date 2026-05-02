module uim.platform.service.domain.ports.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IIdRepository(TEntity, TId) : IPlatformRepository!(TEntity) {
  bool existsById(TId id);
  TEntity findById(TId id);
  void removeById(TId id);

  bool existsAllById(TId[] ids);
  TEntity[] findAllById(TId[] ids, bool onlyExisting = true);
  void removeAllById(TId[] ids);

  void save(TEntity item);
  void update(TEntity item);
  void remove(TEntity item);

  void updateAll(TEntity[] items);
  void saveAll(TEntity[] items);
  void removeAll(TEntity[] items);
}
