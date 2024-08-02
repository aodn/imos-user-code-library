#!/usr/bin/env python
"""
utilfuncs.py
:authors: Salman Khan
:edited: Benjamin Stepin
:email: salmansaeed.khan@csiro.au, info@aodn.org.au
:creation date : 05-03-2020
:last modified : 16-05-2024
"""

import sys

from matplotlib.colors import LinearSegmentedColormap, ListedColormap, BoundaryNorm
import matplotlib.pyplot as plt
import numpy as np

from wavespectra.core.attributes import set_spec_attributes
import xarray as xr


def cmap_wavespectra(n):
    """ Colormap for plotting directional wave spectra.
	Args:
	    - n (int): number of levels in the colormap.
	Returns:
	    - a matplotlib.colors.LinearSegmentedColormap, which
	      can be used as a colormap.			
    """
    colors = np.array([[255,64,0],
		       [255,81,0],
		       [255,98,0],
		       [255,116,0],
  		       [255,133,0],
		       [255,150,0],
		       [255,168,0],
		       [255,185,0],
		       [255,202,0],
		       [255,220,0],
		       [255,237,0],
		       [255,255,0],
		       [231,255,14],
		       [208,255,29],
		       [185,255,44],
		       [162,255,58],
		       [139,255,73],
		       [115,255,88],
		       [92,255,103],
		       [69,255,117],
		       [46,255,132],
		       [23,255,147],
		       [0,255,162],
		       [0,255,170],
		       [0,255,178],
		       [0,255,187],
		       [0,255,195],
	   	       [0,255,204],
		       [0,255,212],
		       [0,255,221],
		       [0,255,229],
		       [0,255,238],
		       [0,255,246],
		       [0,255,255],
		       [0,234,255],
		       [0,214,255],
		       [0,194,255],
		       [0,173,255],
	   	       [0,153,255],
		       [0,133,255],
		       [0,113,255],
		       [0,92,255],
		       [0,72,255],
		       [0,52,255],
		       [0,32,255],
		       [11,29,243],
		       [23,26,231],
	 	       [34,23,220],
		       [46,20,208],
		       [58,17,197],
		       [69,14,185],
		       [81,11,174],
		       [93,8,162],
		       [104,5,151],
		       [116,2,139],
		       [128,0,128],
		       [139,23,139],
	 	       [151,46,151],
		       [162,69,162],
		       [174,92,174],
		       [185,115,185],
		       [197,139,197],
	 	       [208,162,208],
		       [220,185,220],
	 	       [231,208,231],
		       [243,231,243],
		       [255,255, 255]])/255.0
    return LinearSegmentedColormap.from_list(name = 'wavespectra', colors = np.flipud(colors), N = n)

def k2f(k):
    """ Convert wavenumber to frequency using deep water assumption.
	Args:
	    - k (np.ndarray or xr.DataArray): wavenumber vector
        Returns:
	    - frequency vector
    """
    return np.sqrt(9.8*k)/(2*np.pi) # 1/2pi.sqrt(gk)

def ek2f(ek, k, units = 'm4'):
    """ Convert wavenumber spectra (ekth) with units (m3.deg-1 = m^2.1/m^-1.deg^-1)
        or (m4.deg-1 = m^3.1/m^-1.deg^-1) to standard spectral variance density 
        spectra (efth) with units m2.s.deg-1. If direction units are radians then
        the relationship deg = (180/pi)rads is used. This is a vectorised method and 
        works for both time series of omni-dir and dir spectra as well as labelled
        (xr.DataArray) and unlabelled (numpy.ndarray) arrays:
        1- xr.DataArray
        Args:
            - ek (xr.DataArray): omni-dir wavenumber spectra
            - k (xr.DataArray): wavenumber coordinate vector
            - units (str): units of input. For detailed options,
              see Notes below.
        Returns:
            - xr.DataArray with 1-d spectral variance density spectra
        Notes:
            - The dim name for wavenumber vector should be the same for
              both ek and k, otherwise xarray's broadcasting will not
              properly align the arrays.
        2- np.ndarray
        Args:
            - ek (numpy.ndarray): omni-dir wavenumber spectra
            - k (numpy.ndarray): wavenumber coordinate vector
        Returns:
            - numpy.ndarray with 1-d spectral variance density spectra
        Notes:
            - If ek is of shape (m, n) where n is the size of k, then
              k should be of shape (n) or (1, n). 
            - If ek is of shape (m, n) where m is the size of k, then
              k should be of shape (m, 1).
            - Otherwise a ValueError will be thrown because numpy broadcasting 
              rules will be violated.
        Other Notes:
            - Input units can be 
              (i) \'m4\' or \'m4.deg-1\', \'m4.rad-1\',
              (iii) \'m3\' or \'m3.deg-1\', \'m3.rad-1\'
            - The return dir units are always in degrees, so if input dir units are
              in rads then the appropriate rad to degree conversion is used.
            - Formula derived in daily project progress word doc.
            - Deep water assumption is currently being used.
            - Formulas with water depth will be updated in the future.  
    """
    try:
        if units == 'm4' or units == 'm4.deg-1': 
            # omni-dir or dir (deg-1)
            # 4pi.sqrt(k/g).k.S(k)
            return 4 * np.pi * np.sqrt(k ** 3 / 9.8) * ek 
        elif units == 'm4.rad-1': 
            # dir (rad-1)
            # 4pi.sqrt(k/g).k.S(k).pi/180
            return 4 * np.pi * np.sqrt(k ** 3 / 9.8) * ek * np.pi / 180. 
        elif units == 'm3' or units == 'm3.deg-1': 
            # omni-dir or dir (deg-1)
            # 4pi.sqrt(k/g).S(k)
            return 4 * np.pi * np.sqrt(k / 9.8) * ek 
        elif units == 'm3.rad-1': 
            # dir (rad-1)
            # 4pi.sqrt(k/g).S(k).pi/180
            return 4 * np.pi * np.sqrt(k / 9.8) * ek * np.pi / 180. 
        else:
            sys.exit('ekth units must be \'m4\', \'m4.deg-1\', \'m4.rad-1\' or \'m3\', \'m3.deg-1\', \'m3.rad-1\', but \'{0:s}\' was given.'
                     .format(units))        
    except ValueError as ve:
        sys.exit(ve)

def s1_compute_efth(ds, ekth_name = 'EKTH', ekth_wavnum = 'WAVNUM',
                    ekth_dir = 'DIRECTION', ekth_time = 'TIME',
                    efth_name = 'efth', efth_freq = 'freq',
                    efth_dir = 'dir', efth_time = 'time'):
    """ Compute efth from Sentinel-1 wavenumber spectra with wavespectra
        library naming conventions so that wavespectra.SpecArray methods
        and plotting can be used.
        Args:
            - ds (xr.Dataset): Sentinel-1 dataset
            - ekth_name (str): name of wavenumber spectra variable
            - ekth_wavnum (str): name of wavenumber coord dim
            - ekth_dir (str): name of direction coord dim
            - ekth_time (str): name of time coord dim
            - efth_name (str): name of efth DataArray
            - efth_freq (str): name of freq coord dim
            - efth_dir (str): name of dir coord dim
            - efth_time (str): name of time coord dim
        Returns:
            - efth DataArray in wavespectra library conventions.
    """
    try:
        efth = ek2f(ek = ds.data_vars[ekth_name], k = ds.coords[ekth_wavnum],
                    units = 'm4.rad-1')        
        efth = xr.DataArray(data = efth, 
                            coords = [k2f(ds.coords[ekth_wavnum]), 
                                      efth.coords[ekth_time],
                                      efth.coords[ekth_dir]],
                            dims = [efth_freq, efth_time, efth_dir],
                            name = efth_name)
        set_spec_attributes(efth)
        efth[efth_dir].attrs = {'unit' : 'degree',
                                'standard_name' : 'sea_surface_wave_to_direction'}
        return efth
    except Exception as e:
        sys.exit(e)

# Plot the partitions
def plt_part(part, x, y, ax, **kwargs):
    # part must be np array of dimensions dir x freq
    # x is of dim dir in degrees
    # y is of dim freq in Hz
    
    x = part.coords[x].data
    y = 1/k2f(part.coords[y].data)
    part = part.data

    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1);

    # Append 1D freq spectrum at 0 degs again at the end for plotting
    part = np.append(part, np.expand_dims(part[0,:], axis=0), axis=0)
    x = np.append(x, 360)
    
    # plot the spectrum    
    x, y = np.broadcast_arrays(np.radians(x), y[:, np.newaxis])
    clrs = kwargs['cmap'].colors
    cax = ax.pcolormesh(x, y, np.transpose(part), alpha = 0.50,
                        # shading = 'flat', 
                        # facecolor = 'none',
                        # edgecolor = clrs, 
                        cmap = kwargs['cmap'], 
                        norm = kwargs['norm'])     
    
    # set labels for periods and dir coords
    ylocs = range(5, 35, 5)
    ylabels = [l for l in ylocs] 
    ax.set_yticks(ylocs)
    ax.set_yticklabels(ylabels)    
    xlocs = np.radians(range(0, 360, 45));
    xlabels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    ax.set_xticks(xlocs)
    ax.set_xticklabels(xlabels)
    ax.set_rlabel_position(180 + 45)
    ax.set_ylim([0, max(ylocs)]) # period range  
    plt.subplots_adjust(wspace = 0.75)
    ax.grid(color='grey',linestyle='-',linewidth=1.5,alpha=0.5)
    return cax

def discretecmap(cmin, cmax, cmap):
    """ Creates a discrete Colormap within desired bounds
    Args:
        - cmin (int): minimum color
        - cmax (int): maximum color
        - cmap (matplotlib.colors.Colormap): a Colormap object            
    Returns:
        - norm (matplotlib.colors.BoundaryNorm): a BoundaryNorm object
    """
    bounds = np.linspace(cmin, cmax, cmax - cmin + 1)
    return BoundaryNorm(bounds, cmap.N)    

def cmap_part(n):
    """ To be filled.
    """
    partcolors = np.array([[255,0,0],
                           [255,0,255],
                           [0,255,0], 
                           [0,0,255],
                           [0,255,255]])/255.0
    return ListedColormap(partcolors)

def plot_part(part):
    """ To be filled.
    """
    # plot the partitions
    cmap = cmap_part(5) # partitions colormap with five colors for parts 0-4    
    norm = discretecmap(0, 5, cmap) # map parts to cmap
    cmap.set_under(color = 'w', alpha = None) # anything under 0 is set to white
    
    part = part.squeeze()
    if len(part.dims) == 3:
        # a time series of 2d spectra partitions
        # use facet grid plotting
        ncols = 4
        if part.sizes['TIME'] < 4:
            ncols = part.sizes['TIME']
        fg = xr.plot.FacetGrid(data = part, col = 'TIME', col_wrap = ncols,
                               sharex = True, sharey = True, aspect = 0.9,
                               size = 3, 
                               subplot_kws = dict(projection = 'polar'))
        fg.map_dataarray(func = plt_part, x ='DIRECTION', y = 'WAVNUM', 
                         cmap = cmap, norm = norm,
                         cbar_kwargs = dict(orientation = 'vertical',
                                            pad = 0.075, fraction = 0.05, 
                                            ticks = np.arange(0.5, 5 + 1.5)))
        fg.set_titles(pad = 15)
        fg.set_ylabels('Wave period [s]', labelpad = 20)
        fg.set_xlabels('Wave to direction [$^\circ$]', labelpad = 0)              
        
        # set colorbar axes properties        
        fg.cbar.set_label('max 5 partitions', labelpad = 10)
        fg.cbar.set_ticklabels(ticklabels=[str(lbl) for lbl in np.arange(0, 5 + 1)])            
        fg.cbar.ax.tick_params(labelsize=8)        
        fg.cbar.ax.set_title('partitions',size=10)
        return fg
    
    elif len(part.dims) == 2:
        # one 2d spectrum
        # use traditional plotting        
        fig = plt.figure(figsize = (5, 5))
        ax = plt.subplot(111, projection = 'polar')
        cax = plt_part(part, x ='DIRECTION', y = 'WAVNUM',
                       ax = ax, cmap = cmap, norm = norm)
        cbar = fig.colorbar(cax, orientation = 'vertical',
                            pad=0.075, fraction=0.05, 
                            ticks = np.arange(0.5, 5 + 1.5))
        cbar.set_label('max 5 partitions', labelpad = 10)
        cbar.set_ticklabels(ticklabels=[str(lbl) for lbl in np.arange(0, 5 + 1)])            
        cbar.ax.tick_params(labelsize=8)        
        cbar.ax.set_title('partitions',size=10)
        ax.set_ylabel('Wave period [s]', labelpad = 20)
        ax.set_xlabel('Wave to direction [$^\circ$]')
        if part.coords['TIME']:
            ax.set_title(part.TIME.data)        
        return fig
            
    else:
        sys.exit('part dimensions are not correct, only 2d spec part plots are supported.')