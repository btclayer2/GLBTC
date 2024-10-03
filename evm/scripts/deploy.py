from pathlib import Path

from brownie import network, project, accounts, config, Contract, web3
from brownie.network.account import Account


def get_account() -> Account:
    acc = accounts.add(config["wallets"]["from_key"])
    print(f"Load acc:{acc.address}")
    return acc


def change_network(dst_net):
    if network.show_active() == dst_net:
        return
    if network.is_connected():
        network.disconnect()
    network.connect(dst_net)


def load_project(net="sepolia"):
    p = project.load(project_path=Path(__file__).parent.parent, raise_if_loaded=False)
    p.load_config()
    change_network(net)
    return p


def load_glbtc(net="sepolia"):
    p = load_project(net)
    addr = config["networks"][net]["glbtc"]
    return Contract.from_abi("GLBTC", addr, p["GLBTC"].abi)


def load_glbtcoft(net="sepolia"):
    p = load_project(net)
    addr = config["networks"][net]["glbtcoft"]
    return Contract.from_abi("GLBTCOFT", addr, p["GLBTCOFT"].abi)


def transferOwnership(net="sepolia"):
    glbtc = load_glbtc(net)
    # GG
    owner = "0x82d54cb5036165560ad648dea1312c268d827da5"
    print(glbtc.address)
    glbtc.transferOwnership(owner, {"from": get_account()})


def deploy_glbtc(net="sepolia"):
    p = load_project(net)
    name = "GL-BTC"
    symbol = "GL-BTC"
    decimals = 8
    glbtc = p["GLBTC"].deploy(
        name,
        symbol,
        decimals,
        {"from": get_account()}
    )
    print(f"glbtc address:", glbtc)
    if net in ["sepolia", "bevm-test", "avax-test"]:
        glbtc.mint(get_account(), int(10000 * pow(10, decimals)), {"from": get_account()})


def deploy_glbtcoft(net="sepolia"):
    p = load_project(net)
    glbtc = load_glbtc(net)

    token = glbtc.address
    _sharedDecimals = 8
    _lzEndpoint = config["networks"][net]["_lzEndpoint"]
    glbtcoft = p["GLBTCOFT"].deploy(
        token,
        _sharedDecimals,
        _lzEndpoint,
        {"from": get_account(), "gas_price": "0.05 gwei"}
    )
    print(f"GLBTCOFT address:{glbtcoft.address}")


def setTrustedRemoteAddress(net="sepolia", dst_net="aptos-mainnet"):
    glbtcoft = load_glbtcoft(net)

    # aptos-testnet
    remoteChainID = config["networks"][dst_net]["lzChainId"]
    remoteAddress = "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b"
    glbtcoft.setTrustedRemoteAddress(
        remoteChainID,
        remoteAddress,
        {"from": get_account(), "gas_price": "0.05 gwei"}
    )


def setMinDstGas(net="sepolia", dst_net="aptos-mainnet"):
    glbtcoft = load_glbtcoft(net)

    remoteChainID = config["networks"][dst_net]["lzChainId"]
    glbtcoft.setMinDstGas(
        remoteChainID,
        0,
        100000,
        {"from": get_account(), "gas_price": "0.05 gwei"}
    )
    glbtcoft.setMinDstGas(
        remoteChainID,
        1,
        100000,
        {"from": get_account(), "gas_price": "0.05 gwei"}
    )


def custom_encode_packed(types, values):
    result = b''
    for t, v in zip(types, values):
        if t == 'uint16':
            result += v.to_bytes(2, byteorder='big')
        elif t == 'uint256':
            result += web3.toBytes(v).rjust(32, b'\0')
        # 可以根据需要添加其他类型的处理
    return "0x" + result.hex()


def sendFrom(net="sepolia", dst_net="aptos-mainnet"):
    glbtc = load_glbtc(net)
    glbtcoft = load_glbtcoft(net)
    acc = get_account()

    senderAddress = acc.address

    # aptos-testnet
    remoteChainID = config["networks"][dst_net]["lzChainId"]

    recipientAddress = "0x8304621d9c0f6f20b3b5d1bcf44def4ac5c8bf7c11a1ce80b53778532396312b"
    amountToSend = int(0.0001 * 1e8)

    param1 = 1  # uint16
    param2 = 200000  # uint256
    adapterParams = custom_encode_packed(['uint16', 'uint256'], [param1, param2])

    # glbtc.approve(glbtcoft.address, amountToSend, {"from": acc, "gas_price": "0.05 gwei"})

    fee = glbtcoft.estimateSendFee(
        remoteChainID,
        recipientAddress,
        amountToSend,
        False,
        adapterParams
    )[0]

    glbtcoft.sendFrom.estimate_gas(
        senderAddress,
        remoteChainID,
        recipientAddress,
        amountToSend,
        [
            senderAddress,  # refundAddress (address payable)
            "0x0000000000000000000000000000000000000000",  # zroPaymentAddress (address)
            adapterParams
        ],
        {"from": acc,
         "value": fee,
         "gas_price": "0.05 gwei"
         }
    )


if __name__ == "__main__":
    # deploy_glbtc("bevm-main")
    # deploy_glbtcoft("bevm-main")
    # setMinDstGas(net="bevm-main", dst_net="aptos-mainnet")
    # setTrustedRemoteAddress("bevm-main", dst_net="aptos-mainnet")
    sendFrom(net="bevm-main", dst_net="aptos-mainnet")
