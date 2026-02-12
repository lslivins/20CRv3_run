#!/bin/tcsh

# 31 December 2019

# a script to monitor the job id 
# held in the local file
# current_jobid

# if current_jobid is not listed 
# resubmit 
# gfsenkf_20crV3_cmip5oz_new_knl.csh

# up to max_resubmit times

# updated 13 Nov 2020 to remove user "compo" hardcode
# and replace with ${username} determined from whoami


# find out what experiment is being run
set username=`whoami`
echo $username
setenv expname `basename $PWD`
set datadir=/global/cscratch1/sd/${username}/
setenv datapath "${datadir}/gfsenkf_20crV3_cmip5oz_CoriII/${expname}/"

echo $username $expname
echo $datapath

# find out the current analysis time

setenv startupenv "${datapath}/analdate.csh"
source $startupenv

echo "starting analdate $analdate"
set starting_analdate=$analdate

set start_jobid=`cat current_jobid | cut -c21-29`

# find out the status of the last submitted job id
set n_resubmit=0

set max_resubmit=3

# how long to sleep until next check
set nseconds=3600
set n_resubmit=0

set max_resubmit=30

while ($n_resubmit <= $max_resubmit)

	# get the current job id for this experiment
	set jobid=`cat current_jobid | cut -c21-29`

	# get the current analdate
	setenv startupenv "${datapath}/analdate.csh"
	source $startupenv
	
	echo $n_resubmit $analdate $jobid
	
	# might want: we are advancing analyses, reset the number of allowed resubmissions
	if ( ${analdate} > ${starting_analdate} && ${jobid} != ${start_jobid} ) then
		echo "job advancing, wait and watch"
		
		set start_jobid=`cat current_jobid | cut -c21-29`
		echo "consider this job $jobid the start_jobid"
		setenv startupenv "${datapath}/analdate.csh"
		source $startupenv

		echo "starting analdate $analdate"
		set starting_analdate=$analdate
		sleep $nseconds
	

	else # check the job code


		set jobcode=`squeue -u ${username} --jobs=$jobid -o "%t" | tail -n 1`

		# check the status of this check

		echo "$jobid is in state $jobcode"

		switch ($jobcode)
		# find out if the jobcode is any of the options that would 
		# keep from resubmitting
		# see list at https://slurm.schedmd.com/squeue.html

		# job cancelled
		case 'CA':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		# job completed
		case 'CD':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		# job configuring
		case 'CG':
			echo "wait and watch"
			sleep $nseconds
			breaksw	
		# job Pending
		case 'PD':
			echo "wait and watch"
			sleep $nseconds
			breaksw		
		# is job running
		case 'R':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		# is job held resv_del_hold
		case 'RD':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		# is job requeud resv_del_hold
		case 'RF':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		case 'RH':
			echo "wait and watch"
			sleep $nseconds
			breaksw	
		case 'RQ':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		# is job being Signaled
		case 'SI':
			echo "wait and watch"
			sleep $nseconds
			breaksw	
		# is job Staging Out files
		case 'SO':
			echo "wait and watch"
			sleep $nseconds
			breaksw
		# is job Suspended
		case 'S':
			echo "wait and watch"
			sleep $nseconds
			breaksw	
		default: 
			echo "$jobid not found pending, running, or another good state"
			echo " resubmit here"

			# resubmit
			sbatch gfsenkf_20crV3_cmip5oz_new_knl.csh > & ! current_jobid

			@ n_resubmit = $n_resubmit + 1
			breaksw
		endsw
	endif #$analdate > $starting_analdate
	echo " "
	echo " "
	echo `date`
	echo " "
end#while

echo "Reached limit of resubmissions"
echo `date`
echo $n_resubmit $analdate $jobid

exit 1

