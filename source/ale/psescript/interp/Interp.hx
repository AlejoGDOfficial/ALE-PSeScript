package ale.psescript.interp;

import ale.psescript.compiler.Chunk;
import ale.psescript.compiler.Inst;

import haxe.Log;

class Interp
{
    public final name:String;

    public var scope:Scope;

    public function new(name:String)
    {
        this.name = name;

        scope = new Scope();

        scope.define('trace', (t) -> {
            Log.trace(name + ': ' + t);
        });
    }

    var stack:Array<Dynamic>;

    var chunk:Chunk;

    var pointer:Int = 0;

    inline function readByte():Int
        return chunk.bytes[pointer++];

    inline function readConstant():Dynamic
        return chunk.constants[readByte()];

    public function execute(newChunk:Chunk):Dynamic
    {
        stack = [];

        chunk = newChunk;

        pointer = 0;

        while (pointer < chunk.bytes.length)
        {
            switch (readByte() : Inst)
            {
                case CONSTANT:
                    stack.push(readConstant());

                case CALL:
                    final args:Array<Dynamic> = [];

                    for (i in 0...readConstant())
                        args.unshift(stack.pop());

                    Reflect.callMethod(null, stack.pop(), args);

                case VARIABLE:
                    stack.push(scope.get(readConstant()));

                case FIELD:
                    stack.push(Reflect.getProperty(stack.pop(), readConstant()));

                case DEFINE:
                    scope.define(readConstant(), stack.pop());

                default:
            }
        }

        return null;
    }
}