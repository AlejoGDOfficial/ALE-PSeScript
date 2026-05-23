package ale.psescript.compiler;

enum Inst
{
    IPush(value:Null<Dynamic>);

    IBlock(insts:Array<Inst>);

    IDefine(name:String);

    IVariable(name:String);
    IField(field:String);
    IFunction(name:String, args:Array<String>, block:Array<Inst>);

    ICall(args:Int);
}