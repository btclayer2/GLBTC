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
        {"from": get_account()}
    )
    print(f"GLBTCOFT address:{glbtcoft.address}")


def setTrustedRemoteAddress(net="sepolia"):
    glbtcoft = load_glbtcoft(net)

    # aptos-mainnet
    # remoteChainID = 108
    # remoteAddress = "0x46f31ff67d1c18824d69dfc4dadaedf6d9e892464d191784527a40b8626bb419"

    # aptos-testnet
    remoteChainID = 10108
    remoteAddress = "0x46f31ff67d1c18824d69dfc4dadaedf6d9e892464d191784527a40b8626bb419"
    glbtcoft.setTrustedRemoteAddress(
        remoteChainID,
        remoteAddress,
        {"from": get_account()}
    )


def setMinDstGas(net="sepolia"):
    glbtcoft = load_glbtcoft(net)

    # aptos-mainnet
    # remoteChainID = 108
    # remoteAddress = "0x543c5660aa4d496687e2068c11765f04607c4f4b639a83233a9333604fb8ce59"

    # aptos-testnet
    remoteChainID = 10108
    glbtcoft.setMinDstGas(
        remoteChainID,
        0,
        100000,
        {"from": get_account()}
    )
    glbtcoft.setMinDstGas(
        remoteChainID,
        1,
        100000,
        {"from": get_account()}
    )


def sendFrom(net="sepolia"):
    glbtc = load_glbtc(net)
    glbtcoft = load_glbtcoft(net)
    acc = get_account()

    senderAddress = acc.address

    # aptos-testnet
    remoteChainID = 10108

    recipientAddress = "0x46f31ff67d1c18824d69dfc4dadaedf6d9e892464d191784527a40b8626bb419"
    amountToSend = int(0.1 * 1e8)

    param1 = 1  # uint16
    param2 = 200000  # uint256
    adapterParams = web3.codec.encode_abi(['uint16', 'uint256'], [param1, param2])

    glbtc.approve(glbtcoft.address, amountToSend, {"from": acc})

    glbtcoft.sendFrom(
        senderAddress,
        remoteChainID,
        recipientAddress,
        amountToSend,
        [
            senderAddress,  # refundAddress (address payable)
            "0x0000000000000000000000000000000000000000",  # zroPaymentAddress (address)
            "0x00010000000000000000000000000000000000000000000000000000000000030d40"
        ],
        {"from": acc,
         "value": int(0.2 * 1e18)
         }
    )


if __name__ == "__main__":
    # deploy_glbtcoft("avax-test")
    # setTrustedRemoteAddress("avax-test")
    # setMinDstGas("avax-test")
    sendFrom("avax-test")
