module uim.platform.service.domain.ports.repositories.id;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IIdRepository(TEntity, TId) {
  bool existsById(TId id);
  bool existsAllById(TId[] ids);
  
  TEntity findById(TId id);
  TEntity[] findAllById(TId[] ids);

  void removeById(TId id);
  void removeAllById(TId[] ids);

  void save(TEntity entity);
  void saveAll(TEntity[] entities);

  void update(TEntity entity);
  void updateAll(TEntity[] entities);

  void remove(TEntity entity);
  void removeAll(TEntity[] entities);
}
