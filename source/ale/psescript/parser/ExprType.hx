package ale.psescript.parser;

enum ExprType
{
    EString(value:String);
    ENumber(value:Float);
    EBlock(exprs:Array<Expr>);

    ENull;

    EDefine(name:String, ?value:Expr);

    EVariable(name:String);
    EField(obj:Expr, field:String);
    EFunction(name:String, args:Array<FunctionArgument>, block:Array<Expr>);

    ECall(obj:Expr, ?args:Array<Expr>);
}