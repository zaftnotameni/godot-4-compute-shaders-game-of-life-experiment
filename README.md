# Game Of Life - Using Compute Shaders

This is a simple experiment created to learn about Godot compute shaders.

The sum of neighbours is run using the shader defined in the `/zaft/game/shaders` folder.

I've been meaning to learn compute shaders for a while,
and [Captain Coder's Learn You a Game Jam](https://itch.io/jam/learn-you-a-game-jam-2024)
ended up being the final little push of motivation I needed to sit down and understand how this works.

## Requirements to Run

- Godot 4.3-beta2 or newer
- Forward+ renderer (unfortunately compute shaders are not available in the Compatibility renderer)

Extra consideration: everything uses **two spaces** (not tabs) for indentation.
If you want to use it with an editor set in a different way, you might end up with mixed indentation,
which breaks `gdscript` (because languages with meaningful whitespace are so wonderful).

## License - GPLv3

Copy left, no ifs, no buts. Full document [on the gnu website](https://www.gnu.org/licenses/gpl-3.0.html).

## Disclaimer

The code in this project is by no means optimized.

It is doing silly things like rendering 128X128 `ColorRect` nodes to show each frame
(which, as a surprise to noone, is orders of magnitude slower than the shader).
This is an extremely awful way of doing things, but it's done to also check how far
Godot nodes can go before performance becomes an issue.

It uses 128x128 buffers of `Int32` for the shaders, which is a complete waste:
each cell only needs to hold values from 0 to 8 (counting neighbors alive, ignoring self).


