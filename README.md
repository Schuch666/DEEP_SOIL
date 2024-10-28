# DEEP_SOIL

Repository to save updated instructions to run WRF using deep soil nudging options

## 1. Software:
### MADIS library
```
wget https://madis-data.ncep.noaa.gov/source/madis-4.3.tar.gz
```

### MADIS api to download the data
```
wget https://madis-data.ncep.noaa.gov/scripts/MADIS_archive_scripts-1.4.tar.gz
```

### MADIS to LITTLE r
```
wget https://www2.mmm.ucar.edu/wrf/src/MADIS2LITTLER_V1.2.tar.gz
```

### WRF OBSGRID
```
wget https://www2.mmm.ucar.edu/wrf/src/OBSGRID.tar.gz
```

### To update Soil Temperature

to update wrfinput soil temp. and soil hum. using wrfout from previous simulation used with WRF (this step is not required)

```
wget https://www2.mmm.ucar.edu/wrf/contributed/IPXWRF_WRFV3.1.tar.gz
```
## 2. To run MADIS (download observations to obsgrid), choose a folder to put the data:

```
export MADIS_DATA=/scratch/$USER/OBSGRID/MADIS_DATA

mkdir -p $MADIS_DATA/point/maritime/netcdf
mkdir -p $MADIS_DATA/point/metar/netcdf
mkdir -p $MADIS_DATA/point/sao/netcdf
mkdir -p $MADIS_DATA/LDAD/coop/netCDF
mkdir -p $MADIS_DATA/LDAD/mesonet/netCDF
mkdir -p $MADIS_DATA/LDAD/urbanet/netCDF
mkdir -p $MADIS_DATA/LDAD/crn/netCDF
mkdir -p $MADIS_DATA/LDAD/hcn/netCDF
mkdir -p $MADIS_DATA/LDAD/nepp/netCDF
mkdir -p $MADIS_DATA/LDAD/hfmetar/netCDF
mkdir -p $MADIS_DATA/point/raob/netcdf
mkdir -p $MADIS_DATA/point/profiler/netcdf
mkdir -p $MADIS_DATA/point/acars/netcdf
mkdir -p $MADIS_DATA/point/acarsProfiles/netcdf
mkdir -p $MADIS_DATA/point/radiometer/netcdf
mkdir -p $MADIS_DATA/LDAD/hydro/netCDF
mkdir -p $MADIS_DATA/LDAD/profiler/netCDF
mkdir -p $MADIS_DATA/point/HDW/netcdf
mkdir -p $MADIS_DATA/point/HDW1h/netcdf
mkdir -p $MADIS_DATA/point/POES/netcdf
mkdir -p $MADIS_DATA/point/satrad/netcdf
mkdir -p $MADIS_DATA/LDAD/snow/netCDF
mkdir -p $MADIS_DATA/LDAD/WISDOM/netCDF
```

**NOTE:** the variable **MADIS_DATA** can be exported to the environment

edit the time to download the data

```
nano ftp.par1.txt    ### set start/end
```

make sure to export MADIS_DATA variable (see above)

```
./get_MADIS_Data_unix.pl
## USE THIS!
## USER: anonymous
## PASS: anonymous
```

the (intermediary) data is in `$MADIS_DATA/point/metar/netcdf` folder

```
# next step need madis Lib
export MADIS_BIN=/scratch/$USER/OBSGRID/madis/bin
export MADIS_STATIC=/scratch/$USER/OBSGRID/madis/static
```

**NOTE:** the variable **MADIS_BIN** and **MADIS_STATIC** be exported to the environment


`nano api.par1.txt   ### set start/end`

NOTE from run_MADIS_API_unix.pl lines 124-127:
```
## # Line 4 start time in "YYYYMMDD HH" format
## my($stime) = shift(@pars);
## # Line 5 end time in "YYYYMMDD HH" format
## my($etime) = shift(@pars);
```

```./run_MADIS_API_unix.pl > log_run_api.txt```

The output: `sfcdump.txt`

## 3. MADIS to LITTLE r

input file:  `sfcdump.txt`

output files: `METAR_LITTLE_R_YYYY-MM-DD_HH`

```
# set MADIS_DATA,MADIS_STATIC,CODE_DIR
# set SDATE=YYYYMMDDHH and EDATE=YYYYMMDDHH
nano run_madis_to_little_r.ksh
./run_madis_to_little_r.ksh
```

the output is in `$MADIS_DATA/little_r_obs/YYYYMMDDHH/metar/METAR_LITTLE_R_YYYY-MM-DD_HH`

## 4. OBSGRID

input:  

a. `met_em` files from WPS

b. LITTLE r files from MADIS to LITTLE r (step 3)        

output: `wrfsfdda_d0*`

```
mkdir met
mkdir little_r
link or copy all the met_em and all little_r
cd met
ln -s /scratch/$USER/OBSGRID/met/met_em.d0* .
cd ../little_r
ln -s /scratch/$USER/OBSGRID/MADIS_DATA/little_r_obs/*/metar/METAR_LITTLE_R_* .
```

link all `met/little_r` files to OBSGRID root (folder that contains the obsgrid.exe)

script to link the files in little_r for obs:<date>
```
chmod +x create_links.sh
./create_links.sh
```

copy the original working obsgrid namelist
change the date
```
cp namelist.obsgrid.d01 namelist.oa
./obsgrid.exe > log.obsgrid.d01
```

change for the 2nd domain
```
cp namelist.obsgrid.d02 namelist.oa
./obsgrid.exe > log.obsgrid.d02
```

change for the 3rd the domain (and additional domains)
```
cp namelist.obsgrid.d02 namelist.oa
./obsgrid.exe > log.obsgrid.d03
```

NOTE about the namelist options:

- Recomended options
```
# to record4
qc_test_error_max = .TRUE.
qc_test_buddy = .TRUE.
qc_test_vert_consistency = .TRUE.
qc_test_convective_adj = .FALSE.
max_error_t = 8
max_error_uv = 4
max_error_z = 4
max_error_rh = 20
max_error_p = 600
max_buddy_t = 6
max_buddy_uv = 4
max_buddy_z = 4
max_buddy_rh = 20
max_buddy_p = 800
buddy_weight = 0.75
max_p_extend_t = 1300
max_p_extend_w = 1300

# to record7
use_first_guess = .TRUE.,
f4d = .TRUE.,
intf4d = 10800,

# to record9
oa_type = 'Cressman'
radius_influence = 20,15,10,5
```

To clean results from previsous run
```
rm *.nc qc_obs_* plotobs_out.d0* OBS_DOMAIN* obs:20* wrfsfdda_d0*
```
