### IAMIP2 post-processing script for ACCESS-OM2
### by Hakase Hayashida
###
### notes
###
### - currently assumes that all input are daily
### - one file for one year of data instead of concatenating all years because of memory issue on NCI.
### 1deg_iamip2_CMCC-ESM2ssp126/ 1deg_iamip2_con/             1deg_iamip2_EC-Earth3ssp585/ 1deg_iamip2_his/             
### 1deg_iamip2_CMCC-ESM2ssp585/ 1deg_iamip2_EC-Earth3ssp126/ 1deg_iamip2_exc/
###
### ACCESS-OM2_grid.nc  exclusion/          .ipynb_checkpoints/ ssp126-EC-Earth3/   ssp585-EC-Earth3/   
### control/            historical/         ssp126-CMCC-ESM2/   ssp585-CMCC-ESM2/
### yr0=(1958 for historical, 2015 for projection

module load cdo

invar=(PP_net algal_N aice hi hs skl_Nit fswthru_ai)
outvar=(intppbi phycbi siconc sivol snvol no3bi parbi)
inuni=('mg C m-2 d-1' 'mmol N m-2' '1' 'm' 'm' 'mmol m-2' 'W m-2')
outuni=('mol m-2 s-1' 'mol m-3' '%' 'm' 'm' 'mol m-3' 'W m-2')
longnam=(
    'Vertically integrated primary organic carbon production by bottom-ice algae over grid cell area'
	'Bottom-ice algae carbon concentration over grid cell area'
    'Percentage of grid cell covered by sea ice'
    'Sea ice thickness (sea-ice volume divided by grid cell area)'
    'Snow thickness (snow volume divided by grid cell area)'
    'Bottom-ice dissolved nitrate concentration over grid cell area'
    'Downwelling photosynthetic radiance flux at bottom ice over grid cell area'
	)
confac=(1e-3/12.011/86400 1e-3/0.03*106/16 100 1 1 1e-3/0.03 1)
inexp=(EC-Earth3ssp585)
outexp=(ssp585-EC-Earth3)
yr0=(2015)

indir=/g/data/ik11/outputs/access-om2/1deg_iamip2_
outdir=/g/data/v45/hh0162/projects/IAMIP2/ACCESS-OM2

#Loop over each experiment (e.g. historical)
for i in "${!inexp[@]}";
do
	#Loop over each variable (e.g. hi)
	for j in "${!invar[@]}";
	do
		#parallel
		{
		#Make directory for each variable and each experiment
		path2dir=${outdir}/${outexp[i]}/${outvar[j]}
		mkdir -p ${path2dir}
		#Set the start year before looping over each file
		yrnow=${yr0[i]}
		#Loop over each file
		for k in ${indir}${inexp[i]}/output???/ice/OUTPUT/iceh.???-daily.nc;
		do
			filnam=${outvar[j]}_day_IAMIP2_ACCESS-OM2_${outexp[i]}_${yrnow}.nc
			path2file=${path2dir}/${filnam}
			ncks -O -v ${invar[j]} ${k} ${path2file}
			ncap2 -O -s "${outvar[j]}=${invar[j]}*${confac[j]}" ${path2file} ${path2file}
			ncrename -v TLON,longitude -v TLAT,latitude -d nj,y -d ni,x ${path2file}
			ncatted -a units,${outvar[j]},o,c,"${outuni[j]}" ${path2file}
			ncatted -a long_name,${outvar[j]},o,c,"${longnam[j]}" ${path2file}
			ncks -O -x -v ${invar[j]} ${path2file} ${path2file}
			ncks -O --cnk_dmn time,1 ${path2file} ${path2file}
			cdo shifttime,-12hour ${path2file} ${path2file}.tmp
			mv ${path2file}.tmp ${path2file}
			ncks -O -4 -L 9 ${path2file} ${path2file}
			echo ${yrnow},${invar[j]},${inexp[i]}
			date
			yrnow=`expr ${yrnow} + 1`
		done
		} &
	done
done