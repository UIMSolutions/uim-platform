/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Base of the interactors: repositories, clock, events and audit stamping.
module uim.platform.architecture.application.services.support;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

abstract class ArchitectureInteractor {
  protected ArchitectureRepositories repos;
  protected IClock clock;
  protected IArchitectureEventPublisher events;

  this(ArchitectureRepositories repos, IClock clock, IArchitectureEventPublisher events) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
  }

  protected void emit(string type, TenantId t, string subject, Json data = Json.emptyObject) {
    events.publish(type, t, subject, data);
  }

  /// Audit fields of a new entity.
  protected void stamp(E)(ref E entity, UserId actor) {
    entity.createdAt = clock.now;
    entity.updatedAt = entity.createdAt;
    entity.createdBy = actor;
    entity.updatedBy = actor;
  }

  /// Audit fields of a changed entity.
  protected void touch(E)(ref E entity, UserId actor) {
    entity.updatedAt = clock.now;
    entity.updatedBy = actor;
  }

  protected BuildingBlock loadBlock(TenantId t, BuildingBlockId id) {
    auto b = repos.blocks.findById(t, id);
    if (b.isNull)
      throw ArchitectureException.notFound("Building block '" ~ id.value ~ "'");
    return b;
  }
}

/// Require a tenant on every request.
void requireTenant(TenantId t) {
  if (t.value.strip.length == 0)
    throw ArchitectureException.invalid("Tenant is required");
}

/// Case-insensitive substring match.
bool containsText(string haystack, string needle) {
  return needle.length == 0 || haystack.toLower.canFind(needle.toLower);
}
