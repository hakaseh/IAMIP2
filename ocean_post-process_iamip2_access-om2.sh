### IAMIP2 post-processing script for ACCESS-OM2
### by Hakase Hayashida
###
### notes
###
### - currently assumes that all input are daily
### - one file for one year of data instead of concatenating all years because of memory issue on NCI.

module load cdo

invar=(surface_temp surface_salt mld npp1 npp2d 
	pprod_gross_2d wdet100 radbio1 stf09 surface_no3 
	surface_fe surface_phy surface_zoo surface_det 
	surface_alk surface_adic)
outvar=(sst sss mldts2t intppos intpp intgp epc100 paros 
	fgco2 no3os dfeos phycos zoocos detcos talkos dissicos)
inuni=('K' 'PSU' 'm' 'mmol N m-2 s-1' 'mmol N m-2 s-1' 
	'mmol N m-2 s-1' 'mmol N m-2 s-1' 'W m-2' 
	'mmol C m-2 s-1' 'mmol N m-3' 'umol Fe m-3' 
	'mmol N m-3' 'mmol N m-3' 'mmol N m-3' 'mmol m-3' 
	'mmol m-3')
outuni=('C' 'PSU' 'm' 'mol C m-2 s-1' 'mol C m-2 s-1' 
	'mol C m-2 s-1' 'mol C m-2 s-1' 'W m-2' 'kg C m-2 s-1'
    'mol N m-3' 'mol Fe m-3' 'mol C m-3' 'mol C m-3' 
    'mol C m-3' 'mol m-3' 'mol m-3')
longnam=(
	'Sea surface temperature'
    'Sea surface salinity'
	'Ocean mixed layer thickness defined by sigma-t'
	'Vertically integrated primary organic carbon production by phytoplankton over sea surface layer'
	'Vertically integrated primary organic carbon production by phytoplankton'
	'Vertically integrated gross primary organic carbon production by phytoplankton'
	'Downward flux of particulate organic carbon at 100m'
	'Downwelling photosynthetic radiance flux at sea surface'
	'Sea surface downward flux of carbon dioxide'
	'Sea surface dissolved nitrate concentration'
	'Sea surface dissolved iron concentration'
	'Sea surface phytoplankton carbon concentration'
	'Sea surface zooplankton carbon concentration'
	'Sea surface detritus carbon concentration'
	'Sea surface total alkalinity'
	'Sea surface dissolved inorganic carbon concentration'
	)
confac=(273.15 1 1 1e-3*106/16 1e-3*106/16 1e-3*106/16 
	1e-3*106/16 1 1e-6*12.011 1e-3 1e-6 1e-3*106/16
	1e-3*106/16 1e-3*106/16 1e-3 1e-3)
inexp=(his)
outexp=(historical)
yr0=(1958)

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
		for k in ${indir}${inexp[i]}/output???/ocean/*-2d-${invar[j]}-*.nc;
		do
			filnam=${outvar[j]}_day_IAMIP2_ACCESS-OM2_${outexp[i]}_${yrnow}.nc
			path2file=${path2dir}/${filnam}
			ncks -O -v ${invar[j]} ${k} ${path2file}
			#Conversion is by subtraction for temperature.
			if [ ${invar[j]} == 'surface_temp' ]
			then
				ncap2 -O -s "${outvar[j]}=${invar[j]}-${confac[j]}" ${path2file} ${path2file}
			else
				ncap2 -O -s "${outvar[j]}=${invar[j]}*${confac[j]}" ${path2file} ${path2file}
			fi
			ncrename -v xt_ocean,longitude -v yt_ocean,latitude -d yt_ocean,y -d xt_ocean,x ${path2file}
			ncatted -a units,${outvar[j]},o,c,"${outuni[j]}" ${path2file}
			ncatted -a long_name,${outvar[j]},o,c,"${longnam[j]}" ${path2file}
			ncks -O -x -v longitude,latitude,${invar[j]} ${path2file} ${path2file}
			ncks -O --cnk_dmn time,1 ${path2file} ${path2file}
			ncks -O -4 -L 9 ${path2file} ${path2file}
			echo ${yrnow},${invar[j]},${inexp[i]}
			date
			yrnow=`expr ${yrnow} + 1`
		done
		} &
	done
done