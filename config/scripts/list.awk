BEGIN {
        mask=1}
match($0, /^CPU ([0-9]+)\/KVM,([0-9]+)$/,m) {
        print "taskset -p "mask" "m[2]
        mask *= 2}

