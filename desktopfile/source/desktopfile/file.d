module desktopfile.file;

public import inilike.file;

final class DesktopEntry : IniLikeGroup
{
    protected @nogc @safe this() nothrow {
        super("Desktop Entry");
    }
}
