package ale.psescript.parser;

enum ExprType
{
    EProgram(expr:Array<Expr>);

    EString(value:String);
    ENumber(value:Float);

    EDefine(name:String, ?value:Expr);

    EVariable(name:String);
    EField(obj:Expr, field:String);
    ECall(obj:Expr, ?args:Array<Expr>);
}