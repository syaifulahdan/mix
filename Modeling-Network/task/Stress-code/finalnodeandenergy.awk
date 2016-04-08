#####################################################################
################http://www.ns2blogger.blogspot.in/###################
#####################################################################

BEGIN {
initialenergy=90
maxenergy=0
n=30
nodeid=999
}
{
# Trace line format: energy
event = $1
time = $2 
nodex=$11
nodey=$13
nodez=$15
if (event == "r" || event == "d" || event == "s"|| event== "f") {
node_id = $9
energy = $17
}
if (event== "N") {
node_id = $9
energy = $17
}
# Store remaining energy
finalenergy[node_id] = energy
posx[node_id] = nodex
posy[node_id] = nodey
posz[node_id] = nodez
}
END {
# Compute consumed energy for each node
for (i in finalenergy) {
consumenergy[i] = initialenergy-finalenergy[i]
totalenergy += consumenergy[i]
if(maxenergy < consumenergy[i]){
maxenergy = consumenergy[i]
nodeid = i
}
}
###compute average energy
averagenergy=totalenergy/n
####output
print("node no: xdir  ydir  zdir  energy"); 
for (i=0; i<n; i++) {
print("node",i,posx[i],posy[i],posz[i],consumenergy[i])
}
print("+===========+")
print("average energy",averagenergy)
print("+===========+")
print("total energy",totalenergy)

}
