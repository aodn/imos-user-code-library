"""
Utility functions for NESP data processing and visualization.

This module provides helper functions for:
- Generating color mappings and hexbin visualizations using pydeck
- Creating rich tables for schema display
- Estimating pyarrow dataset sizes
- Generating PyDeck Artifacts
"""
import matplotlib.pyplot
import pyarrow
import pyarrow.dataset
import rich.console
import rich.table
import typing
import polars
import pydeck
import pydeck.data_utils
import tempfile
import pathlib
import zipfile
import geopandas
import h3
import polars_st

N_QUANTILES = 10
COLOR_PALETTE = "plasma"
COLOR_PALETTE_LITERAL = typing.Literal["viridis", "plasma", "inferno", "magma", "cividis"]
TOOLTIP = {
    "html": """
        <div style="font-family: 'Helvetica Neue', Arial, sans-serif; padding: 10px;">
            <b style="font-size: 1.2em;">H3 Index:</b> <code>{h3Index}</code><br/>
            <hr style="margin: 5px 0; border: 0; border-top: 1px solid #ccc;">
            <b>Records:</b> {n_records}<br/>
            <b>Datasets:</b> {datasets}
        </div>
    """,
    "style": {
        "width": "33%",
        "backgroundColor": "#2b2b2b",
        "color": "white",
        "borderRadius": "4px",
        "zIndex": "1000"
    }
}
GLOBAL_VIEW_STATE = pydeck.ViewState(
    latitude=0,
    longitude=0,
    zoom=0.75,
    pitch=0,
    bearing=0,
)


def generate_color_mapping(
    n_quantiles: int = N_QUANTILES,
    color_palette: COLOR_PALETTE_LITERAL = COLOR_PALETTE,
    alpha: float = 0.8,
) -> dict[str, list[int]]:
    """
    Generate a mapping from quantile indices to RGBA color values.

    :param n_quantiles: Number of quantiles/colors to generate.
    :type n_quantiles: int
    :param color_palette: Name of the matplotlib color palette to use.
    :type color_palette: COLOR_PALETTE_LITERAL
    :param alpha: Alpha value for color transparency (0.0-1.0).
    :type alpha: float
    :return: Dictionary mapping quantile indices (as strings) to RGBA color lists.
    :rtype: dict[str, list[int]]
    """

    # Sample colours
    colors = matplotlib.pyplot.get_cmap(color_palette)([i / (n_quantiles - 1) for i in range(n_quantiles)])

    # Convert from 0.0-1.0 floats to 0-255 integers
    mapping = {
        str(i): [int(r * 255), int(g * 255), int(b * 255), int(alpha * 255)]
        for i, (r, g, b, _) in enumerate(colors)
    }

    return mapping

def generate_color_index_series(
    df: polars.DataFrame,
    aggregate_column_name: str,
    color_mapping: dict[str, list[int]] = generate_color_mapping(
        n_quantiles=N_QUANTILES,
        color_palette=COLOR_PALETTE,
    ),
) -> polars.Series:
    """
    Generate a polars Series assigning each row to a color index based on quantiles.

    :param df: Input polars DataFrame.
    :type df: polars.DataFrame
    :param aggregate_column_name: Name of the column to aggregate and bin.
    :type aggregate_column_name: str
    :param color_mapping: Mapping of color indices to RGBA values.
    :type color_mapping: dict[str, list[int]]
    :return: Series of color indices as strings.
    :rtype: polars.Series
    """

    # Bin the h3 cells
    return df[aggregate_column_name].qcut(
        quantiles=len(color_mapping),
        labels=list(color_mapping.keys()),
        allow_duplicates=True,
    ).cast(polars.String)

def generate_pydeck_hexagon_layers(
    df: polars.DataFrame,
    aggregate_column_name: str,
    hexagon_index_column_name: str = "h3Index",
    n_quantiles: int = N_QUANTILES,
    color_palette: COLOR_PALETTE_LITERAL = COLOR_PALETTE,
) -> list[pydeck.Layer]:
    """
    Generate a list of pydeck H3HexagonLayer objects for visualizing hexagons.

    :param df: Input polars DataFrame.
    :type df: polars.DataFrame
    :param aggregate_column_name: Column to aggregate for coloring.
    :type aggregate_column_name: str
    :param hexagon_index_column_name: Column containing H3 hexagon indices.
    :type hexagon_index_column_name: str
    :param n_quantiles: Number of quantiles/colors.
    :type n_quantiles: int
    :param color_palette: Name of the matplotlib color palette.
    :type color_palette: COLOR_PALETTE_LITERAL
    :return: List of pydeck Layer objects.
    :rtype: list[pydeck.Layer]
    """

    # Generate color mapping
    color_mapping = generate_color_mapping(
        n_quantiles=n_quantiles,
        color_palette=color_palette,
    )

    # Add a color index to the df
    color_index_column_name = "__color_index__"
    df = df.with_columns(
        generate_color_index_series(
            df=df,
            aggregate_column_name=aggregate_column_name,
            color_mapping=color_mapping,
        ).alias(color_index_column_name),
    )

    return [
        pydeck.Layer(
            "H3HexagonLayer",
            df.filter(
                polars.col(color_index_column_name).eq(color_index),
            ).to_pandas(use_pyarrow_extension_array=True),
            get_hexagon=hexagon_index_column_name,
            auto_highlight=True,
            extruded=False,
            get_fill_color=fill_color,
            get_line_color=fill_color[:3],
            line_width_min_pixels=2,
            pickable=True,
        )
        for color_index, fill_color in color_mapping.items()
    ]

def print_schema_rich_table(
    schema: pyarrow.Schema,
    metadata_keys: list[str] = ["definition", "units"]
) -> None:
    """
    Generate a rich Table displaying schema field names and metadata.

    :param schema: PyArrow schema object.
    :type schema: pyarrow.Schema
    :param metadata_keys: List of metadata keys to display.
    :type metadata_keys: list[str]
    :return: Rich Table object with schema information.
    :rtype: rich.table.Table
    """

    # Construct table
    table = rich.table.Table()
    table.add_column("name")
    table.add_column("type")
    for metadata_key in metadata_keys:
        table.add_column(metadata_key)

    # Add the field name and definition rows
    for field in schema:

        # Add name
        field_row = [
            field.name,
            str(field.type),
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

    rich.console.Console().print(table)

def generate_view_state(
    df: polars.DataFrame,
    view_proportion: float = 1.0,
    longitude_column_name: str = "decimalLongitude",
    latitude_column_name: str = "decimalLatitude",
) -> pydeck.ViewState:
    """
    Compute a pydeck ViewState centered and zoomed to fit the data points.

    :param df: Input polars DataFrame containing longitude and latitude columns.
    :type df: polars.DataFrame
    :param view_proportion: Proportion of the view to use for fitting points (0.0-1.0).
    :type view_proportion: float
    :param longitude_column_name: Name of the longitude column.
    :type longitude_column_name: str
    :param latitude_column_name: Name of the latitude column.
    :type latitude_column_name: str
    :return: Computed pydeck ViewState object.
    :rtype: pydeck.ViewState
    """
    return pydeck.data_utils.compute_view(
        points=df.select(
            polars.col(longitude_column_name),
            polars.col(latitude_column_name),
        ).to_numpy(),
        view_proportion=view_proportion,
    )

def estimate_dataset_size(
    ds: pyarrow.dataset.Dataset,
    n_samples: int = 10_000,
) -> int:
    """
    Estimate the size of a PyArrow dataset in megabytes by sampling rows.

    :param ds: PyArrow dataset object.
    :type ds: pyarrow.dataset.Dataset
    :param n_samples: Number of rows to sample for estimation.
    :type n_samples: int
    :return: Estimated dataset size in megabytes.
    :rtype: int
    """

    # Take a sample
    n_rows = ds.count_rows()
    sample= ds.head(min(n_samples, n_rows))

    # Estimate dataset size
    avg_bytes_per_row = sample.nbytes / min(n_samples, n_rows)
    estimated_bytes = avg_bytes_per_row * n_rows
    estimated_megabytes = estimated_bytes / (2 ** 20)
    return estimated_megabytes


def generate_geodataframe_from_shapefile(path: pathlib.Path) -> geopandas.GeoDataFrame:

    # Unzip into a temporary directory
    with tempfile.TemporaryDirectory() as temporary_directory:
        # Unzip the path
        with zipfile.ZipFile(path, 'r') as zip_ref:
            zip_ref.extractall(temporary_directory)

        # Read the shape file
        gdf = geopandas.read_file(
            temporary_directory,
            engine="pyogrio",
        )

        # Check and translate to 4326
        if gdf.crs is None or gdf.crs.to_epsg() != 4326:
            gdf = gdf.to_crs("EPSG:4326")

        return gdf

def generate_wkt_to_h3_index(
    gdf: polars_st.GeoDataFrame,
    h3_resolution: int = 5,
    tag_column_name: str = "tag",
) -> polars.DataFrame:
    """
    Convert geometries in a GeoDataFrame to H3 hexagon indices and aggregate by tags.

    This function takes a GeoDataFrame containing geometries, converts each geometry
    to H3 hexagon indices at the specified resolution, and groups the results by
    H3 index while aggregating associated tags.

    :param gdf: Input GeoDataFrame containing geometries and tag information.
    :type gdf: polars_st.GeoDataFrame
    :param h3_resolution: H3 resolution level for hexagon indexing (0-15).
    :type h3_resolution: int
    :param tag_column_name: Name of the column containing tags to aggregate.
    :type tag_column_name: str
    :return: DataFrame with H3 indices, aggregated tags, and tag counts.
    :rtype: polars.DataFrame
    """
    return (
        gdf
        .with_columns(
            # Get h3 shapes per wkt
            # Produces list[h3_index]
            polars_st.geom().st.to_dict().map_elements(
                function=lambda geo_interface: h3.h3shape_to_cells_experimental(
                    h3shape=h3.geo_to_h3shape(geo_interface),
                    res=h3_resolution,
                    contain="overlap",
                ),
                return_dtype=polars.List(polars.String)
            ).alias("h3Index"),
            # Add h3 resolution scalar
            polars.lit(h3_resolution).cast(polars.Int8).alias("h3_resolution"),
        )
        # Drop no longer required geometry
        .drop(
            polars_st.geom(),
        )
        # Generate record per geometry h3 indexes
        .explode(
            polars.col("h3Index"),
        )
        # Group by the location
        .group_by(
            polars.col("h3_resolution"),
            polars.col("h3Index")
        ).agg(
            polars.col(tag_column_name).alias("tags"),
        ).with_columns(
            # Aggregate tags to a representable string
            polars.col("tags").list.join("|"),
            polars.col("tags").list.len().alias("n_tags"),
        ).sort(
            polars.col("tags"),
        )
    )