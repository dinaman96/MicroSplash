def line(bin_colors, error_y_mode=None, **kwargs):
    """Extension of `plotly.express.line` to use error bands with color mapping."""
    ERROR_MODES = {'bar', 'band', 'bars', 'bands', None}
    if error_y_mode not in ERROR_MODES:
        raise ValueError(f"'error_y_mode' must be one of {ERROR_MODES}, received {repr(error_y_mode)}.")

    if error_y_mode in {'bar', 'bars', None}:
        fig = px.line(**kwargs)
    elif error_y_mode in {'band', 'bands'}:
        if 'error_y' not in kwargs:
            raise ValueError(f"If you provide argument 'error_y_mode' you must also provide 'error_y'.")
        figure_with_error_bars = px.line(**kwargs)
        fig = px.line(**{arg: val for arg, val in kwargs.items() if arg != 'error_y'})

        for data in figure_with_error_bars.data:
            bin_value = data['legendgroup']
            base_color = bin_colors.get(bin_value, 'rgba(0,0,0,1)')  # Get base color
            
            # Split the base color into components
            color_components = base_color.lstrip('rgba(').rstrip(')').split(',')
            r, g, b = (int(c.strip()) for c in color_components[:3])
            a = float(color_components[3].strip())  # Alpha value as float

            shaded_color = f'rgba({r},{g},{b},{a * 0.3})'  # Adjust alpha for shading

            x = list(data['x'])
            y_upper = list(data['y'] + data['error_y']['array'])
            y_lower = list(data['y'] - data['error_y']['array'] if data['error_y']['arrayminus'] is None else data['y'] - data['error_y']['arrayminus'])
            
            fig.add_trace(
                go.Scatter(
                    x=x + x[::-1],
                    y=y_upper + y_lower[::-1],
                    fill='toself',
                    fillcolor=shaded_color,
                    line=dict(color='rgba(255,255,255,0)'),
                    hoverinfo="skip",
                    showlegend=False,
                    legendgroup=data['legendgroup'],
                    xaxis=data['xaxis'],
                    yaxis=data['yaxis'],
                )
            )
        # Reorder data
        reordered_data = []
        for i in range(int(len(fig.data)/2)):
            reordered_data.append(fig.data[i + int(len(fig.data)/2)])
            reordered_data.append(fig.data[i])
        fig.data = tuple(reordered_data)
    return fig
