# Bug Fix Notice

## Issue Identified

**SyntaxError in `scrub_audio.py` line 189**

### Problem
The original code used Python reserved keyword `in` as a format string placeholder:

```python
# BROKEN CODE (line 189)
cmd = [part.format(bitrate=bitrate, in=in_wav, out=out_wav) for part in cmd_template]
```

This caused a **SyntaxError** because `in` is a reserved keyword in Python and cannot be used as a parameter name.

### Error Message
```
File "C:\Ascrub\adv_audio_scrub\scrub_audio.py", line 189
    cmd = [part.format(bitrate=bitrate, in=in_wav, out=out_wav) for part in cmd_template]
                                        ^^
SyntaxError: invalid syntax
```

## Solution Applied

Changed the format string placeholders from `{in}` and `{out}` to `{input}` and `{output}`:

### Fixed Code

**Line 34-37 (Template definition):**
```python
# Template for neural scrub command. Formatting placeholders: {bitrate}, {input}, {output}
NEURAL_SCRUB_CMD_TEMPLATE = [
    sys.executable, "-m", "demucs.encodec", "--bitrate", "{bitrate}", "{input}", "-o", "{output}"
]
```

**Line 189 (Format call):**
```python
cmd = [part.format(bitrate=bitrate, input=in_wav, output=out_wav) for part in cmd_template]
```

## Files Modified

- `adv_audio_scrub/scrub_audio.py` (lines 34-37 and 189)

## Verification

✅ **Syntax check passed**: `python -m py_compile adv_audio_scrub/scrub_audio.py`
✅ **Import test passed**: Module can be imported without errors
✅ **No functionality changes**: Only placeholder names changed, behavior remains identical

## What You Need to Do

1. **Download the fixed package**: `adv_audio_scrub_FIXED.zip`
2. **Extract and replace** your current files
3. **Run the application**: `python gui.py`

The error should now be resolved!

## Technical Details

### Why This Happened

Python has reserved keywords that cannot be used as variable names or parameter names:
- `in`, `is`, `if`, `for`, `while`, `def`, `class`, etc.

When used in `.format()` method as keyword arguments, these reserved words cause syntax errors.

### The Fix

By renaming the placeholders to non-reserved words (`input` and `output`), the code now compiles correctly while maintaining the exact same functionality.

## Status

- **Bug**: Fixed ✅
- **Testing**: Passed ✅
- **Package**: Updated ✅
- **Ready to use**: Yes ✅

---

**Version**: Fixed on 2026-01-04
**Original Issue**: SyntaxError due to reserved keyword usage
**Resolution**: Renamed format placeholders to valid identifiers
