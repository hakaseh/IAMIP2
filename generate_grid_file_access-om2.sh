### IAMIP2 post-processing script for generating grid data for ACCESS-OM2
### by Hakase Hayashida
### 2022-07-01


module load cdo

invar=(algal_N PP_net aice hi hs skl_Nit fswthru_ai)
outvar=(phycbi intppbi siconc sivol snvol no3bi parbi)
inuni=('mmol N m-2' 'mg C m-2 d-1' '1' 'm' 'm' 'mmol m-2' 'W m-2')
outuni=('mol m-3' 'mol m-2 s-1' '%' 'm' 'm' 'mol m-3' 'W m-2')
longnam=(
	'Bottom-ice algae carbon concentration over grid cell area'
    'Vertically integrated primary organic carbon production by bottom-ice algae over grid cell area'
    'Percentage of grid cell covered by sea ice'
    'Sea ice thickness (sea-ice volume divided by grid cell area)'
    'Snow thickness (snow volume divided by grid cell area)'
    'Bottom-ice dissolved nitrate concentration over grid cell area'
    'Downwelling photosynthetic radiance flux at bottom ice over grid cell area'
	)
confac=(1e-3/0.03*106/16 1e-3 1e-3/12.011/86400 100 1 1 1e-3/0.03 1)
inexp=(his)
outexp=(historical)
yr0=(1958)

inpath=/g/data/ik11/outputs/access-om2/1deg_iamip2_his/output000/ice/OUTPUT/iceh.000-daily.nc
outpath=/g/data/v45/hh0162/projects/IAMIP2/ACCESS-OM2/ACCESS-OM2_grid.nc

ncks -O -v TLON,TLAT,tarea,tmask $inpath $outpath
ncrename -v TLON,longitude -v TLAT,latitude -v tarea,area -v tmask,mask -d nj,y -d ni,x $outpath
ncks -O -4 -L 9 $outpath $outpath
