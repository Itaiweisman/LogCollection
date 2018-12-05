declare -a files=("/etc/path_to_inst" "/etc/name_to_major" "/etc/driver_aliases" "/var/log/syslog" "/var/adm/messages")
declare -a mfiles=()
declare -a directories=("/etc/driver/drv" "/kernel/drv" "/var/pkg" )
declare -a commands=("ls -la /dev" "ls -la /dev/dsk" "ls -la /dev/rdsk" "ls -la /dev/scsi/array_ctrl" "pkginfo -p" "pkginfo -i" "modinfo" "fcinfo lu -v" "fcinfo hba-port" "cfgadm -lao" "echo| format" "kstat -c disk" "mpathadm list lu" "ifconfig -a" "netstat -na" "netstat -nr" "iscsiadm list discovery" "iscsiadm list target -v" "iscsiadm list target -S" "iscsiadm list target-param -v" "iscsiadm list initiator-node" "iscsiadm list discovery-address -v" "iscsiadm list static-config" "svcs -a" "ls -la /dev/vx/dmp" "ls -la /dev/vx/rdmp")
declare -a logs=("/var/log")
log_time=4

date=`date +%m%d%y_%H%M%S`
out=/tmp/infini.collection.${date}
log=$out/collection.${date}.log
logto=$out/logs
cmdoutto=$out/commands
echo working dir is $out
mkdir $out || exit 
mkdir $cmdoutto
mkdir $logto
for i in "${files[@]}"
do
	if [ -f $i ] 
	then
		echo copying $i | tee -a $log
		cp $i $out >> $log 2>&1
	else
		echo $i could not be found | tee -a $log
	fi
done

for mfile in "${mfiles[@]}"
do
	dir=`echo $mfile | sed 's/\//_/g' | sed 's/\*//g'`
	mkdir $out/$dir
	echo copying $mfile as $dir | tee -a $log
	cp -r $mfile $out/$dir >> $log 2>&1
done

for dire in "${directories[@]}"
do
	dir=`echo $dire | sed 's/\//_/g' | sed 's/\*//g'`
	to_dir=$out/$dir
	mkdir $to_dir 
	echo copying $dir $out | tee -a $log
	cp -r $dire $to_dir >>  $log 2>&1
done

for cmd in "${commands[@]}" 
do
	f=`echo $cmd | awk  '{print $1}'`
	echo running $cmd | tee -a 
	output_to=`echo $cmd | sed 's/ /_/g'`
	#echo $cmd
	eval $cmd > $out/$output_to 2>&1
	
done


for flog in "${logs[@]}"
do
	for file in `find $flog -mtime -${log_time}`
	do
		cp $file $logto
	done

done 
tar cf /tmp/infi.collection.$date.tar $out && gzip /tmp/infi.collection.$date.tar | tee -a $log
if [ $? -eq 0 ] ; then 
	echo Log collection done - please send /tmp/infi.collection.$date.tar.gz to infinidat.
	echo you may also delete the temporary folder $out
else
	echo Warning - unable to compress log directory, please send $out manually to support
fi
	
