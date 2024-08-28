import {
    Account,
    AccountAddress,
    AnyNumber,
    Aptos,
    AptosConfig,
    Ed25519PrivateKey,
    InputViewFunctionData,
    Network,
    NetworkToNetworkName
} from "@aptos-labs/ts-sdk";
import * as dotenv from 'dotenv';

if (dotenv.config({path: ".env"}).error) {
    throw new Error(".env format error")
}

if (process.env.PRIVATE_KEY == null) {
    throw new Error(".env RELAYER_KEY not found")
}

function hexStringToBytes(hex: string): Uint8Array {
    if (hex.startsWith("0x")) {
        hex = hex.slice(2);
    }

    if (hex.length % 2 !== 0) {
        throw new Error("Invalid hex string length");
    }

    const bytes = new Uint8Array(hex.length / 2);

    for (let i = 0; i < hex.length; i += 2) {
        bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
    }

    return bytes;
}

const account = Account.fromPrivateKey({privateKey: new Ed25519PrivateKey(hexStringToBytes(process.env.PRIVATE_KEY))});

const APTOS_NETWORK: Network = NetworkToNetworkName[Network.DEVNET];

const config = new AptosConfig({
    network: APTOS_NETWORK
});
const aptos = new Aptos(config);

/** Admin forcefully transfers the newly created coin to the specified receiver address */
async function transferCoin(
    from: Account,
    toAddress: AccountAddress,
    amount: AnyNumber,
): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: from.accountAddress,
        data: {
            function: "0xbd4f4d25b0410220516389f153071949232993af1ca43a9257c936cf60448255::glbtc::transfer",
            functionArguments: [toAddress, amount],
        },
    });

    const senderAuthenticator = await aptos.transaction.sign({signer: from, transaction});
    const pendingTxn = await aptos.transaction.submit.simple({transaction, senderAuthenticator});

    return pendingTxn.hash;
}

/** Admin mint the newly created coin to the specified receiver address */
async function mintCoin(admin: Account, receiver: AccountAddress, amount: AnyNumber): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `0xbd4f4d25b0410220516389f153071949232993af1ca43a9257c936cf60448255::glbtc::mint`,
            functionArguments: [receiver, amount],
        },
    });

    const senderAuthenticator = await aptos.transaction.sign({signer: admin, transaction});
    const pendingTxn = await aptos.transaction.submit.simple({transaction, senderAuthenticator});

    return pendingTxn.hash;
}

/** Admin burns the newly created coin from the specified receiver address */
async function burnCoin(admin: Account, fromAddress: AccountAddress, amount: AnyNumber): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `0xbd4f4d25b0410220516389f153071949232993af1ca43a9257c936cf60448255::glbtc::burn`,
            functionArguments: [fromAddress, amount],
        },
    });

    const senderAuthenticator = await aptos.transaction.sign({signer: admin, transaction});
    const pendingTxn = await aptos.transaction.submit.simple({transaction, senderAuthenticator});

    return pendingTxn.hash;
}

/** Admin freezes the primary fungible store of the specified account */
async function freeze(admin: Account, targetAddress: AccountAddress): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `0xbd4f4d25b0410220516389f153071949232993af1ca43a9257c936cf60448255::glbtc::freeze_account`,
            functionArguments: [targetAddress],
        },
    });

    const senderAuthenticator = await aptos.transaction.sign({signer: admin, transaction});
    const pendingTxn = await aptos.transaction.submit.simple({transaction, senderAuthenticator});

    return pendingTxn.hash;
}

/** Admin unfreezes the primary fungible store of the specified account */
async function unfreeze(admin: Account, targetAddress: AccountAddress): Promise<string> {
    const transaction = await aptos.transaction.build.simple({
        sender: admin.accountAddress,
        data: {
            function: `0xbd4f4d25b0410220516389f153071949232993af1ca43a9257c936cf60448255::glbtc::unfreeze_account`,
            functionArguments: [targetAddress],
        },
    });

    const senderAuthenticator = await aptos.transaction.sign({signer: admin, transaction});
    const pendingTxn = await aptos.transaction.submit.simple({transaction, senderAuthenticator});

    return pendingTxn.hash;
}

const getGLbtcBalance = async (owner: AccountAddress, assetType: string): Promise<number> => {
    const data = await aptos.getCurrentFungibleAssetBalances({
        options: {
            where: {
                owner_address: {_eq: owner.toStringLong()},
                asset_type: {_eq: assetType},
            },
        },
    });

    return data[0]?.amount ?? 0;
};

/** Return the address of the managed fungible asset that's created when this module is deployed */
async function getMetadata(admin: Account): Promise<string> {
    const payload: InputViewFunctionData = {
        function: `0xbd4f4d25b0410220516389f153071949232993af1ca43a9257c936cf60448255::glbtc::get_metadata`,
        functionArguments: [],
    };
    const res = (await aptos.view<[{ inner: string }]>({payload}))[0];
    return res.inner;
}

// Specify which network to connect to via AptosConfig
async function main() {
    const metadataAddress = await getMetadata(account);
    console.log(`Metadata address:${metadataAddress}`)
    const mintCoinTransactionHash = await mintCoin(account, account.accountAddress, 100);
    await aptos.waitForTransaction({transactionHash: mintCoinTransactionHash});
    console.log(
        `Current fungible store balance: ${await getGLbtcBalance(account.accountAddress, metadataAddress)}.`,
    );

    const tmp_acc = new AccountAddress(hexStringToBytes("0xaa92e46ad151132bcbf4392eb4b10cd6060c28025988f47429aedc4e9a364fda"));
    const transferCoinTransactionHash = await transferCoin(account, tmp_acc, 100);
    await aptos.waitForTransaction({transactionHash: transferCoinTransactionHash});
    console.log(
        `Current fungible store balance: ${await getGLbtcBalance(tmp_acc, metadataAddress)}.`,
    );
}

main()