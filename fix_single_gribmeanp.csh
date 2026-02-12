# this is not actually a csh script at the moment
# 13 January 2018 G. Compo
#updated with more steps  (16 Jan 2018 G. Compo)
#updated with rm step (11 Feb 2018 G. Compo)

# just a step by step 
#
#1. first htar -xvf the date stamp that needs fixing to your output directory, e.g.
	# if in the archive_orig 
# cd /global/cscratch1/sd/compo/gfsenkf_20crV3_cmip5oz_CoriII/ensda_451_1904
# htar -xvf /home/projects/incite11/ensda_v451_archive_orig/ensda_451_1904/1905110118.tar

#2. mv any grb2 files in the date stamp directory to a holding location, e.g.
#	mkdir -p hold_1904_grb2_files 
#	mv ./1905110118/*grb2 ./hold_1904_grb2_files 

#3. the request and interactive allocation
###salloc -p debug -N 16 -t 10:00 -C haswell

#4. cut and paste the lines from #+ to #- to the interactive shell on Cori Haswell once it is allocated
#	in the directory with the name ensda_{experiment}_{stream_year}
#+
cd /global/u2/c/compo/coriII_home/20CRv3_scripts/ensda_451_1904
set path = ($path /global/cscratch1/sd/compo/20CRV3_CoriI_stripe4/bin/ )
setenv NNODESd5 16
setenv corespermpitaskd5 12


setenv basedir /global/cscratch1/sd/compo/20CRV3_CoriI_stripe4/
set datadir=/global/cscratch1/sd/$USER/
setenv expname `basename $PWD`
setenv spinyear `echo $expname | cut -c11-14`
setenv datapath "${datadir}/gfsenkf_20crV3_cmip5oz_CoriII/${expname}/"
echo $datadir

setenv enkfscripts $PWD
setenv enkfbin "${basedir}/enkf/trunk/src/global_enkf_new"
setenv incdate "${enkfscripts}/incdate"
setenv homedir $PWD
setenv ANALINC 6
setenv LONB 512  
setenv LATB 256  
setenv HOMEGLOBAL ${basedir}
setenv EXECGLOBAL ${basedir}/bin 
setenv IO $LONB 
setenv JO $LATB 
echo "DataPath: ${datapath}"


#5. change the analdate for the "next analysis time that would worked on"
#(to fix pgrbanl files this should 6 hours past what you are trying to fix

setenv analdate 1905110200

# previous analysis time.
setenv analdatem1 `${incdate} $analdate -$ANALINC`
set analdate_p3 = `${incdate} $analdatem1 3`

setenv datapath2 "${datapath}/${analdate}/"
setenv datapathm1 "${datapath}/${analdatem1}/"
setenv nanals 80
#-

#6. depending on which needs fixing, cut and paste the appropriate line
# for compute ens mean panl file
  time srun  -N $NNODESd5 -n $nanals -c $corespermpitaskd5 --cpu_bind=cores  ${EXECGLOBAL}/gribmeanp.x $datapathm1 $IO $JO $analdatem1 p anl  
  
# for compute ens mean panl+3 file
  time srun  -N $NNODESd5 -n $nanals -c $corespermpitaskd5 --cpu_bind=cores  ${EXECGLOBAL}/gribmeanp.x $datapathm1 $IO $JO $analdate_p3 p anl  
  
# for the pgrb fg files
time srun  -N $NNODESd5 -n $nanals -c $corespermpitaskd5 --cpu_bind=cores  ${EXECGLOBAL}/gribmeanp.x $datapath2 $IO $JO $analdate p fg 06 

# for the sflxf03 files
  time srun  -N $NNODESd5 -n $nanals -c $corespermpitaskd5 --cpu_bind=cores  ${EXECGLOBAL}/gribmeanp.x $datapath2 $LONB $LATB $analdate sflx fg 03  

# for the sflxf06 files
  time srun  -N $NNODESd5 -n $nanals -c $corespermpitaskd5 --cpu_bind=cores  ${EXECGLOBAL}/gribmeanp.x $datapath2 $LONB $LATB $analdate sflx fg 06 


#7. htar the directory back to where it came from
# 	htar -cvf /home/projects/incite11/ensda_v451_archive_orig/ensda_451_1904/1905110118.tar ./1905110118


#8.	rm everything should be cleaned up after the regular htar, e.g.
		cd ./1905110118

		/bin/rm -f sfg*mem*
		 
		/bin/rm -f sfg*ens*
		 
		/bin/rm -f bfg*mem* 
		
		/bin/rm -f bfg*ens* 
		
		/bin/rm -f sanl*mem* 
		
		/bin/rm -f sanl*ens* 
		
		/bin/rm -f sfcanl*mem*
		 
		/bin/rm -f sfcanl*ens* 
		
		/bin/rm -f fort* 
		
		/bin/rm -f diag*mem*
		 
		/bin/rm -f covinflate.dat
		 
		/bin/rm -f sflx*mem* 

#9. rm the grib1 versions of what remains that should be already be grb2
#10. convert to grib2 anything that needs it.
#	using /global/homes/c/cmccoll/bin/cnvgrib -g12 -nv $grb_file ${grb_file}.grb2 

#11. mv the other grb2 files back, e.g.,
#	mv ./hold_1904_grb2_files/*grb2  ./1905110118

# 12. rm any grib1 ensmean files


#13. run archive_grib2_monthly.csh on this stream month after going to the utilities directory
#	cd coriII_home/20CRv3_scripts/utilities/	
#	e.g., ./archive_grib2_monthly_ONLYforSpinup_useforFixingpgrbens.csh 451 1904 1905 11
# BUT if in production year:
	 ./archive_grib2_monthly.csh 451 1904 1905 11
