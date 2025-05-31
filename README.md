# iizutypes
Bandaid patch that adds new value types.

```bash
rojo build -o "iizutypes.rbxm"
```

## Current types
| Type         | Description                    | Use cases                 |
| :----------: | -------------------------------|-------------------------- |
| Vector6      | A vector with 6 components: `X`, `Y`, `Z`, `W`, `H`, `D`  | Having to store position + size or position + orientation, easy raycasting. |
| Vector4      | A vector with 4 components: `X`, `Y`, `Z`, `A` | Having to store alpha with colors, quick UDim2 |
| FakeRandom   | Gives out pseudorandom numbers by going through an array | Emulating old RNG methods |

## Potential types
These types may not be present in the current version and are also subject to removal.
| Type         | Description                    | Use cases                 | Problem        |
| :----------: | -------------------------------|-------------------------- | -------------- |
| LSC (Long Short Char) | Buffer types with separate fixed sizes.  | Data storing, smaller remote arguments. | Buffers were originally meant to be flexible. |
| Rect3D       | Similar to Vector6, though with `Min` and `Max` + `Width`, `Height`  and `Depth` variables | 3D UI work. | It's a fancier Vector6. |
| RemoteHash   | Identifiers through remote communication | Remote safety, identification | stinks to make :\[ |
