module inilike.file;


struct ListMap(K,V, size_t chunkSize = 32)
{
    @disable this(this);

    private static struct ByNode(NodeType)
    {
    private:
        NodeType* _begin;
        NodeType* _end;

    public:
        bool empty() const {
            return _begin is null || _end is null || _begin.prev is _end || _end.next is _begin;
        }

        auto front() {
            return _begin;
        }

        auto back() {
            return _end;
        }

        void popFront() {
            _begin = _begin.next;
        }

        void popBack() {
            _end = _end.prev;
        }

        @property auto save() {
            return this;
        }
    }

    auto byNode()
    {
        return ByNode!Node(_head, _tail);
    }

    auto byNode() const
    {
        return ByNode!(const(Node))(_head, _tail);
    }

    auto byEntry() const {
        import std.algorithm : map;
        return byNode().map!(node => node.toEntry());
    }

    static struct Node {
    private:
        K _key;
        V _value;
        bool _hasKey;
        Node* _prev;
        Node* _next;

        @trusted this(K key, V value) pure nothrow {
            _key = key;
            _value = value;
            _hasKey = true;
        }

        @trusted this(V value) pure nothrow {
            _value = value;
            _hasKey = false;
        }

        @trusted void prev(Node* newPrev) pure nothrow {
            _prev = newPrev;
        }

        @trusted void next(Node* newNext) pure nothrow {
            _next = newNext;
        }

    public:
        @trusted inout(V) value() inout pure nothrow {
            return _value;
        }

        @trusted void value(V newValue) pure nothrow {
            _value = newValue;
        }

        @trusted bool hasKey() const pure nothrow {
            return _hasKey;
        }

        @trusted auto key() const pure nothrow {
            return _key;
        }

        @trusted inout(Node)* prev() inout pure nothrow {
            return _prev;
        }

        @trusted inout(Node)* next() inout pure nothrow {
            return _next;
        }

        auto toEntry() const {
            static if (is(V == class)) {
                alias Rebindable!(const(V)) T;
                if (hasKey()) {
                    return Entry!T(_key, rebindable(_value));
                } else {
                    return Entry!T(rebindable(_value));
                }

            } else {
                alias V T;

                if (hasKey()) {
                    return Entry!T(_key, _value);
                } else {
                    return Entry!T(_value);
                }
            }
        }
    }

    static struct Entry(T = V)
    {
    private:
        K _key;
        T _value;
        bool _hasKey;

    public:
        this(T value) {
            _value = value;
            _hasKey = false;
        }

        this(K key, T value) {
            _key = key;
            _value = value;
            _hasKey = true;
        }
    }

private:

    Node* _tail;
    Node* _head;
}


struct IniLikeLine
{
private:
    string _first;
    string _second;
}

class IniLikeGroup
{
private:
    alias ListMap!(string, IniLikeLine) LineListMap;

public:

    protected @nogc @safe this(string groupName) nothrow {

    }

    static struct LineNode
    {
    private:
        LineListMap.Node* node;
    }

    private @trusted auto lineNode(LineListMap.Node* node) pure nothrow {
        return LineNode(node);
    }

    @trusted auto byNode() {
        import std.algorithm : map;
        return _listMap.byNode().map!(node => lineNode(node));
    }

private:
    LineListMap _listMap;
}
