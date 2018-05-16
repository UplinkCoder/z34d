version (Dynamic)
{
    import z3h = z3h;
    import core.sys.posix.dlfcn;
    import core.stdc.stdio : puts;
    mixin(() {
            string vars;
            string loader = `static this () {
        auto handle = dlopen("libz3.so", RTLD_NOW);
        if (!handle) puts(dlerror());
        `;
            foreach(m;__traits(allMembers, z3h))
            {
                static if (is(typeof(mixin("z3h." ~ m)) == function))
                {
                    auto type = "typeof(z3h." ~ m ~ ")* ";
                    vars ~= type ~ m ~ ";\n";
                    loader ~= m ~ " = (cast(" ~ type ~ ") " ~
                        ` dlsym(handle, "` ~ m ~ `"));` ~ "\n";
                    loader ~= "if (" ~ m ~ " is null) puts(dlerror());\n";
                }
            }
            return vars ~ loader ~ "}";
        } ());
}
else 
public import z3h;
