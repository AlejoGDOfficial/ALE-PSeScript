package ale.psescript.interp;

import ale.psescript.parser.Expr;

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

    public function execute(ast:Expr, ?customScope:Scope):Dynamic
    {
        return switch (ast.type)
        {
            case EBlock(exprs):
                final oldScope = scope;

                scope = customScope ?? new Scope(scope);

                for (expr in exprs)
                    execute(expr);

                scope = oldScope;

                null;

            case EFunction(name, args, block):
                scope.define(name, Reflect.makeVarArgs(
                    function (newArgs:Array<Dynamic>)
                    {
                        final oldScope = scope;

                        scope = new Scope(scope);

                        for (index => arg in args)
                            scope.define(arg.name, execute(newArgs[index] ?? arg.value));

                        execute(block, scope);

                        scope = oldScope;
                    }
                ));

                null;

            case EProgram(exprs):
                for (expr in exprs)
                    execute(expr);

                null;

            case ECall(obj, args):
                Reflect.callMethod(this, execute(obj), [for (arg in args) execute(arg)]);

            case EVariable(name):
                scope.get(name);

            case EString(str):
                str;

            case ENumber(num):
                num;

            default:
                null;
        }
    }
}