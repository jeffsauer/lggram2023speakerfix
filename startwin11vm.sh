sudo /home/jsauer/Documents/myqemu/qemu-8.1.0/build/qemu-system-x86_64 -enable-kvm -hda win11.img -m 4G -smp 4 -device vfio-pci,host=0000:00:1f.3,x-no-mmap=true -trace events=/home/jsauer/Documents/qemu/events.txt -monitor stdio

