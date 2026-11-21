/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port: manage ArchiMate relationships.
module uim.platform.architecture.ports.usecases.relationships;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageRelationships {
  Relationship createRelationship(CreateRelationshipRequest r);
  /// Only the description can change (type and ends are the identity).
  Relationship updateRelationship(UpdateRelationshipRequest r);
  Relationship getRelationship(TenantId t, RelationshipId id);
  Relationship[] listRelationships(TenantId t, RelationshipFilter filter = RelationshipFilter.init);
  void deleteRelationship(TenantId t, RelationshipId id, UserId actor);
}
