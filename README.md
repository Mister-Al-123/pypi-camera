# pypi-camera

A project for a standalone security camera using Python on a Raspberry Pi

## Hardware and Equipment
### Full Install
- Raspberry Pi 5 or equivalent (CPU with similar power to BCM2712 like Intel N100)
- Camera attachment (Camera Module if using a Raspberry Pi/ USB Web Camera if using other computer)
- 128GB Storage or more (Must be mounted on / or /camera)
- Debian or Raspberry Pi OS (Or Forks)

### Minimal Install
- Raspberry Pi Zero 2W or equivalent (Any CPU capable of good H.264 encoding)
- Camera attachment (Camera Module if using a Raspberry Pi/ USB Web Camera if using other computer)
- Any amount of storage
- Debian or Raspberry Pi OS (Or Forks)

## Installation
### Full install (Includes object detection and web application)
`curl -fs -L https://raw.githubusercontent.com/Mister-Al-123/pypi-camera/refs/heads/basic/install/max-install.sh | sudo bash`
### Minimal install (Only camera feed)
`curl -fs -L https://raw.githubusercontent.com/Mister-Al-123/pypi-camera/refs/heads/basic/install/min-install.sh | sudo bash`

## Requirements
### Must
- [x] Live video feed 
- [x] Object detection active
- [x] Web application to access video feed
- [x] Easy Installation
- [x] Software running on boot
### Should
- [ ] Make system secure and robust
- [x] Record video whenever people are detected
- [x] Make software reproducible for other hardware
- [x] Software for pre-existing CCTV set ups
- [ ] Mobile application to access video feed
### Could
- [ ] Use hardware acceleration to improve back-end performance
- [ ] Create option select for object detection to include or exclude certain types of objects
