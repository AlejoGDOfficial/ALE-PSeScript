package ale.psescript.interp;

import ale.psescript.compiler.Inst;

import haxe.Log;

class Interp
{
    public final name:String;

    public var scope:Scope;

    public function new(name:String)
    {
        this.name = name;

        scope = new Scope();

        scope.define('trace', (t) -> {
            Log.trace(name + ': ' + t);
        });
    }

    var stack:Array<Dynamic> = [];

    inline function push(val:Dynamic)
        stack.push(val);

    inline function pop():Dynamic
        return stack.pop();

    public function execute(instructions:Array<Inst>):Dynamic
    {
        for (inst in instructions)
        {
            switch (inst)
            {
                case IPush(val):
                    push(val);

                case IDefine(name):
                    scope.define(name, pop());

                case IVariable(name):
                    push(scope.get(name));

                case IField(field):
                    push(Reflect.getProperty(pop(), field));

                case ICall(argsNum):
                    final args = [];

                    for (i in 0...argsNum)
                        args.unshift(pop());

                    Reflect.callMethod(null, stack.pop(), args);

                default:
            }
        }

        return null;
    }
}