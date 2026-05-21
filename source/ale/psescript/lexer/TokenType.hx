package ale.psescript.lexer;

enum TokenType
{
    // Std

    TIdent(value:String);
    TString(value:String);
    TNumber(value:Float);

    // Symbols

    TComma;

    TLParen;
    TRParen;

    TEqual;

    TDot;

    // Keywords

    TDefine;
    TAs;

    // Operators
}