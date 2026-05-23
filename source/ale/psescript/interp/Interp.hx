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
            executeInst(inst);

        return null;
    }

    function executeInst(inst:Inst)
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

                for (_ in 0...argsNum)
                    args.unshift(pop());

                callFunction(pop(), args);

            case IFunction(name, args, block):
                final defaults:Array<Dynamic> = [];

                for (_ in 0...args.length)
                    defaults.unshift(pop());

                scope.define(name, new Function(args, defaults, block, scope));

            default:
        }
    }

    function callFunction(toCall:Dynamic, ?args:Array<Dynamic>)
    {
        args ??= [];

        if (toCall is Function)
        {
            final newScope:Scope = new Scope(toCall.scope);

            for (i in 0...toCall.arguments.length)
                newScope.define(toCall.arguments[i], args[i] ?? toCall.defaults[i]);

            executeBlock(toCall.block, newScope);
        } else {
            Reflect.callMethod(null, toCall, args);
        }
    }

    function executeBlock(insts:Array<Inst>, ?newScope:Scope)
    {
        final prev:Scope = scope;

        scope = newScope ?? new Scope(scope);

        for (inst in insts)
            executeInst(inst);

        scope = prev;
    }
}