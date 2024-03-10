#include <std/mem.pat>
#include <std/string.pat>
#include <std/hash.pat>
#include <type/leb128.pat>
#include <std/time.pat>

// Lengths in the pattern are Lengths in Bytes as opposed to Length of characters.
using ul = type::uLEB128;

// Thanks to https://github.com/ogmini/Notepad-Tabstate-Buffer/blob/main/README.md#insertion-chunk
struct UnsavedChunk
{
    ul CursorPosition;
    ul CharactersDeleted;
    ul CharactersAdded;
    char16 AddedCharacters[CharactersAdded];
    u32 CRC32;
};

struct NotepadTab
{
    char NullTerminatedHeaderIdentifier[3]; // NP\0
    bool IsSaved;

    if (IsSaved)
    {
        ul SavedFilePathLength;
        char16 SavedFilePath[SavedFilePathLength];
        ul ContentLength1;

        u8 Unknown1[2]; // 05 01

        ul FileTime;

        u8 Content_SHA256[32];
        u8 SelectionStartDelimiter[2]; // 00 01
    }
    else 
    {
        u8 SelectionStartDelimiter; // 01
    }
    
    ul SelectionStartIndex;
    ul SelectionEndIndex;

    u8 SelectionEndDelimiter[4]; // 01 00 00 00

    ul ContentLength;
    char16 Content[ContentLength];

    // False on Saved File, 
    // True on unsaved file,
    // False on unsaved file with chunks
    bool Unknown3; 

    u32 CRC32;
    UnsavedChunk Chunks[0];
};

NotepadTab tabState @ 0x0;

if (tabState.IsSaved)
{
    std::time::EpochTime unixTime = std::time::filetime_to_unix(tabState.FileTime);
    std::print("Last Saved Unix Time is " + std::string::to_string(unixTime));
}
