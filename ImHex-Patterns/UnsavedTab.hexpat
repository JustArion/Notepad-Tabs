#include <std/mem.pat>
#include <std/string.pat>
#include <std/hash.pat>
#include <type/leb128.pat>

using ul = type::uLEB128;

struct UnsavedNotepadTab
{
    char NullTerminatedHeaderIdentifier[3];
    u8 SelectionStartDelimiter[2];
    ul SelectionStartIndex;
    ul SelectionEndIndex;
    u8 SelectionEndDelimiter[2];
    u8 Unknown1[2];
    ul TabContentLength;
    char16 Content[ContentLength];
    bool IsTempFile;
    u32 CRC32;
};

UnsavedNotepadTab tabState @ 0x0;

