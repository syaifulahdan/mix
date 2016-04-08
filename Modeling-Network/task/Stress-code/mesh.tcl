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
set tracefile [open out_mesh.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out_mesh.nam w]
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

$n1 shape hexagon
$n5 shape box

$n2 shape hexagon
$n7 shape box

#memberi warna router 1 ke 5
$n1 color "red"
$n5 color "red"
#memberi warna router 2 ke 7
$n2 color "blue"
$n7 color "blue"
#memberi label router 1 dan 5
$n1 label "n1: Src: FTP "
$n5 label "n5: Dest: FTP Sink"
#memberi label router 2 dan 7
$n2 label "n2: Src: UDP "
$n7 label "n7: Dest: Null"

#warna link
$ns color 1 blue
$ns color 2 red
#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n0 $n1 5.0Mb 10ms DropTail
$ns queue-limit $n0 $n1 50
$ns duplex-link $n1 $n2 100.0Mb 10ms DropTail
$ns queue-limit $n1 $n2 50
$ns duplex-link $n2 $n3 5.0Mb 10ms DropTail
$ns queue-limit $n2 $n3 50
$ns duplex-link $n3 $n4 5.0Mb 10ms DropTail
$ns queue-limit $n3 $n4 50
$ns duplex-link $n4 $n5 5.0Mb 10ms DropTail
$ns queue-limit $n4 $n5 50
$ns duplex-link $n5 $n6 5.0Mb 10ms DropTail
$ns queue-limit $n5 $n6 50
$ns duplex-link $n6 $n7 5.0Mb 10ms DropTail
$ns queue-limit $n6 $n7 50
$ns duplex-link $n7 $n0 5.0Mb 10ms DropTail
$ns queue-limit $n7 $n0 50
$ns duplex-link $n0 $n4 5.0Mb 10ms DropTail
$ns queue-limit $n0 $n4 50
$ns duplex-link $n2 $n6 5.0Mb 10ms DropTail
$ns queue-limit $n2 $n6 50
$ns duplex-link $n1 $n5 5.0Mb 10ms DropTail
$ns queue-limit $n1 $n5 50
$ns duplex-link $n7 $n3 5.0Mb 10ms DropTail
$ns queue-limit $n7 $n3 50

#Give node position (for NAM)
$ns duplex-link-op $n0 $n1 orient right-down
$ns duplex-link-op $n2 $n1 orient left-up
$ns duplex-link-op $n3 $n2 orient right-up
$ns duplex-link-op $n3 $n4 orient right-down
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n5 $n6 orient left-up
$ns duplex-link-op $n6 $n7 orient left-up
$ns duplex-link-op $n7 $n0 orient left-up
$ns duplex-link-op $n0 $n4 orient right-down
$ns duplex-link-op $n2 $n6 orient right-up
$ns duplex-link-op $n1 $n5 orient right-up
$ns duplex-link-op $n3 $n7 orient left-up

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n1 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500

#Setup a UDP connection
set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2
set null3 [new Agent/Null]
$ns attach-agent $n7 $null3
$ns connect $udp2 $null3
$udp2 set packetSize_ 1500


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
$cbr1 attach-agent $udp2
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 1.0Mb
$cbr1 set random_ null
#paket TCP dikirim di detik ke 0.5 sampai dengan menit ke 1.0
$ns at 0.05 "$cbr1 start"
$ns at 1.0 "$cbr1 stop"

#packet FTP dari node 1 ditujukan ke node 5 (secara Directly)
# link terputus di jalur antara node1 ke node5 di detik ke 30
#setelah link terputus packet UDP dari node 1 ditujukan ke node 5 packet di route kembali ke  (node 1 > node 2 > node 6 > node 5)
#$ns rtmodel-at 0.30 down $n5 $n1
# link naik kembali di jalur antara node5 ke node1 di detik ke 3
#$ns rtmodel-at 0.90 up  $n5 $n1

#packet UDP dari node 2 ditujukan ke node 7 via (node 2 > node 3 > node 7)
# link terputus di jalur antara node2 ke node3 di detik ke 30
#setelah link terputus packet UDP dari node 2 ditujukan ke node 7 di route kembali ke  (node 2 > node 6 > node 7)
$ns rtmodel-at 0.35 down $n2 $n3
# link naik kembali di jalur antara node2 ke node1 di detik ke 3
$ns rtmodel-at 0.90 up  $n2 $n3
#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out_mesh.nam &
    exit 0
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
