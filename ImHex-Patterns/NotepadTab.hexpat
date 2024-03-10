#include <std/string.pat>
#include <type/leb128.pat>
#include <std/time.pat>
#include <std/core.pat>

using ul = type::uLEB128;
using int = u32;

// Thanks to https://github.com/ogmini/Notepad-Tabstate-Buffer/blob/main/README.md#insertion-chunk
struct UnsavedChunk
{
    ul CursorPosition;
    ul CharactersDeleted;
    ul CharactersAdded;
    char16 AddedCharacters[CharactersAdded];
    u8[4] CRC32;
};

struct NotepadTab
{
    char NullTerminatedHeaderIdentifier[3]; // NP\0
    bool IsSaved;

    if (IsSaved)
    {
        ul SavedFilePathLength;
        char16 SavedFilePath[SavedFilePathLength];
        ul SavedContentLength;

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

    ul CurrentContentLength;
    char16 Content[CurrentContentLength];
    // False on Saved File, 
    // True on unsaved file,
    // False on unsaved file with chunks
    // True on saved file with unsaved content
    bool HasUnsavedContent; 
    u8 CRC32[4];
    UnsavedChunk Chunks[0];
};

fn CheckForUnsavedContent(ref NotepadTab tab)
{
    if (tab.SavedContentLength != tab.CurrentContentLength)
    {
        std::print(std::format("You have some unsaved content! {0} bytes of unsaved content!", tab.CurrentContentLength - tab.SavedContentLength));
    }
};

fn filetime_to_local(ul time)
{
    int epoch=std::time::filetime_to_unix(time);
    return std::time::to_local(epoch);
};

fn format_to_hex(auto data)
{
    int length = std::core::member_count(data);
    str result;
    for(int i = 0, i < length, i = i+1)
    {
        result = result + std::format("{:X}", u8(data[i]));
    }
    return result;
};

NotepadTab tab @ 0x0;

if (tab.IsSaved)
{
    std::time::EpochTime unixTime = std::time::filetime_to_unix(tab.FileTime);
    std::print("Last Saved Unix Time is {0}",std::string::to_string(unixTime));

    CheckForUnsavedContent(tab);

    std::time::Time localTime = filetime_to_local(tab.FileTime);

    str formattedFileTime = std::time::format(localTime, "%H:%M:%S | %Y-%m-%d");

    std::print("File: {0}", tab.SavedFilePath);
    std::print("Saved at " + formattedFileTime);
    std::print("SHA256: {0}", format_to_hex(tab.Content_SHA256));

    std::print("Cursor Position: {0}", tab.SelectionStartIndex);
    
    if (tab.SelectionStartIndex != tab.SelectionEndIndex)
    {
        std::print("Selection End Index: {0}", tab.SelectionEndIndex);
        str slice = std::string::substr(std::string::to_string(tab.Content), tab.SelectionStartIndex, tab.SelectionEndIndex - tab.SelectionStartIndex);
        std::print("Selected Text: {0}", slice);
    }
}

std::print("Content: {0}", tab.Content);
std::print("CRC32: {0}", format_to_hex(tab.CRC32));
