# step 2

now that you have the validator addresses for L2 you can think about the L1 genesis file.

the idea here is to create a network using clique poa consensus to keep things simple and
to have at least 2 nodes running and acting as validators.  as the network is private it 
should be fine to keep these nodes also serving RPC traffic.

run the `create-l1.sh` script and enter a password in (you will need to do this twice)