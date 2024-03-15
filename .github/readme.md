### Notepad Tab File Types
- File Tab (Saved Tab)
- Unsaved Tab
- 0.bin
- 1.bin

---

#### Template:
- [sizeInBytes] `dataType` Short Description / Title `Example Bytes`
    - Additional Observations

**Notices:** 
- For convenience sake I will denote `ULEB128` as `ul`
- The [hexpat](../ImHex-Patterns/NotepadTab.pat) file has more detailed records with bundled data-types. Eg. a struct containing the `Start` and `End` for selection indexes.

### File Tab

The Pattern for this type can be found [here](../ImHex-Patterns/NotepadTab.pat)

`[~] = Undefined Length / Defined at runtime`

- [2] `char[2]` Magic Numbers / Header Identifier `NP`
- [1-16] `ul` Unsaved Sequence Number (Reserved for 0.bin and 1.bin files) `00`
- [1] `bool` IsSaved (The Tab) `00 / 01`

`If IsSaved:`
> - [1-16] `ul` Saved File Path Length
> - [~] `char16[~]` Saved File Path
>     - UTF-16
> - [1-16] `ul` Saved Tab Content Length
> - [1] `enum EncodingTypes` Encoding Type `UTF-8`
> - [1] `enum EOLSequenceType` Line Carriage Type `CRLF (Windows)`
> - [1-16] `ul` FileTime `D2 EC E8 C2 D8 AF 9C ED 01`
>     - Increments from Left to Right
>     - 9 bytes
> - [32] `u8[32]` SHA-256 of the File's Content
> - [2] `u8[2]` Possible Selection Start Delimiter `00 01`

`Else:`
> - [1] `u8` Possible Selection Start Delimiter `01`

- [1-16] `ul` Selection Start Index
- [1-16] `ul` Selection End Index
- [1] `bool` WordWrap `00 / 01`
- [1] `bool` Right To Left `00 / 01`
- [1] `bool` Show Unicode Control `00 / 01`
- [1] `u8` Unknown (Likely bool) `00`
- [1-16] `ul` Content Length
- [~] `char16[~]` Content
- [1] `bool` Has Unsaved Content `00 / 01`
    - `False` on Saved File
    - `True` on Unsaved File
    - `False` on Unsaved File with Chunks
    - `True` on saved file with unsaved content
- [4] `u8[4]` CRC of all content from **after** the *Header Identifier* up to here
- [~] `UnsavedChunk[~]` Remaining unsaved chunks of user input (Additions or Deletions)
    - Thanks to [ogmini](https://github.com/ogmini/)


### Unsaved Chunk

`[~] = Undefined Length / Defined at runtime`

- [1-16] `ul` Cursor Position
- [1-16] `ul` Number of Characters Deleted
- [1-16] `ul` Numbers of Characters Added
- [~] `char16[~]` Literal Characters that have been added
- [4] `u32` CRC of all content of the chunk up to here