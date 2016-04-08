    # a general script for computing throughput

    BEGIN {
    arguments = 2;
    if (ARGC < arguments || ARGC > arguments || flowtype == 0) {
    printf("error: wrong number of arguments.\nawk: usage â€“ awk -f flowcalc.awk [-v graphgran=value] [-v fidfrom=value] [-v fidto=value] [-v fid=value] -v flowtype=\"type\" -v outdata_file=\"filename\" indata_file\nâ€“%d",ARGC);
    exit;
    }
    measure_interval = 0.5;
    bits = 0;
    first_time = graphgran;
    }

    {
    if (($1 == "r") &&
    ((fidfrom == 0 && fidto ==0) || (($8 == fid) && ($3 == fidfrom) && ($4 == fidto))) &&
    (flowtype == "all" || flowtype == $5)) {
    if (($2 - first_time) > measure_interval) {
    first_time = first_time + measure_interval;
    rate = (bits/1000000)/first_time;
    print filename first_time, rate;
    }
    bits = bits + $6 * 8;
    }
    }
    END {
    measure_interval = 0.5;
    first_time = first_time + measure_interval;
    rate = (bits/1000000)/first_time;
    print filename first_time, rate;
    }

