log=$1

# check OS type

system=`uname`

#echo $system

if [ "$system" != "Darwin" ] && [ "$system" != "Linux" ];then

printf "\nError: Only Mac or Linux supported.\n"

exit

fi

if [ ! -e "$log" ];then

printf "\nError: Log $file is not found.\n"

exit

else

printf "\nSystem is $system and log file $log is found, proceeding....\n"

fi

if [ "$system" == "Darwin" ];then

timestamps=`egrep '^2019' $log  | cut -d: -f1-3 | awk 'NR==1{print $1, $2}END{print $1, $2}'`

array=($timestamps)

endtime=`date -j -f "%Y.%m.%d %H:%M:%S" "${array[2]} ${array[3]}" +"%s"`

starttime=`date -j -f "%Y.%m.%d %H:%M:%S" "${array[0]} ${array[1]}" +"%s"`

logsize=`wc -c $log | cut -d " " -f2`

elif [ "$system" == "Linux" ];then

timestamps=(`egrep '^2019' $log | cut -d: -f1-3 | awk '{gsub (/\./, "-");if (NR==1)a=$1" "$2}END{print a,$1, $2}'`)

array=($timestamps)

endtime=`date -d "${array[2]} ${array[3]}" +%s`

starttime=`date -d "${array[0]} ${array[1]}" +%s`

logsize=`wc -c $log | cut -d " " -f1`

fi

delta=`expr $endtime - $starttime`

printf "\n$log is $logsize bytes and duration is $delta seconds.\n"

 for channel in `awk -F "|" '/^2019/{print $3}' $log |sed 's/^ //' | sed 's/ $//' |sort | uniq`;do

 channel_size=$(bwTrafficParser -m "\| $channel" $log | wc -c)

 channel_perc=`echo "scale=4;($channel_size / $logsize) * 100" | bc`

 echo "Channel $channel $channel_size $channel_perc %" >> $log.tmp

 printf "processed $channel               \r"

 done

 cat $log.tmp | sort -rn -k3 | column -t

 rm $log.tmp 2> /dev/null

echo "-----------------------------------------------"

 

exit

 