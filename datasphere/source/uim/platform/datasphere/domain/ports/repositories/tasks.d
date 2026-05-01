/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.tasks;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.task;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface TaskRepository {
  DSTask findById(SpaceId spaceId, TaskId id);
  DSTask[] findBySpace(SpaceId spaceId);
  DSTask[] findByStatus(SpaceId spaceId, TaskStatus status);
  DSTask[] findByType(SpaceId spaceId, TaskType type);
  void save(DSTask t);
  void update(DSTask t);
  void remove(SpaceId spaceId, TaskId id);
  size_t countBySpace(SpaceId spaceId);
}
