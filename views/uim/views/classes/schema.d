/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.schema;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

// Contains the schema information for Form instances.
class DSchema : UIMObject {
    this() {
        super( /* this.classname */ );
    }

    this(Json[string] initData) {
        super(initData);
    }

    this(string newName) {
        super(newName);
    }

    override bool initialize(Json[string] initData = null) {
        if (!super.initialize(initData)) {
            return false;
        }

        _fieldDefaults
            .set(["type", "length", "precision", "default"], Json(null));

        return true;
    }

    // The fields in this schema.
    protected Json[string] _fields = new Json[string];

    // The default values for fields.
    protected Json[string] _fieldDefaults = new Json[string];

    // #region fields
    // Removes a field to the schema.
    // Get the list of fields in the schema.
    string[] fieldNames() {
        return _fields.keys;
    }

    // Add multiple fields to the schema.
    DSchema addFields(Json[string] fields) {
        fields.byKeyValue
            .each!(field => addFields(field.key, field.value));

        return this;
    }

    // Adds a field to the schema.
    DSchema addFields(string key, Json attributes) {
        // _fields.set(key, attributes.merge(_fieldDefaults));

        return this;
    }

    // #region has
<<<<<<< HEAD
=======
    // Returns true if the map has value(s)
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
    mixin(HasMethods!("Fields", "Field", "string"));

    bool hasField(string fieldName) {
        return fieldName in _fields ? true : false;
    }
    unittest {
<<<<<<< HEAD
/*         assert(!hasField("a"), "Field a is missing");
        assert(!hasField("b"), "Field b is missing");
        assert(!hasField("c"), "Field c is missing"); */
    }
    // #endregion has
=======
        // TODO: Add unittest for hasField
    }
    // #region has
>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200

    // Get the type of the named field.
    string fieldType(string key) {
        return hasField(key)
            ? field(key).getString("type") : null;
    }

    // Get the type of the named field.
    string fieldDefault(string fieldName) {
        auto foundField = field(fieldName);
        return foundField.isNull
            ? null
            : foundField.getString("default");
    }

    // Get the attributes for a given field.
    Json field(string fieldName) {
        return _fields.get(fieldName, Json(null));
    }

    DSchema removeField(string fieldName) {
        _fields.removeKey(fieldName);
        return this;
    }
    // #endregion fields

    // Get the printable version of this object
    override Json[string] debugInfo(string[] showKeys = null, string[] hideKeys = null) {
        auto info = super.debugInfo(showKeys, hideKeys);
        info.set("_fields", Json(_fields));
        return info;
    }
}

auto Schema() {
    return new DSchema;
}

unittest {
    /* STRINGAA[string] fields;
    fields.set("a", [
            "type": Json(null),
            "length": Json(null),
            "precision": Json(null),
            "default": Json(null),
        ]);

    fields.set("b", [
            "type": Json(null),
            "length": Json(null),
            "default": Json(null),
        ]);

    fields.set("c", [
            "type": Json(null),
            "length": Json(null),
            "default": Json(null),
        ]);

    auto schema = Schema.addFields(fields);
    assert(schema.hasField("a"), "Field a is missing");
    assert(schema.hasAnyFields(["a", "b", "c"]), "Fields a, b, c are missing");
    assert(!schema.hasAnyFields(["x", "y", "z"]), "Fields a, b, c are missing");
    assert(schema.hasAllFields(["a", "b", "c"]), "Field a, b or c are missing");
    assert(!schema.hasAllFields(["a", "b", "c", "d"]), "Field a, b or c are missing");

    schema.removeField("b");
    assert(schema.hasField("a"), "Field a is missing");
    assert(!schema.hasField("b"), "Field b still exists");
    assert(schema.hasAnyFields(["a", "b", "c"]), "Fields a, b, c are missing");
    assert(!schema.hasAnyFields(["x", "y", "z"]), "Fields a, b, c are missing");
    assert(schema.hasAllFields(["a", "c"]), "Field a or c are missing");
    assert(!schema.hasAllFields(["a", "b", "c"]), "Field a, b or c are missing"); */
}
