# Deploy

~~~
# testnet
aptos move publish --url https://fullnode.testnet.aptoslabs.com

# mainnet
aptos move publish --url https://fullnode.mainnet.aptoslabs.com
~~~



# Config

1. Deps

   ~~~
   # LayerZero Testnet Addresses
    layerzero = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    layerzero_common = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    msglib_auth = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    msglib_v1_1 = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    msglib_v2 = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    zro = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    executor_auth = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    executor_v2 = "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3"
    layerzero_apps = "0x2f972c173927006c83277b6e6ae38f83482eba560f343d022f145979020d3621"
   
   #LayerZero Mainnet Addresses
   layerzero = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   layerzero_common = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   msglib_auth = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   msglib_v1_1 = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   msglib_v2 = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   zro = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   executor_auth = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   executor_v2 = "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90"
   layerzero_apps = "0x43d8cad89263e6936921a0adb8d5d49f0e236c229460f01b14dca073114df2b9"
   ~~~

2. Set Remote

   ~~~shell
   # Testnet
   aptos move run --max-gas 10000 --function-id "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3::remote::set" --args "u64:10106" hex:0x54005C207988294004Ab4a9B2DB3a32901fa9A36 --url https://fullnode.testnet.aptoslabs.com
   
   # Mainnet
   aptos move run --max-gas 10000 --function-id "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::remote::set" --args "u64:317" hex:0xF1783f15a94020AD8F3988d434F7ef3968bF303c --url https://fullnode.mainnet.aptoslabs.com
   ~~~

3. Set min gas

   ~~~shell
   # Testnet
   aptos move run --max-gas 10000 --function-id "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3::lzapp::set_min_dst_gas" --type-args "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b::gl_bitcoin::GlobalLiquidityBTC" --args "u64:10106" u64:0 u64:100000 --url https://fullnode.testnet.aptoslabs.com
   
   aptos move run --max-gas 10000 --function-id "0x1759cc0d3161f1eb79f65847d4feb9d1f74fb79014698a23b16b28b9cd4c37e3::lzapp::set_min_dst_gas" --type-args "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b::gl_bitcoin::GlobalLiquidityBTC" --args "u64:10106" u64:1 u64:100000 --url https://fullnode.testnet.aptoslabs.com
   
   # mainnet
   aptos move run --max-gas 10000 --function-id "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::lzapp::set_min_dst_gas" --type-args "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b::gl_bitcoin::GlobalLiquidityBTC" --args "u64:317" u64:0 u64:100000 --url https://fullnode.mainnet.aptoslabs.com
   
   aptos move run --max-gas 10000 --function-id "0x54ad3d30af77b60d939ae356e6606de9a4da67583f02b962d2d3f2e481484e90::lzapp::set_min_dst_gas" --type-args "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b::gl_bitcoin::GlobalLiquidityBTC" --args "u64:317" u64:1 u64:100000 --url https://fullnode.mainnet.aptoslabs.com
   ~~~

3. Send

   ~~~shell
   # Testnet 
   # aptos --> avax
   aptos move run --max-gas 10000 --function-id "0x2f972c173927006c83277b6e6ae38f83482eba560f343d022f145979020d3621::oft::send" --type-args "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b::gl_bitcoin::GlobalLiquidityBTC" --args "u64:10106" "hex:0000000000000000000000002dA7e3a7F21cCE79efeb66f3b082196EA0A8B9af" u64:100000  u64:100000 u64:209495245 u64:0 "hex:" "hex:" --url https://fullnode.testnet.aptoslabs.com
   
   # aptos -> bevm
   aptos move run --max-gas 10000 --function-id "0x43d8cad89263e6936921a0adb8d5d49f0e236c229460f01b14dca073114df2b9::oft::send" --type-args "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b::gl_bitcoin::GlobalLiquidityBTC" --args "u64:317" "hex:0000000000000000000000002dA7e3a7F21cCE79efeb66f3b082196EA0A8B9af" u64:1000  u64:1000 u64:50949524 u64:0 "hex:" "hex:" --url https://fullnode.mainnet.aptoslabs.com
   ~~~
   
   