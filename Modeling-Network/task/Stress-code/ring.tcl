# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(stop)   1.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]
$ns rtproto DV

#Open the NS trace file
set tracefile [open out_ring.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out_ring.nam w]
$ns namtrace-all $namfile

#===================================
#        Nodes Definition        
#===================================
#Create 8 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

$n1 shape square
$n2 shape square



#memberi warna router 1 ke 5
$n1 color "red"
$n5 color "red"
#memberi warna router 2 ke 7
$n2 color "blue"
$n7 color "Blue"

#warna link
$ns color 1 red
$ns color 2 blue


#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n0 $n1 5.0Mb 1ms DropTail
$ns queue-limit $n0 $n1 50
$ns duplex-link $n2 $n1 5.0Mb 1ms DropTail
$ns queue-limit $n2 $n1 50
$ns duplex-link $n3 $n2 5.0Mb 1ms DropTail
$ns queue-limit $n3 $n2 50
$ns duplex-link $n3 $n4 5.0Mb 1ms DropTail
$ns queue-limit $n3 $n4 50
$ns duplex-link $n4 $n5 5.0Mb 1ms DropTail
$ns queue-limit $n4 $n5 50
$ns duplex-link $n5 $n6 5.0Mb 1ms DropTail
$ns queue-limit $n5 $n6 50
$ns duplex-link $n6 $n7 5.0Mb 1ms DropTail
$ns queue-limit $n6 $n7 50
$ns duplex-link $n7 $n0 5.0Mb 1ms DropTail
$ns queue-limit $n7 $n0 50 

#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient left-down
$ns duplex-link-op $n2 $n1 orient left-up
$ns duplex-link-op $n3 $n2 orient right-up
$ns duplex-link-op $n3 $n4 orient right-down
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n5 $n6 orient left-up
$ns duplex-link-op $n6 $n7 orient left-up
$ns duplex-link-op $n7 $n0 orient left-up

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n1 $tcp0
$tcp0 set class_ 1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

#Setup a UDP connection
set udp3 [new Agent/UDP]
$ns attach-agent $n2 $udp3
$udp3 set class_ 2
set null4 [new Agent/Null]
$ns attach-agent $n7 $null4
$ns connect $udp3 $null4
$udp3 set packetSize_ 1500


#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
#paket TCP dikirim di detik ke 0.10 sampai dengan menit ke 1.0
$ns at 0.10 "$ftp0 start"
$ns at 1.0 "$ftp0 stop"

#Setup a CBR Application over UDP connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp3
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 1.0Mb
$cbr1 set random_ null

#paket TCP dikirim di detik ke 0.5 sampai dengan menit ke 1.0
$ns at 0.05 "$cbr1 start"
$ns at 1.0 "$cbr1 stop"

# link terputus di jalur antara node6 ke node7 di detik ke 30
$ns rtmodel-at 0.30 down $n7 $n6
# link naik kembali di jalur antara node4 ke node5 di detik ke 3
$ns rtmodel-at 0.35 up  $n7 $n6
#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out_ring.nam &
    exit 0
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
