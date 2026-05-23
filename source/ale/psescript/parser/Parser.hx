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

    public function parse():Array<Expr>
    {
        final result:Array<Expr> = [];

        while (!isEnd())
        {
            final res:Expr = parseExpr();

            if (res != null)
                result.push(res);
        }

        return result;
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
                {type: EString(val)}

            case TNumber(val):
                {type: ENumber(val)}

            case TNull:
                {type: ENull}

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
                {type: EVariable(id)}

            case TFunction:
                final name:String = switch (advance())
                {
                    case TIdent(n):
                        n;

                    default:
                        error();

                        null;
                }

                final args:Array<FunctionArgument> = parseFunctionArguments(); 

                {type: EFunction(name, args, parseFunctionBlock())};

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

    function parseFunctionBlock():Array<Expr>
    {
        final result:Array<Expr> = [];
        
        while (!isEnd() && peek() != TEnd)
        {
            final expr = parseExpr();

            if (expr != null)
                result.push(expr);
        }
        
        expect(TEnd);
        
        return result;
    }

    function parseCallArguments():Array<Expr>
    {
        final args:Array<Expr> = [];

        expect(TLParen);

        var shouldContinue:Bool = peek() != TRParen;

        while (shouldContinue && !isEnd())
        {
            args.push(parseExpr());

            shouldContinue = switch (peek())
            {
                case TComma:
                    advance();

                    true;

                default:
                    false;
            }
        }

        expect(TRParen);

        return args;
    }

    function parseFunctionArguments():Array<FunctionArgument>
    {
        final result:Array<FunctionArgument> = [];

        expect(TLParen);

        var shouldContinue:Bool = peek() != TRParen;

        while (shouldContinue)
        {
            final name:String = switch (advance())
            {
                case TIdent(n):
                    n;

                default:
                    error();

                    null;
            }

            final value:Expr = switch (peek())
            {
                case TEqual:
                    advance();

                    parseExpr();
                
                default:
                    null;
            }

            result.push({name: name, value: value});

            shouldContinue = switch (peek())
            {
                case TComma:
                    advance();

                    true;

                default:
                    false;
            }
        }

        expect(TRParen);

        return result;
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