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
  Task findById(TaskId id, SpaceId spaceId);
  Task[] findBySpace(SpaceId spaceId);
  Task[] findByStatus(TaskStatus status, SpaceId spaceId);
  Task[] findByType(TaskType type, SpaceId spaceId);
  void save(Task t);
  void update(Task t);
  void remove(TaskId id, SpaceId spaceId);
  size_t countBySpace(SpaceId spaceId);
}
