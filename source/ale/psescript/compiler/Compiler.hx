package ale.psescript.compiler;

import ale.psescript.parser.Expr;

class Compiler
{
    final ast:Array<Expr>;

    public function new(ast:Array<Expr>)
        this.ast = ast;

    public function compile():Array<Inst>
    {
        final result:Array<Inst> = [];

        for (expr in ast)
            compileExpr(expr, result);

        return result;
    }

    function compileExpr(expr:Expr, result:Array<Inst>)
    {
        function emit(inst:Inst)
            result.push(inst);

        switch (expr.type)
        {
            case EString(value):
                emit(IPush(value));

            case ENumber(value):
                emit(IPush(value));

            case ENull:
                emit(IPush(null));

            case EDefine(name, value):
                compileExpr(value, result);

                emit(IDefine(name));

            case EVariable(name):
                emit(IVariable(name));

            case EField(obj, name):
                compileExpr(obj, result);

                emit(IField(name));

            case ECall(obj, args):
                compileExpr(obj, result);

                args ??= [];

                for (arg in args)
                    compileExpr(arg, result);

                emit(ICall(args.length));

            case EBlock(exprs):
                final insts:Array<Inst> = [];

                for (e in exprs)
                    compileExpr(e, insts);

                emit(IBlock(insts));

            case EFunction(name, args, block):
                final namedArgs:Array<String> = [];

                for (arg in args)
                {
                    namedArgs.push(arg.name);

                    if (arg.value != null)
                        compileExpr(arg.value, result);
                    else
                        emit(IPush(null));
                }

                final insts:Array<Inst> = [];

                for (e in block)
                    compileExpr(e, insts);

                emit(IFunction(name, namedArgs, insts));

            default:
        }
    }
}