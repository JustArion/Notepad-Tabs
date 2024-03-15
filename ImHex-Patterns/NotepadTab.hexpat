// Applies to:
// Saved Tabs
// Unsaved Tabs

// Does not apply to:
// Sequenced Tabs (0.bin 1.bin)

#include <std/string.pat>
#include <type/leb128.pat>
#include <std/time.pat>
#include <std/core.pat>

using ul = type::uLEB128;
using int = u32;

// https://github.com/ogmini/Notepad-Tabstate-Buffer/blob/main/README.md#insertion-chunk
struct UnsavedChunk
{
    ul CursorPosition;
    ul CharactersDeleted;
    string16 AddedCharacters;
    u8 CRC32[4];
};

// --- Data Types ---

// Default fallback is UTF-8
enum EncodingTypes : u8
{
    UTF8 = 5,
    UTF8BOM = 4,
    UTF16BE = 3,
    UTF16LE = 2,
    ANSI = 1,
};

enum EOLSequenceType : u8
{
    CRLF = 1, // Windows
    CR = 2, // Mac
    LF = 3 // Linux
};

struct SelectionInfo
{
    ul StartIndex;
    ul EndIndex;
};

// https://github.com/Nordgaren/tabstate-util/blob/master/TabState.bt#L48
// Word Wrap is in the "View" menu
// The options that appear when you right click
struct TabOptions
{
    bool WordWrap;
    bool RightToLeft;
    bool ShowUnicodeControl;
    u8 Unknown;
};

struct string16
{
    ul Length;
    char16 Value[Length];
};

struct SavedFileInfo
{
    string16 SavedFilePath;
    ul ContentLength;
    EncodingTypes EncodingType;
    EOLSequenceType LineCarriage;
    ul FileTime;
    u8 SHA256[32];
};

struct NotepadTab
{
    char MagicBytes[2]; // NP
    // https://github.com/Nordgaren/tabstate-util/issues/1#issuecomment-1988731585
    ul UnsavedSequenceNumber; // 0 in Saved files.
    bool IsSaved;

    if (IsSaved)
    {
        SavedFileInfo FileInfo;
        
        u8 SelectionStartDelimiter[2]; // 00 01
    }
    else 
    {
        u8 SelectionStartDelimiter; // 01
    }
    
    SelectionInfo CursorInfo;
    TabOptions Options;
    string16 Content;

    // False on Saved File, 
    // True on unsaved file,
    // False on unsaved file with chunks
    // True on saved file with unsaved content
    bool HasUnsavedContent; 
    u8 CRC32[4];
    UnsavedChunk Chunks[0];
};

// --- Functions ---

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

// -- Declaration --

NotepadTab tab @ 0x0;

// -- Presentation --

if (tab.IsSaved)
{
    std::time::EpochTime unixTimestamp = std::time::filetime_to_unix(tab.FileInfo.FileTime);
    std::print("Last Saved Unix Time is {0}",std::string::to_string(unixTimestamp));

    std::time::Time localTime = filetime_to_local(tab.FileInfo.FileTime);

    str formattedFileTime = std::time::format(localTime, "%Y-%m-%d | %H:%M:%S");

    std::print("Encoding Type: {0}", std::string::to_string(tab.FileInfo.EncodingType));
    std::print("Line Carriage Type: {0}", std::string::to_string(tab.FileInfo.LineCarriage));
    std::print("File: {0}", tab.FileInfo.SavedFilePath);
    std::print("Saved at " + formattedFileTime);
    std::print("SHA256: {0}", format_to_hex(tab.FileInfo.SHA256));

    std::print("Cursor Position: {0}", tab.CursorInfo.StartIndex);

    std::print("Options: {0}", tab.Options);
    
    if (tab.CursorInfo.StartIndex != tab.CursorInfo.EndIndex)
    {
        std::print("Selection End Index: {0}", tab.CursorInfo.EndIndex);
        str slice = std::string::substr(std::string::to_string(tab.Content), tab.CursorInfo.StartIndex, tab.CursorInfo.EndIndex - tab.CursorInfo.StartIndex);
        std::print("Selected Text: {0}", slice);
    }
}

std::print("Content: {0}", tab.Content);
std::print("CRC32: {0}", format_to_hex(tab.CRC32));

// -- Print Unknowns --

std::print("\nUnknowns\n------");

std::print("Selection Start Delimiter: {0}", tab.SelectionStartDelimiter);
std::print("Unknown Tab Option: {0}\n", tab.Options.Unknown);