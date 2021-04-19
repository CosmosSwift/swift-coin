











``` shell


swift run nameservicecli keys add jack

swift run nameservicecli --help
swift run nameservicecli keys --help
swift run nameservicecli tx nameservice buy-name jack.id 5nametoken --from jack -y --chain-id toto --gas-price 1000
swift run nameservicecli keys list -n
swift run nameservicecli keys show jack -a

swift run nameservicecli query account --chain-id toto cosmos1fcte6snpz7fu477ve2cmu3d7fgkdtnn4ed95pj --node "http://127.0.0.1:26657"

swift run nameservicecli tx nameservice buy-name jack.id 5nametoken --from cosmos1fcte6snpz7fu477ve2cmu3d7fgkdtnn4ed95pj -y --chain-id toto --gas-price 1000 --node "http://127.0.0.1:26657"

swift run nameservicecli tx nameservice buy-name jack.id 5nametoken --from jack -y --chain-id toto --gas-price 1000 --node "http://127.0.0.1:26657"
swift run nameservicecli tx nameservice set-name jack.id 8.8.8.8 --from jack  --chain-id toto --gas-price 1000 --node "http://127.0.0.1:26657"

swift run nameservicecli  query account cosmos1fcte6snpz7fu477ve2cmu3d7fgkdtnn4ed95pj --chain-id toto --node "http://127.0.0.1:26657"

swift run nameservicecli query nameservice list-whois --chain-id toto --node "http://127.0.0.1:26657"
swift run nameservicecli query nameservice get-whois jack.id --chain-id toto --node "http://127.0.0.1:26657"
```
