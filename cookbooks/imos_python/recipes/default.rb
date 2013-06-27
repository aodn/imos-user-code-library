# Packages by Marty's request

# Maths & plotting (installs numpy as a dependency)
package "python-matplotlib"

# Connect to postgres db
package "python-psycopg2"

# email helper
package "python-beautifulsoup"

# NetCDF
package "libhdf5-serial-dev"
package "libnetcdf-dev"
python_pip "netCDF4" do
  action :install
end

# Optional but very useful
package "ipython"
package "python-scipy"
