#!/usr/bin/env python3

### Minimal Generic Software Accelerated ###
#
# This is this basic version of the PyPi Script
# which does not use any hardware acceleration.
# Should be compatible with any
# normal computer with a webcam.
#
### End ###

from datetime import datetime
from time import sleep
import cv2
import numpy as np
import subprocess

# Program Entry Point
if(__name__ == '__main__'):
    # Camera details
    fps = 20
    res = [1280,720]
    encode = "libx264"
    
    # Camera Module configure and start
    cam = cv2.VideoCapture(0)

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

    while True:
        # Frame retrieval
        result, frame = cam.read()

        if (result == False):
            frame = np.zeros((640,480), dtype=int)

        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
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

        # Send frame into ffmpeg
        live_output.stdin.write(frame.tobytes())
        sleep(1/fps)
