#Description
debian + CUDA 7.0.28 + ssh
#Requirement
Host with CUDA driver (v350.52) installed
#Build 
```
sudo docker build -t debian_cuda .
```
#Usage
```
sudo docker run -d \
	--restart always \
	--device /dev/nvidia0:/dev/nvidia0 \
	--device /dev/nvidiactl:/dev/nvidiactl \
	--device /dev/nvidia-uvm:/dev/nvidia-uvm \
	-p 22:22 \
	debian_cuda
```