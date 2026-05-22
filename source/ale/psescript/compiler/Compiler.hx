package ale.psescript.compiler;

import ale.psescript.parser.Expr;

class Compiler
{
    final ast:Array<Expr>;

    public function new(ast:Array<Expr>)
        this.ast = ast;

    final result:Array<Inst> = [];

    public function compile():Array<Inst>
    {
        for (expr in ast)
            compileExpr(expr);

        return result;
    }

    function emit(inst:Inst)
        result.push(inst);

    function compileExpr(expr:Expr)
    {
        switch (expr.type)
        {
            case EString(value):
                emit(IPush(value));

            case ENumber(value):
                emit(IPush(value));

            case EDefine(name, value):
                compileExpr(value);

                emit(IDefine(name));

            case EVariable(name):
                emit(IVariable(name));

            case EField(obj, name):
                compileExpr(obj);

                emit(IField(name));

            case ECall(obj, args):
                compileExpr(obj);

                args ??= [];

                for (arg in args)
                    compileExpr(arg);

                emit(ICall(args.length));

            default:
        }
    }
}