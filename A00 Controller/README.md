## A00 Post Processor ##

### Explanation of variables: ###
**8 digit program number** - Specifies that an 8 digit program number is needed.

**Write machine settings** - Output the machine settings in the header of the code.

**Write tool list** - Output a tool list in the header of the code.

**Write notes** - Writes operation notes as comments in the outputted code.

**Use G54.1 Pnn** - Begins WCS increments with G54.1 P01, G54.1 P02 ...

**Enable A-axis** - Specifies whether to enable the A axis.

**Radius arcs** - If yes is selected, arcs are outputted using radius values rather than IJK.

**Parametric feed** - Specifies the feed value that should be output using a Q value.

**Use line numbers** - Use line numbers for each block of outputted code.

**Line number start** - The number at which to start the line numbers.

**Line number increment** - The amount by which the line number is incremented by in each block.

**Separate words with space** - Adds spaces between words if 'yes' is selected.

**Safe start all operations** - Include safe start preamble for all operations.

**Preload next tool** - Preloads the next tool at a tool change (if any).

**Automatic optional stop** - Automatically outputs optional stop after each operation.

**Chip shower at end** - Run chip shower (M400/M401) at end of the cycle.

**Return spindle home at end** - Return spindle to home at end of the cycle with G28 G91 Z0.

**Center part at end** - Enable to center the part along X at the end of program for easy access. Requires a CNC with a moving table.

**Include post warnings** - Include post warnings (i.e. G20 unit parameter set in machine, M400 time, etc.) in the generated output.

**Add (%) for file transfer** - Specifies whether to write leading and trailing % for file transfer.
