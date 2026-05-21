package ale.psescript.interp;

import ale.psescript.parser.Expr;

class ReturnSignal
{
    public var value:Dynamic;

    public function new(value:Dynamic)
        this.value = value;
}