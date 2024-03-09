### Notepad Tab File Types
- File Tab (Saved Tab)
- Unsaved Tab
- 0.bin
- 1.bin

---
**Note:** For convenience sake I will denote `ULEB128` as `ul`

### File Tab

The Pattern for this type can be found [here](../ImHex-Patterns/FileTab.pat)

`[~] = Undefined Length / Defined at runtime`

- [3] `char[3]` Header Identifier (Null Terminated) `NP\0`
- [1] `bool` IsSaved (The Tab) `00 / 01`
- [1-16] `ul` Saved File Path Length
- [~] `char16[~]` Saved File Path
    - UTF-16
- [1-16] `ul` Tab Content Length
- [2] `u8[2]` Possible Delimiter `05 01`
- [1-16] `ul` FileTime `D2 EC E8 C2 D8 AF 9C ED 01`
    - Increments from Left to Right
    - 9 bytes
- [33] `u8[33]` Unknown For Now / To Do
- [2] `u8[2]` Possible Delimiter `00 01`
- [1-16] `ul` Selection Start Index
- [1-16] `ul` Selection End Index
- [4] `u8[4]` Possible Delimiter `01 00 00 00`
- [1-16] `ul` Tab Content Length
    - Same as previous
- [~] `char16[~]` Tab Content
    - UTF-16
- [1] `bool` IsTempFile `00 / 01`
    - Unsure about this one
- [4] `u32` CRC32 of all content from **after** the *Header Identifier* up to here