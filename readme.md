# Account initialisation

Copy all the following files into `volumes/credentials`:
- auth.txt
- client.ovpn
- pal.json
- password.txt

```
cd /go/go-pal/datadir
pal account new --datadir ./pal-node-1 --password ./password.txt
```

Update `PAL_N1_ETHERBASE` with account address

**On AWS, be sure to mount EBS volume instead of using volumnes/credentials**