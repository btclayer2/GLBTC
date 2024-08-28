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


def load_project(net="movement-test"):
    p = project.load(project_path=Path(__file__).parent.parent, raise_if_loaded=False)
    p.load_config()
    change_network(net)
    return p


def load_glbtc(net="movement-test"):
    p = load_project(net)
    return Contract.from_abi("GLBTC", p["GLBTC"][-1].address, p["GLBTC"].abi)


def main(net="movement-test"):
    p = load_project(net)

    # Deploy glbtc
    name = "GLBTC"
    symbol = "GLBTC"
    decimals = 8
    fromChain = 30732
    glbtc = p["GLBTC"].deploy(
        name,
        symbol,
        decimals,
        fromChain,
        {"from": get_account()}
    )
    print(f"glbtc address:", glbtc)


def transferOwnership(net="movement-test"):
    glbtc = load_glbtc(net)
    # GG
    owner = "0x209867e6430D75D0Aff27E217A6a51580Ef4C31e"
    glbtc.transferOwnership(owner, {"from": get_account()})


if __name__ == "__main__":
    main("movement-test")
    transferOwnership("movement-test")
