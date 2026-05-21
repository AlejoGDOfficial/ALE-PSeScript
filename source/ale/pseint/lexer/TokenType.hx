package ale.pseint.lexer;

enum TokenType
{
    // Std

    TIdent;
    TString;
    TNumber;

    // Symbols

    TComma;

    TLParen;
    TRParen;

    // Keywords

    TEscribir;

    TAlgoritmo;
    TFinAlgoritmo;

    // Operators

    TLeftArrow;
    TLess;
}