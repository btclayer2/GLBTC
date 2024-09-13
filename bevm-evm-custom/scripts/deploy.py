from pathlib import Path

from brownie import network, project, accounts, config, Contract
from brownie.network.account import Account

RAY = 10000


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


def load_project(net="bevm-test"):
    p = project.load(project_path=Path(__file__).parent.parent, raise_if_loaded=False)
    p.load_config()
    change_network(net)
    return p


def load_glbtc(net="bevm-test"):
    p = load_project(net)
    return Contract.from_abi("GLBTC", p["GLBTC"][-1].address, p["GLBTC"].abi)


def load_glbtc_adapter(net="bevm-test"):
    p = load_project(net)
    return Contract.from_abi("GLBTCAdapter", p["GLBTCAdapter"][-1].address, p["GLBTCAdapter"].abi)


def main(net="bevm-test"):
    p = load_project(net)

    # Deploy glbtc
    name = "GL-BTC"
    symbol = "GL-BTC"
    decimals = 8
    glbtc = p["GLBTC"].deploy(
        name,
        symbol,
        decimals,
        {"from": get_account(),
         "gas_price": "0.05 gwei"
         }
    )
    print(f"glbtc address:", glbtc)

    # deploy glbtc adapter
    # glbtc_adapter = p["GLBTCAdapter"].deploy(
    #     glbtc.address,
    #     11501,
    #     {"from": get_account(),
    #      "gas_price": "0.05 gwei"
    #      }
    # )
    # print(f"glbtc adapter address:", glbtc_adapter)


def transferOwnership(net="bevm-test"):
    glbtc = load_glbtc(net)
    # glbtc_adapter = load_glbtc_adapter(net)
    # GG
    owner = "0x82d54cb5036165560ad648dea1312c268d827da5"
    print(glbtc.address)
    # glbtc.transferOwnership(owner, {"from": get_account(), "gas_price": "0.05 gwei"})
    # glbtc_adapter.transferOwnership(owner, {"from": get_account(), "gas_price": "0.05 gwei"})


if __name__ == "__main__":
    # main("bevm-main")
    transferOwnership("bevm-main")
