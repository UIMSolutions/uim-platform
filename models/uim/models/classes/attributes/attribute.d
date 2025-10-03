module uim.models.classes.attributes.attribute;

mixin(Version!"test_uim_models");

import uim.models;
@safe:

class DAttribute : UIMObject, IAttribute {
    mixin(AttributeThis!());
    this(DAttributeBuilder builder) {
        this();    
        // TODO
    }

    override bool initialize(Json[string] initData = null) {
        if (!super.initialize(initData)) {
            return false;
        }

        return true;
    }

    // #region dataFormats
    // Data type of the attribute. 
    mixin(TProperty!("string[]", "dataFormats"));
    bool hasDataFormat(string checkName) {
        return dataFormats.any!(dataFormat => dataFormat == checkName);
    }

    void addDataFormats(string[] formatNames) {
        formatNames.each!(formatName => addDataFormat(formatName));
    }

    void addDataFormat(string formatName) {
        if (!hasDataFormat(formatName)) {
            _dataFormats ~= formatName;
        }
    }
    // #endregion dataFormats

    mixin(TProperty!("UUID", "id"));
    mixin(TProperty!("string", "display"));
    mixin(TProperty!("string", "registerPath"));
    mixin(TProperty!("bool", "isNullable"));
    mixin(TProperty!("STRINGAA", "descriptions"));
    mixin(TProperty!("string", "valueType")); // Select the data type of the property.")); // 
    mixin(TProperty!("string", "keyType")); // Select the data type of the property.")); // 
    mixin(TProperty!("string", "dataType_display")); // ")); // 
    mixin(TProperty!("long", "defaultValueLong")); // Shows the default value of the property for a whole number data type.")); // 
    mixin(TProperty!("string", "defaultValueString")); // Shows the default value of the property for a string data type.")); // 
    //mixin(TProperty!("string", "defaultValueDecimal")); // Shows the default value of the property for a decimal data type.")); // 
    mixin(TProperty!("string", "baseDynamicPropertyId")); // Shows the property in the product family that this property is being inherited from.")); // 
    mixin(TProperty!("string", "overwrittenDynamicPropertyId")); // Shows the related overwritten property.")); // 
    mixin(TProperty!("string", "rootDynamicPropertyId")); // Shows the root property that this property is derived from.")); // 
    /* mixin(TProperty!("string", "minValueDecimal")); // Shows the minimum allowed value of the property for a decimal data type.")); // 
  mixin(TProperty!("string", "maxValueDecimal")); // Shows the maximum allowed value of the property for a decimal data type.")); //  */
    mixin(TProperty!("uint", "precision")); // Shows the allowed precision of the property for a whole number data type.")); // 
    mixin(TProperty!("string", "stateCode")); // Shows the state of the property.")); // 
    mixin(TProperty!("string", "stateCode_display")); // ")); // 
    mixin(TProperty!("string", "statusCode")); // Shows whether the property is active or inactive.")); // 
    mixin(TProperty!("string", "statusCode_display")); // ")); // 
    mixin(TProperty!("string", "regardingObjectId")); // Choose the product that the property is associated with.")); // 
    mixin(TProperty!("double", "defaultValueDouble")); // Shows the default value of the property for a double data type.")); // 
    mixin(TProperty!("double", "minValueDouble")); // Shows the minimum allowed value of the property for a double data type.")); // 
    mixin(TProperty!("double", "maxValueDouble")); // Shows the maximum allowed value of the property for a double data type.")); // 
    mixin(TProperty!("long", "minValueLong")); // Shows the minimum allowed value of the property for a whole number data type.")); // 
    mixin(TProperty!("long", "maxValueLong")); // Shows the maximum allowed value of the property for a whole number data type.")); // 
    mixin(TProperty!("bool", "isArray"));
    mixin(TProperty!("bool", "isDouble"));
    mixin(TProperty!("bool", "isString"));
    mixin(TProperty!("bool", "isJson"));
    mixin(TProperty!("bool", "isXML"));
    mixin(TProperty!("bool", "isAssociativeArray"));
    mixin(TProperty!("bool", "isReadOnly")); // Defines whether the attribute is read-only or if it can be edited.")); // 
    mixin(TProperty!("bool", "isHidden")); // Defines whether the attribute is hidden or shown.")); // 
    mixin(TProperty!("bool", "isRequired")); // Defines whether the attribute is mandatory.")); // 
    mixin(TProperty!("uint", "maxLengthString")); // Shows the maximum allowed length of the property for a string data type.")); // 
    mixin(TProperty!("string", "defaultValueOptionSet")); // Shows the default value of the property.

    mixin(TProperty!("UUID", "attribute")); // Super attribute.

    /* void attribute(UUID myId, size_t myMajor = 0, size_t myMinor = 0) { 
    _attribute = Attribute.id(myId).versionMajor(myMajor).versionMinor(myMinor);
     }

  void attribute(string myName, size_t myMajor = 0, size_t myMinor = 0) { 
    _attribute = Attribute.name(myName).versionMajor(myMajor).versionMinor(myMinor);
     }

  void attribute(DAttribute myAttclass) { 
    _attribute = myAttclass;     
     } */

    // Create a new attribute based on this attribute - using attribute name 
    /* auto createAttribute() {
    return createAttribute(_name); } */

    Json createValue() {
        return Json(null); // NullData;
    }

    /* override  */
    void fromJson(Json aJson) {
        if (aJson.isEmpty) {
            return;
        }
        /* super.fromJson(aJson); */

        foreach (keyvalue; aJson.byKeyValue) {
            auto k = keyvalue.key;
            auto v = keyvalue.value;
            switch (k) {
            case "attribute":
                this.attribute(UUID(v.get!string));
                break;
            case "isNullable":
                this.isNullable(v.get!bool);
                break;
            case "valueType":
                this.valueType(v.get!string);
                break;
            case "keyType":
                this.keyType(v.get!string);
                break;
            case "dataType_display":
                this.dataType_display(v.get!string);
                break;
            case "defaultValueLong":
                this.defaultValueLong(v.get!long);
                break;
            case "defaultValueString":
                this.defaultValueString(v.get!string);
                break;
            case "baseDynamicPropertyId":
                this.baseDynamicPropertyId(v.get!string);
                break;
            case "overwrittenDynamicPropertyId":
                this.overwrittenDynamicPropertyId(v.get!string);
                break;
            case "rootDynamicPropertyId":
                this.rootDynamicPropertyId(v.get!string);
                break;
            case "precision":
                this.precision(v.get!int);
                break;
            case "stateCode":
                this.stateCode(v.get!string);
                break;
            case "stateCode_display":
                this.stateCode_display(v.get!string);
                break;
            case "statusCode":
                this.statusCode(v.get!string);
                break;
            case "statusCode_display":
                this.statusCode_display(v.get!string);
                break;
            case "regardingObjectId":
                this.regardingObjectId(v.get!string);
                break;
            case "defaultValueDouble":
                this.defaultValueDouble(v.get!double);
                break;
            case "minValueDouble":
                this.minValueDouble(v.get!double);
                break;
            case "maxValueDouble":
                this.maxValueDouble(v.get!double);
                break;
            case "minValueLong":
                this.minValueLong(v.get!long);
                break;
            case "maxValueLong":
                this.maxValueLong(v.get!long);
                break;
            case "isReadOnly":
                this.isReadOnly(v.get!bool);
                break;
            case "isHidden":
                this.isHidden(v.get!bool);
                break;
            case "isRequired":
                this.isRequired(v.get!bool);
                break;
            case "isArray":
                this.isArray(v.get!bool);
                break;
            case "isAssociativeArray":
                this.isAssociativeArray(v.get!bool);
                break;
            case "maxLengthString":
                this.maxLengthString(v.get!int);
                break;
            case "defaultValueOptionSet":
                this.defaultValueOptionSet(v.get!string);
                break;
            default:
                break;
            }
        }
    }

    // Convert data to json (using vibe's funcs)
    override Json toJson(string[] showKeys = null, string[] hideKeys = null) {
        auto result = super.toJson;

        // Fields
        result.set("isNullable", this.isNullable);
        result.set("valueType", this.valueType);
        result.set("keyType", this.keyType);
        result.set("dataType_display", this.dataType_display);
        result.set("defaultValueLong", this.defaultValueLong);
        result.set("defaultValueString", this.defaultValueString);
        result.set("baseDynamicPropertyId", this.baseDynamicPropertyId);
        result.set("overwrittenDynamicPropertyId", this.overwrittenDynamicPropertyId);
        result.set("rootDynamicPropertyId", this.rootDynamicPropertyId);
        result.set("precision", this.precision);
        result.set("stateCode", this.stateCode);
        result.set("stateCode_display", this.stateCode_display);
        result.set("statusCode", this.statusCode);
        result.set("statusCode_display", this.statusCode_display);
        result.set("regardingObjectId", this.regardingObjectId);
        result.set("defaultValueDouble", this.defaultValueDouble);
        result.set("minValueDouble", this.minValueDouble);
        result.set("maxValueDouble", this.maxValueDouble);
        result.set("minValueLong", this.minValueLong);
        result.set("maxValueLong", this.maxValueLong);
        result.set("isReadOnly", this.isReadOnly);
        result.set("isHidden", this.isHidden);
        result.set("isRequired", this.isRequired);
        result.set("isArray", this.isArray);
        result.set("isAssociativeArray", this.isAssociativeArray);
        result.set("maxLengthString", this.maxLengthString);
        result.set("defaultValueOptionSet", this.defaultValueOptionSet);

        result.set("attribute", this.attribute.toString);

        return result;
    }

    unittest { /// TODO
    }
}


