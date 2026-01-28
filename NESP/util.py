import matplotlib.pyplot
import typing

def generate_color_mapping(
    n_colors: int = 10,
    color_palette: typing.Literal["viridis", "plasma", "inferno", "magma", "cividis"] = "plasma",
    alpha: float = 0.8,
) -> dict[str, list[float]]:

    # Sample colours
    colors = matplotlib.pyplot.get_cmap(color_palette)([i / (n_colors - 1) for i in range(n_colors)])
    
    # Convert from 0.0-1.0 floats to 0-255 integers
    mapping = {
        str(i): [int(r * 255), int(g * 255), int(b * 255), int(alpha * 255)]
        for i, (r, g, b, _) in enumerate(colors)
    }
    
    return mapping