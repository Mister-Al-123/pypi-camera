#!/bin/bash

# Loop through all files in the test2014 folder
for FILE in /home/alzy/Downloads/test/benchmarking-ml-on-the-edge/test2014/*; 
do
    # Print the filename being processed (debugging step)
    echo "Processing file: $FILE"

    # Get base file name
    basefile=$(basename $FILE)

    # Run the Python script and capture the output
    output="$(/home/alzy/Downloads/test/bin/python3 /home/alzy/Downloads/test/benchmarking-ml-on-the-edge/run_lite_rt.py --model /home/alzy/Downloads/test/benchmarking-ml-on-the-edge/mobilenet_v2.tflite --input "$FILE" --output /home/alzy/Downloads/test/COCO_OUT/"$basefile")"
    
    # Print the raw output from the Python script (debugging step)
    echo "Raw output: $output"
    
    # Extract the numeric value before 'ms' using grep and awk
    time=$(echo "$output" | grep -o '[0-9.]*' | awk 'NR==1 {print $1}')
    
    # Print the extracted time (debugging step)
    echo "Extracted time: $time"
    
    # Immediately append just the time (in ms) to the text file
    echo "$time" >> /home/alzy/Downloads/test/test.txt
done
