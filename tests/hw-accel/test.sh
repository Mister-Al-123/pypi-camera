while true
do
    current_time=$(date +"%H-%M-%S")
    cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')
    temp=$(vcgencmd measure_temp | sed "s/temp=//;s/'C//")
    echo "$current_time|cpu=$cpu_usage%|temp=$temp'C" >> test.txt
    sleep 10
done