package ale.pseint.lexer;

using StringTools;

class Lexer
{
    public final content:String;

    public function new(content:String)
        this.content = content;

    var index:Int = 0;

    function isEnd():Bool
        return index > content.length - 1;

    function peek():Int
        return content.fastCodeAt(index);

    function peekString():String
        return content.charAt(index);

    function advance():Int
        return content.fastCodeAt(index++);

    function advanceString():String
        return String.fromCharCode(advance());
    
    inline function isDigitStart(char:Int):Bool
        return char >= '0'.code && char <= '9'.code;

    inline function isDigit(char:Int):Bool
        return isDigitStart(char) || char == '.'.code;

    inline function isIdentStart(char:Int):Bool
        return (char >= 'a'.code && char <= 'z'.code) || (char >= 'A'.code && char <= 'Z'.code) || char == '_'.code;

    inline function isIdent(char:Int):Bool
        return isIdentStart(char) || isDigit(char);

    function match(char:Int):Bool
    {
        if (peek() == char)
        {
            index++;

            return true;
        }

        return false;
    }

    public function tokenize():Array<Token>
    {
        final result:Array<Token> = [];

        while (!isEnd())
        {
            final cur:Int = peek();

            if (isIdentStart(cur))
            {
                var res:String = '';

                while (!isEnd() && isIdent(peek()))
                    res += advanceString();

                final asKeyword:TokenType = TokenUtil.identToKeyword[res];

                final token:Token = {
                    type: asKeyword ?? TIdent
                };

                if (asKeyword == null)
                    token.value = res;

                result.push(token);

                continue;
            }

            if (isDigitStart(cur))
            {
                var res:String = '';

                while (!isEnd() && isDigit(peek()))
                    res += advanceString();

                result.push({
                    type: TNumber,
                    value: Std.parseFloat(res)
                });

                continue;
            }

            switch (cur)
            {
                case ' '.code, '\t'.code, '\n'.code, '\r'.code:
                    advance();

                case '\''.code, '"'.code:
                    final apos:Int = advance();

                    var res:String = '';

                    while (!isEnd() && peek() != apos)
                        res += advanceString();

                    advance();

                    result.push({
                        type: TString,
                        value: res
                    });
                
                case '<'.code:
                    advance();

                    result.push({
                        type: match('-'.code) ? TLeftArrow : TLess
                    });
                
                default:
                    advance();

                    if (TokenUtil.symbolToTokenType.exists(peekString()))
                        result.push({
                            type: TokenUtil.symbolToTokenType[peekString()]
                        });
            }
        }

        return result;
    }
}