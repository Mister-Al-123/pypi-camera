#!/usr/bin/env python3

### Full Generic Software Accelerated ###
#
# This is this basic version of the PyPi Script
# which does not use any hardware acceleration.
# Should be compatible with any
# normal computer with a webcam.
#
### End ###

from datetime import datetime
from ai_edge_litert.interpreter import Interpreter
from time import sleep
import cv2
import numpy as np
import subprocess
import os

def detect_objects(frame):
    # Convert frame for model to read
    frame_size  = cv2.resize(frame, (width, height))
    frame_exp = np.expand_dims(frame_size, axis=0)

    # Model run 
    interpreter.set_tensor(input_details[0]['index'], frame_exp)
    interpreter.invoke()

    # Pull results and draw onto frame
    detected_boxes = interpreter.get_tensor(output_details[0]['index'])
    detected_classes = interpreter.get_tensor(output_details[1]['index'])
    detected_scores = interpreter.get_tensor(output_details[2]['index'])
    num_boxes = interpreter.get_tensor(output_details[3]['index'])
    
    detections = 0
    
    # Go through every box
    for i in range(int(num_boxes[0])):
        classId = int(detected_classes[0][i])
        # 0 is person
        if(classId == 0):
            detections += 1
            # Get confidence of each box and draw if 50% or higher confidence
            top, left, bottom, right = detected_boxes[0][i]
            score = detected_scores[0][i]
            if(score > 0.5):
                # Pull coordinates of bounding box
                ymin = int(top * res[1])
                xmin = int(left * res[0])
                ymax = int(bottom * res[1])
                xmax = int(right * res[0])

                # Draw rectangle onto numpy frame 
                cv2.rectangle(frame, (xmin, ymin), (xmax, ymax), (0,255,0), 2)
    
    # Return drawn frame and number of detections
    return frame, detections

# Program Entry Point
if(__name__ == '__main__'):
    os.chdir("/opt/pypi-camera")
    
    # Camera details
    fps = 15
    res = [640,480]
    encode = "libx264"
    
    # Camera Module configure and start
    cam = cv2.VideoCapture(0)

    # Object detection model load
    interpreter = Interpreter(
        model_path="model/mobilenet_v2.tflite",
        num_threads=4
    )
    interpreter.allocate_tensors()

    # Model detail pull
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    height = input_details[0]['shape'][1]
    width = input_details[0]['shape'][2]
 
    # Live Stream FFmpeg Process Start
    live_ffmpeg = [
        'ffmpeg',
	    '-hide_banner',
	    '-v', 'error',
        '-f', 'rawvideo',
        '-pix_fmt', 'rgb24',
        '-s', f'{res[0]}x{res[1]}',
        '-r', f'{fps}',
        '-i', '-',
        '-c:v', f'{encode}',
        '-tune', 'zerolatency',
        '-b:v', '2M',
        '-g', '10',
        '-f', 'rtsp',
        'rtsp://localhost:8554/live'
    ]
    live_output = subprocess.Popen(
        live_ffmpeg,
        stdin=subprocess.PIPE
    )

    # Recording variables
    recording = False
    cooldown = 0
    
    while True:
        # Frame retrieval
        result, frame = cam.read()

        if (result == False):
            frame = np.zeros((640,480), dtype=int)

        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Object detection function
        frame, detections = detect_objects(frame) 
        
        # Timestamp frame
        timestamp = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        cv2.putText(
            frame,
            timestamp,
            (2, 25),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.66,
            (127,127,127),
            1,
            cv2.LINE_AA
        )

        # Start recording if objects are found
    
        # Detection variable goes up to 5
        # even when no detectable objects are onscreen.
        if(detections > 5):
            if(recording == False):
                # Creates empty file for FFmpeg to write into
                filename = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
                filepath = f"/camera/{filename}.mp4"
                Path(filepath).touch()
                os.chmod(filepath, 0o777)
                
                # Creates new FFmpeg subprocess to put recording into
                file_ffmpeg = [
                    'ffmpeg',
                    '-hide_banner',
                    '-v', 'error',
                    '-f', 'rawvideo',
                    '-pix_fmt', 'rgb24',
                    '-s', f'{res[0]}x{res[1]}',
                    '-r', str(fps),
                    '-i', '-',
                    '-c:v', encode,
                    '-b:v', '2M',
                    '-f', 'mp4',
                    '-y',
                    f'/camera/{filename}.mp4'
                ]
                file_output = subprocess.Popen(
                    file_ffmpeg,
                    stdin=subprocess.PIPE
                )
                print(f"Recording started for {filename}.mp4")
                # Recording boolean used to enter code block that writes frame into file
                recording = True

            # Cooldown is 5 seconds
            cooldown = fps * 5 

        # Write frame to FFmpeg file
        if(recording == True):
            file_output.stdin.write(frame.tobytes())

            # If cooldown expired and no detections in last 5s
            cooldown -= 1
            if(cooldown <= 0):
                # Close FFmpeg process
                file_output.terminate()
                print(f"Video saved in /camera/{filename}.mp4")
                # Returns variables to original state
                recording = False

        # Send frame into ffmpeg
        live_output.stdin.write(frame.tobytes())
        sleep(1/fps)
