# Account initialisation

```
cd /go/go-pal/datadir
echo "<PASSWORD>" > password.txt
pal account new --datadir ./pal-node-1 --password ./password.txt
```

# Update .env

Update `PAL_N1_ETHERBASE` with account address