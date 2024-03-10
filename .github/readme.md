### Notepad Tab File Types
- File Tab (Saved Tab)
- Unsaved Tab
- 0.bin
- 1.bin

---
**Note:** For convenience sake I will denote `ULEB128` as `ul`

### File Tab

The Pattern for this type can be found [here](../ImHex-Patterns/NotepadTab.pat)

`[~] = Undefined Length / Defined at runtime`

- [3] `char[3]` Header Identifier (Null Terminated) `NP\0`
- [1] `bool` IsSaved (The Tab) `00 / 01`

`If IsSaved:`
> - [1-16] `ul` Saved File Path Length
> - [~] `char16[~]` Saved File Path
>     - UTF-16
> - [1-16] `ul` Tab Content Length
> - [2] `u8[2]` Possible Delimiter `05 01`
> - [1-16] `ul` FileTime `D2 EC E8 C2 D8 AF 9C ED 01`
>     - Increments from Left to Right
>     - 9 bytes
> - [32] `u8[32]` SHA-256 of the Content
> - [2] `u8[2]` Possible Selection Start Delimiter `00 01`

`Else:`
> - [1] `u8` Possible Selection Start Delimiter

- [1-16] `ul` Selection Start Index
- [1-16] `ul` Selection End Index
- [4] `u8[4]` Possible Delimiter `01 00 00 00`
- [1-16] `ul` Tab Content Length
    - Same as previous
- [~] `char16[~]` Tab Content
    - UTF-16
- [1] `bool` Unknown Bool `00 / 01`
    - `False` on Saved File
    - `True` on Unsaved File
    - `False` on Unsaved File with Chunks
- [4] `u8[4]` CRC of all content from **after** the *Header Identifier* up to here
- [~] `UnsavedChunk[~]` Remaining unsaved chunks of user input (Additions or Deletions)
    - Thanks to [ogmini](https://github.com/ogmini/)


### Unsaved Chunk

`[~] = Undefined Length / Defined at runtime`

- [1-16] `ul` Cursor Position
- [1-16] `ul` Number of Characters Deleted
- [1-16] `ul` Numbers of Characters Added
- [~] `char16[~]` Literal Characters that have been added.
- [4] `u32` CRC of all content of the chunk up to here