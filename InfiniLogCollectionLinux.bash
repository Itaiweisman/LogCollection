declare -a files=("/etc/modprobe.conf" "/proc/mdstat" )
declare -a mfiles=("/sys/devices/pci*" "/etc/.*multipath.*" "/etc/.*tab" "/etc/iscsid.*" )
declare -a directories=("/etc/modprobe.d"   "/var/lib/iscsi" "/etc/iscsi" "/proc/scsi" "/sys/class" "/sys/module")
declare -a commands=("vgdisplay -v" "lvdisplay -v -all" "pvdisplay -v" "rpm -qa" "dpkg --get-selections" "systemctl --all" "service --status-all" "iscsiadm -m session" "iscsiadm -m node" "iscsiadm -m node -o show" "echo show config | multipathd -k" "echo show maps | multipathd -k" "echo show topology | multipathd -k" "echo show paths | multipathd -k" "sg_map -x || true" "fdisk -l" "modinfo qla2xxx" "modinfo qla4xxx" "modinfo lpfc" "modinfo fnic" "modinfo bfa" "netstat -na" "netstat -rn" )
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
	
