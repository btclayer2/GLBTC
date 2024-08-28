import { EndpointId } from '@layerzerolabs/lz-definitions'

import type { OAppOmniGraphHardhat, OmniPointHardhat } from '@layerzerolabs/toolbox-hardhat'
import {ExecutorOptionType} from "@layerzerolabs/lz-v2-utilities";

const sepoliaContract: OmniPointHardhat = {
    eid: EndpointId.SEPOLIA_V2_TESTNET,
    contractName: 'MyOFT',
}

const fujiContract: OmniPointHardhat = {
    eid: EndpointId.AVALANCHE_V2_TESTNET,
    contractName: 'MyOFT',
}

const config: OAppOmniGraphHardhat = {
    contracts: [
        {
            contract: fujiContract,
        },
        {
            contract: sepoliaContract,
        },
    ],
    connections: [
        {
            from: fujiContract,
            to: sepoliaContract,
            config: {
                // Optional Enforced Options Configuration
                // @dev Controls how much gas to use on the `to` chain, which the user pays for on the source `from` chain.
                enforcedOptions: [
                    {
                        msgType: 1, // depending on OAppOptionType3
                        optionType: ExecutorOptionType.LZ_RECEIVE,
                        gas: 60000, // gas limit in wei for EndpointV2.lzReceive
                        value: 0, // msg.value in wei for EndpointV2.lzReceive
                    },
                    {
                        msgType: 1,
                        optionType: ExecutorOptionType.NATIVE_DROP,
                        amount: 0, // amount of native gas token in wei to drop to receiver address
                        receiver: "0x0000000000000000000000000000000000000000",
                    },
                    {
                        msgType: 2,
                        optionType: ExecutorOptionType.LZ_RECEIVE,
                        index: 0,
                        gas: 60000, // gas limit in wei for EndpointV2.lzReceive
                        value: 0, // msg.value in wei for EndpointV2.lzReceive
                    },
                    {
                        msgType: 2,
                        optionType: ExecutorOptionType.COMPOSE,
                        index: 0, // index of EndpointV2.lzCompose message
                        gas: 60000, // gas limit in wei for EndpointV2.lzCompose
                        value: 0, // msg.value in wei for EndpointV2.lzCompose
                    },
                ],
            }
        },
        {
            from: sepoliaContract,
            to: fujiContract,
            config: {
                // Optional Enforced Options Configuration
                // @dev Controls how much gas to use on the `to` chain, which the user pays for on the source `from` chain.
                enforcedOptions: [
                    {
                        msgType: 1, // depending on OAppOptionType3
                        optionType: ExecutorOptionType.LZ_RECEIVE,
                        gas: 60000, // gas limit in wei for EndpointV2.lzReceive
                        value: 0, // msg.value in wei for EndpointV2.lzReceive
                    },
                    {
                        msgType: 1,
                        optionType: ExecutorOptionType.NATIVE_DROP,
                        amount: 0, // amount of native gas token in wei to drop to receiver address
                        receiver: "0x0000000000000000000000000000000000000000",
                    },
                    {
                        msgType: 2,
                        optionType: ExecutorOptionType.LZ_RECEIVE,
                        index: 0,
                        gas: 60000, // gas limit in wei for EndpointV2.lzReceive
                        value: 0, // msg.value in wei for EndpointV2.lzReceive
                    },
                    {
                        msgType: 2,
                        optionType: ExecutorOptionType.COMPOSE,
                        index: 0, // index of EndpointV2.lzCompose message
                        gas: 60000, // gas limit in wei for EndpointV2.lzCompose
                        value: 0, // msg.value in wei for EndpointV2.lzCompose
                    },
                ],
            }
        },
    ],
}

export default config
