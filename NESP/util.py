import matplotlib.pyplot
import pyarrow
import rich.table
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

def generate_schema_rich_table(
    schema: pyarrow.Schema,
    metadata_keys: list[str] = ["definition", "units"]
) -> rich.table.Table:
    
    # Construct table
    table = rich.table.Table()
    table.add_column("name")
    for metadata_key in metadata_keys:
        table.add_column(metadata_key)

    # Add the field name and definition rows
    for field in schema:

        # Add name
        field_row = [
            field.name,
        ]

        # Add additional metadata
        for metadata_key in metadata_keys:
            field_row.append(
                field.metadata.get(metadata_key.encode(), b"").decode() 
                if field.metadata 
                else None
            )
        table.add_row(*field_row)
        table.add_section()

    return table