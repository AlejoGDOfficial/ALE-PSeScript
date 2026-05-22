package ale.psescript.compiler;

enum abstract Inst(Int) from Int to Int
{
    var CONSTANT = 0;
    
    var VARIABLE = 1;
    var FIELD = 2;

    var DEFINE = 3;

    var CALL = 4;

    var POP = 5;

    var RETURN = 6;
}