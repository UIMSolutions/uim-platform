module uim.platform.service.interfaces.entity;

import uim.platform.service;

mixin(ShowModule!());

@safe:

interface IUIMEntity {
  UUID id(); // Unique identifier for the entity
  void id(UUID id);

  string name(); // Name of the entity
  void name(string name);

  string description(); // Description of the entity
  void description(string description);

  Json toJson(); // Method to serialize the entity to JSON

  string toString(); // Method to get a string representation of the entity 
}
