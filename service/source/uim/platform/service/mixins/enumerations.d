module uim.platform.service.mixins.enumerations;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

// string toEnum(string s, string enumName) {
//     final string fullName = "uim.platform.service.mixins.enumerations." ~ enumName;
//     final TypeInfoEnum* enumInfo = cast(TypeInfoEnum*)TypeInfo.getTypeInfoByName(fullName);
//     if (enumInfo is null) {
//         throw new Exception("Enumeration type not found: " ~ fullName);
//     }
//     foreach (i, member; enumInfo.members) {
//         if (member.toLower() == s.toLower()) {
//             return member;
//         }
//     }
//     throw new Exception("Invalid value '" ~ s ~ "' for enumeration " ~ fullName);
// }

string toEnumSwitch(string enumType, string defaultValue, bool ignoreCase = true) {
    return `
    switch (`
        ~ (ignoreCase ? "value.toLower()" : "value") ~ `) {
        static foreach (member; __traits(allMembers, `
        ~ enumType ~ `)) {
    case `
        ~ (ignoreCase ? "member.toLower()" : "member") ~ `:
            return __traits(getMember, `
        ~ enumType ~ `, member);
        }
    default:
        return `
        ~ enumType ~ `.` ~ defaultValue ~ `;
    }`;
}
///
unittest {
    enum TestEnum {
        one,
        two,
        three
    }

    // Example usage of toEnumSwitch mixin
    {
        TestEnum toTestEnum(string value) {
            mixin(toEnumSwitch("TestEnum", "one"));
        }

        assert(toTestEnum("two") == TestEnum.two);
        assert(toTestEnum("TWO") == TestEnum.two);
        assert(toTestEnum("FOUR") == TestEnum.one);
    }

    // Case-sensitive example
    {
        TestEnum toTestEnum(string value) {
            mixin(toEnumSwitch("TestEnum", "one", false));
        }

        assert(toTestEnum("two") == TestEnum.two);
        assert(toTestEnum("TWO") == TestEnum.one);
        assert(toTestEnum("FOUR") == TestEnum.one);
    }
}
