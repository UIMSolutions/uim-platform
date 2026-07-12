import std.stdio;

void main() {
    writeln("Hello, World!");
}

unittest {
    import std.testing;
    static assert(1 + 1 == 2);
}