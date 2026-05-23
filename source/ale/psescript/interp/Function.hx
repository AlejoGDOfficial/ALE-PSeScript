package ale.psescript.interp;

import ale.psescript.compiler.Inst;

class Function
{
    public final arguments:Array<String>;
    public final defaults:Array<Null<Dynamic>>;
    public final block:Array<Inst>;
    public final scope:Scope;

    public function new(args:Array<String>, defs:Array<Null<Dynamic>>, insts:Array<Inst>, scop:Scope)
    {
        arguments = args;
        defaults = defs;
        block = insts;
        scope = scop;
    }
}