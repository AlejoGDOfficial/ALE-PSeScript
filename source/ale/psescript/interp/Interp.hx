package ale.psescript.interp;

import ale.psescript.parser.Expr;
import ale.psescript.parser.ExprType;

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

    public function execute(expr:Expr):Dynamic
    {
        return switch (expr.type)
        {
            case EProgram(exprs):
                var result = null;

                try
                {
                    for (stmt in exprs)
                        result = execute(stmt);
                } catch (signal:ReturnSignal) {
                    result = signal.value;
                }

                result;

            case EField(obj, field):
                if (obj == null)
                    scope.get(field);
                else
                    Reflect.getProperty(execute(obj), field);

            case ECall(obj, args):
                Reflect.callMethod(null, execute(obj), [for (arg in args) execute(arg)]);

            case EDefine(name, value):
                scope.define(name, execute(value));

            case ENumber(val):
                val;

            case EString(val):
                val;

            default:
                null;
        }
    }
}