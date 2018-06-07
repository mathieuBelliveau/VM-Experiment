#!/bin/bash
# ensure script is running as sudo
[ `whoami` = root ] || exec sudo "$0" "$@"

vmname="windows10vm"
if ps -A | grep -q $vmname; then
    echo "$vmname is already running." &
    exit 1
else
    timestamp=`date +%Y%m%d-%H%M%S`
    
    # use pulseaudio
    export QEMU_AUDIO_DRV=pa
    export QEMU_PA_SAMPLES=8192
    export QEMU_AUDIO_TIMER_PERIOD=99
    export QEMU_PA_SERVER=/run/user/1000/pulse/native
    
    # OVMF variables
    cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd
    
    # stop rdmsrs wdmsrs signals
    echo 1 >/sys/module/kvm/parameters/ignore_msrs
    
    # settings
    config_files="/home/ddgadmin/config/res"
    
    if [ ! -e logs ]; then
        mkdir logs
    elif [ ! -d logs ]; then
        echo failed to create logs folder >2
        exit 1
    fi
	
	#rm -f /home/ddgadmin/monitor
    
    2>"logs/$timestamp.log" \
    qemu-system-x86_64 \
        -name "$vmname,process=$vmname",debug-threads=on \
        -machine type=q35,accel=kvm -enable-kvm \
        -cpu host,kvm=off -smp 4,cores=4 \
        -m 6G -mem-path /run/hugepages/kvm -mem-prealloc \
        -soundhw hda \
	-vga none \
	-nographic \
        -usb -usbdevice host:046d:c332 \
             -usbdevice host:1b1c:1b33 \
             -usbdevice host:046d:0a4d \
        -device vfio-pci,host=01:00.0,multifunction=on \
        -device vfio-pci,host=01:00.1 \
        -device virtio-scsi-pci,id=scsi \
        -device virtio-net-pci,netdev=net0,mac=00:16:3e:00:01:01 \
        -netdev bridge,id=net0,br=br0 \
        -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
        -boot order=cd \
        -drive id=disk0,if=virtio,cache=none,format=raw,file=/dev/sda3 \
        -drive file="$config_files/virtio-win-0.1.141.iso",media=cdrom \
		#-monitor unix:/home/ddgadmin/monitor,server,nowait \
        #-drive file="$config_files/Windows10.iso",index=3,media=cdrom \
        #qemu-system-x86_64
    exit 0
fi

