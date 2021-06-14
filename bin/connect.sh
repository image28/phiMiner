#!/bin/bash
SERVER="daggerhashimoto.eu-west.nicehash.com"
PORT="3353"

# Logs into a stratum clinet and gets work
function login()
{
    printf '%s' "$(cat connect.json)" | netcat -v -i1 -w10 $SERVER $PORT
}

function dag()
{
	login >> .workpipe
}

function work()
{
	DATE="`date +%Y.%j.%T`"
	login > joblog-$DATE
	
	DIFF=`cat joblog-$DATE | grep -iEo "mining.set_di[A-Z]{1,}\",\"params\":\[[0-9\.]{1,}" | grep -iEo "[0-9\.]{1,}$"`
	HEIGHT=`cat joblog-$DATE | grep -iEo "height\":[0-9]*" | grep -iEo "[0-9]*" | tail -n1`
	NONCE=`hexdump -n 8 -e '4/4 "%08X" 1 "\n"' /dev/random | tr -d ' '`
	JOBID=`cat joblog-$DATE | grep -iEo "job_id\":[0-9]*" | grep -iEo "[0-9]*" | tail -n1`
	
	echo "Working on jobid $JOBID on date $DATE at height $HEIGHT with nonce of $NONCE"
	#./phiMiner > worklog-$DATE
	 
	tail -f work-$DATE | while IFS='' read line; do
		echo $line | grep "mining.set_d" 2> /dev/null 1> /dev/null
		if test $? -eq 0;
		then	
			DIFF=`echo $line | grep -iEo "mining.set_di[A-Z]{1,}\",\"params\":\[[0-9\.]{1,}" | grep -iEo "[0-9\.]{1,}$"`
		fi
		
		echo $line | grep "null,\"method\":\"mining.not" 2> /dev/null 1> /dev/null
		if test $? -eq 0;
		then
			# add job
			echo
		fi
		
		
		WORK=`echo $line | grep -E --line-buffered "^nonce" | rev | awk -F' ' '{print $1 "," $2 "," $3 "," $4}' | rev &`
		
		submit "$NONCE" "$HEIGHT" "$JOBID" "$WORK"
		if test `pidof mean31x8` -ne 0
		then 
			echo "Solver thread has shutdown, shutting down in ten seconds..."
			sleep 10 && exit &
		fi
	done
}

function submit()
{
	#login;
	
	JOBID="$1"
	USER="341T2ew7f3aZafjfmhQWRhJ3VaA3pcHCCL"
	NONCE="$2"
	POW="$3"
	
	echo "Submitting work"
	printf '%s' "$(cat submit.json | sed -E s/HEIGHT/$USER/ | sed -E s/JOBID/$JOBID/ | sed -E s/NONCE/$NONCE/ | sed -E s/POW/$POW/)" # | netcat -v -i1 -q10 $SERVER $PORT;
	
}
