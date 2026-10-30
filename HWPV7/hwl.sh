#! /bin/bash

gnome-terminal -- bash -c "cd /home/menetekel/Documents/progriming/3.FS/; g++ Protokoll.cpp -lb15fdrv -o main && echo irgendwas | ./main; exec bash"

gnome-terminal -- bash -c "echo test; exec bash"
