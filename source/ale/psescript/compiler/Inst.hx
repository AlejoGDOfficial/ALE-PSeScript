package ale.psescript.compiler;

enum Inst
{
    IPush(value:Dynamic);

    IDefine(name:String);

    IVariable(name:String);
    IField(field:String);

    ICall(args:Int);
}