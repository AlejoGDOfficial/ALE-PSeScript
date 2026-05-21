package ale.psescript.lexer;

class TokenUtil
{
    public static var symbolToTokenType:Map<String, TokenType> = [
        ',' => TComma,
        '(' => TLParen,
        ')' => TRParen,
        '.' => TDot,
        '=' => TEqual
    ];

    public static var identToKeyword:Map<String, TokenType> = [
        'define' => TDefine,
        'as' => TAs
    ];
}