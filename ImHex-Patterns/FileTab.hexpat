#include <std/mem.pat>
#include <std/string.pat>
#include <std/hash.pat>
#include <type/leb128.pat>

using ul = type::uLEB128;


struct SavedNotepadTab
{
    char NullTerminatedHeaderIdentifier[3];
    bool IsSaved;
    ul SavedFilePathLength;
    char16 SavedFilePath[SavedFilePathLength];
    ul TabContentLength0;
    u8 Unknown1[2];
    u8 UnknownHashOrTime[8];
    u8 Unknown2[33];
    u8 PossibleSpecialDelimiter[2];
    ul SelectionStartIndex;
    ul SelectionEndIndex;
    u8 PossibleSpecialDelimiterEnd[4];
    ul ContentLength2;
    char16 Content[ContentLength2];
    bool IsTempFile;
    u32 CRC32;
};

SavedNotepadTab tabState @ 0x0;