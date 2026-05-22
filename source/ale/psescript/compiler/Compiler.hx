package ale.psescript.compiler;

import ale.psescript.parser.Expr;

class Compiler
{
    public final ast:Expr;

    public final chunk:Chunk = new Chunk();

    public function new(ast:Expr)
        this.ast = ast;

    public function compile():Chunk
    {
        compileExpr(ast);

        return chunk;
    }

    function emitByte(op:Inst)
        chunk.bytes.push(op);

    function emitConstant(value:Dynamic)
        emitByte(addConstant(value));

    function addConstant(value:Dynamic):Int
    {
        chunk.constants.push(value);

        return chunk.constants.length - 1;
    }

    function compileExpr(expr:Expr)
    {
        switch (expr.type)
        {
            case EProgram(exprs):
                for (e in exprs)
                    compileExpr(e);

            case EVariable(name):
                emitByte(VARIABLE);

                emitConstant(name);

            case EField(obj, name):
                compileExpr(obj);

                emitByte(FIELD);

                emitConstant(name);

            case EString(value):
                emitByte(CONSTANT);

                emitConstant(value);

            case ENumber(value):
                emitByte(CONSTANT);

                emitConstant(value);

            case ECall(obj, args):
                compileExpr(obj);

                for (arg in args)
                    compileExpr(arg);

                emitByte(CALL);

                emitConstant(args.length);

            case EDefine(name, value):
                compileExpr(value);

                emitByte(DEFINE);

                emitConstant(name);

            default:
        }
    }
}