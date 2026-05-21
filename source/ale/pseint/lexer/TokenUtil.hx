package ale.pseint.lexer;

class TokenUtil
{
    public static var symbolToTokenType:Map<String, TokenType> = [
        ',' => TComma,
        '(' => TLParen,
        ')' => TRParen
    ];

    public static var identToKeyword:Map<String, TokenType> = [
        'Escribir' => TEscribir,
        'Algoritmo' => TAlgoritmo,
        'FinAlgoritmo' => TFinAlgoritmo
    ];
}