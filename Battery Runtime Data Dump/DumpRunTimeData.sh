#/bin/sh
###############################################################################################
# Inuput file is from MQTT simulator 
# Output file include data captured from input file
# eg. The tool get data of battery runtime data
# Usage: sh DumpRunTimeData.sh Input_file_name(which locate in the same directory)
# Writer: Andy Zhang 2019-01-10 V 0.1
###############################################################################################



RunTimeRemaining="topic  : UPSSystem/BatterySystem/RunTimeCalculation/Measure/RunTimeRemaining"
VoltageDC="topic  : UPSSystem/BatterySystem/Measure/VoltageDC"
CurrentDC="topic  : UPSSystem/BatterySystem/Measure/CurrentDC"

Input=$1
Output=${Input}_result.csv
Result=result.tmp
cnt=1
Current=0
Recrod_F=0
Recrod_N=0
echo NA > result_VoltageDC.tmp
echo NA > result_CurrentDC.tmp
echo NA, | tr '\n' ' ' > $Result

grep -e 'RunTimeRemaining' -e '-----20' $Input | grep -B1 'Time' > Timestamp.tmp
sed -i '/Time\|^--$/d' Timestamp.tmp
awk -F "----------" '{print $2}' Timestamp.tmp > Timestamp_.tmp

grep  -e 'E_VALUE' -e 'RunTimeRemaining' -e 'CurrentDC' -e 'VoltageDC' $Input > Value.tmp
grep -A1 -E 'VoltageDC|Time|CurrentDC' Value.tmp >Value_.tmp
sed -i '/^--$/d' value_.tmp


while read line
do
	let cnt=cnt+1
	echo ----------------------$cnt ------------------------
	if [ "$line" == "$RunTimeRemaining" ];then
		echo log the Voltage and Current Level
		line_1=$line
		VoltageDC_L=`tail -1 result_VoltageDC.tmp`
		CurrentDC_L=`tail -1 result_CurrentDC.tmp`
		echo $VoltageDC_L, | tr '\n' ' ' >> $Result
		echo $CurrentDC_L, >> $Result
		echo NA > result_VoltageDC.tmp
		echo NA > result_CurrentDC.tmp
		continue
	elif [ "$line" == "$VoltageDC" ];then
		line_1=$line
		continue
	elif [ "$line" == "$CurrentDC" ];then
		line_1=$line
		continue
	else
		echo	
	fi

	if [ "$line_1" == "$RunTimeRemaining" ];then
		echo log the Runtimeremaining Level
		echo $line, | tr '\n' ' ' >> $Result
	elif [ "$line_1" == "$VoltageDC" ];then
		echo $line >> result_VoltageDC.tmp
	elif [ "$line_1" == "$CurrentDC" ];then
		echo $line >> result_CurrentDC.tmp
	else
		echo
	fi
done < value_.tmp

sed -i 's/|->E_VALUE ://g' $Result
sed -i 's/^\|$/,/g' Timestamp_.tmp
nl Timestamp_.tmp > time.tmp
nl $Result > value.tmp
join time.tmp value.tmp > $Output
sed -i '1iNum,TimeStamp,RunTimeRemaining,VolatgeDC,CurrentDC' $Output


rm *.tmp



