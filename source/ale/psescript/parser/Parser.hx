package ale.psescript.parser;

import ale.psescript.lexer.Token;
import ale.psescript.lexer.TokenType;

class Parser
{
    public final tokens:Array<Token>;

    public function new(tokens:Array<Token>)
        this.tokens = tokens;

    var index:Int = 0;

    function isEnd():Bool
        return index >= tokens.length;

    function fullPeekLast():Token
        return tokens[index - 1];

    function peekLast():TokenType
        return fullPeekLast().type;

    function fullPeek():Token
        return tokens[index];

    function peek():TokenType
        return fullPeek().type;

    function fullAdvance():Token
        return tokens[index++];

    function advance():TokenType
        return fullAdvance().type;

    function error(cur:Bool = false)
        throw 'Unexpected Token: ' + (cur ? peek() : peekLast());

    function expect(tok:TokenType)
        if (advance() != tok)
            throw 'Expected ' + tok + ', got ' + peekLast();

    public function parse():Expr
    {
        final result:Array<Expr> = [];

        while (!isEnd())
        {
            final res:Expr = parseExpr();

            if (res != null)
                result.push(res);
        }

        return {type: EProgram(result)};
    }

    function parseExpr(prec:Precedence = NONE):Expr
    {
        var left = parsePrefix();

        while (!isEnd() && Std.int(prec) < Std.int(getPrecedence(peek())))
            left = parsePostfix(left);

        return left;
    }

    function parsePrefix():Expr
    {
        return switch (advance())
        {
            case TString(val):
                {type: EString(val)};

            case TNumber(val):
                {type: ENumber(val)};

            case TDefine:
                final name:String = switch (advance())
                {
                    case TIdent(str):
                        str;

                    default:
                        error();

                        null;
                }

                parseOptionalType();

                {type: EDefine(name, parseOptionalValue())}

            case TIdent(id):
                {type: EField(null, id)}

            default:
                null;
        }
    }

    function parsePostfix(left:Expr):Expr
    {
        return switch (peek())
        {
            case TLParen:
                {type: ECall(left, parseCallArguments())}

            case TDot:
                advance();

                {type: EField(left,
                    switch (advance())
                    {
                        case TIdent(str):
                            str;

                        default:
                            error();

                            null;
                    }
                )};

            default:
                advance();

                left;
        }
    }

    function parseCallArguments():Array<Expr>
    {
        final args:Array<Expr> = [];

        expect(TLParen);

        while (!isEnd())
        {
            args.push(parseExpr());

            if (peek() == TComma)
                advance();
            else
                break;
        }

        expect(TRParen);

        return args;
    }

    function parseOptionalType()
    {
        switch (peek())
        {
            case TAs:
                advance();

                parseType();

            default:
        }
    }

    function parseType():String
    {
        switch (advance())
        {
            case TIdent(_):

            default:
                error();
        }

        return '';
    }

    function parseOptionalValue():Expr
    {
        return switch (peek())
        {
            case TEqual:
                advance();

                parseExpr();

            default:
                null;
        }
    }

    function getPrecedence(op:TokenType):Precedence
    {
        return switch (op)
        {
            case TEqual:
                ASSIGNMENT;

            case TLParen:
                CALL;

            case TDot:
                MEMBER;
                
            default:
                NONE;
        }
    }
}