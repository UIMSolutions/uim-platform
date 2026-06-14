module uim.platform.service.mixins.domain;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

mixin template IdTemplate() {
  // this(string newValue) {
  //     this.value = newValue;
  // }

  // this(UUID newValue) {
  //     this.value = newValue.toString();
  // }

  //  bool opEquals(string anId) const {
  //      return this.value == anId;
  //  }

  void opAssign(UUID newValue) {
    this.value = newValue.toString();
  }

  void opAssign(string newValue) {
    this.value = newValue;
  }

  // bool opEquals(UUID aValue) {
  //   return this.value == aValue.toString();
  // }

  // bool opEquals(string aValue) {
  //   return this.value == aValue;
  // }

  bool isNull() const {
    return value.length == 0;
  }

  bool isEmpty() const {
    return value.length == 0;
  }

  string toString() const {
    return value;
  }

  Json toJson() const {
    return Json(value);
  }

  // static LicenseKey fromJson(Json src) {
  //       // Kontrollierte Prüfung des rohen JSON-Werts
  //       if (src.type != Json.Type.string) {
  //           throw new JSONException("Lizenzschlüssel muss ein String sein!");
  //       }

  //       string rawKey = src.get!string;

  //       // Kontrollierte Validierung / Transformation während des Mappings
  //       if (!rawKey.startsWith("KEY-")) {
  //           throw new JSONException("Ungültiges Format: Schlüssel muss mit 'KEY-' beginnen.");
  //       }

  //       // Rückgabe des fertig gemappten Structs
  //       return LicenseKey(rawKey);
  //   }
}
///
unittest {
  struct TestId {
    mixin IdTemplate;

    string value;

    this(string value) {
      this.value = value;
    }
  }

  TestId id = "test-id";
  assert(id.toString() == "test-id");
  assert(!id.isNull());
  assert(!id.isEmpty());
  // assert(id == "test-id");
  assert(id.toJson().getString() == "test-id");

  id = UUID("12345678-1234-5678-1234-567812345678");
  assert(id.toString() == "12345678-1234-5678-1234-567812345678");
  // assert(id == UUID("12345678-1234-5678-1234-567812345678"));

  id = "";
  assert(id.isNull());
  assert(id.isEmpty());
}
