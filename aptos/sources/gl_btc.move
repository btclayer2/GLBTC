module oft::gl_bitcoin {
    use layerzero::endpoint::UaCapability;
    use layerzero_apps::oft;
    use std::vector;
    use aptos_std::type_info::TypeInfo;

    struct GlobalLiquidityBTC {}

    struct Capabilities has key {
        lz_cap: UaCapability<GlobalLiquidityBTC>,
    }

    fun init_module(account: &signer) {
        initialize(account);
    }

    public fun initialize(account: &signer) {
        let lz_cap = oft::init_oft<GlobalLiquidityBTC>(account, b"Global Liquidity Bitoin", b"glBTC", 8, 6);

        move_to(account, Capabilities {
            lz_cap,
        });
    }

    // should provide lz_receive() and lz_receive_types()
    public entry fun lz_receive(src_chain_id: u64, src_address: vector<u8>, payload: vector<u8>) {
        oft::lz_receive<GlobalLiquidityBTC>(src_chain_id, src_address, payload)
    }

    #[view]
    public fun lz_receive_types(_src_chain_id: u64, _src_address: vector<u8>, _payload: vector<u8>): vector<TypeInfo> {
        vector::empty<TypeInfo>()
    }

    #[test_only]
    use std::signer::address_of;
    #[test_only]
    use layerzero::remote;
    #[test_only]
    use layerzero::test_helpers;
    #[test_only]
    use std::option;
    #[test_only]
    use aptos_framework::coin;
    #[test_only]
    use std::bcs;
    #[test_only]
    use layerzero_common::packet;

    #[test(
        aptos = @aptos_framework,
        core_resources = @core_resources,
        layerzero = @layerzero,
        msglib_auth = @msglib_auth,
        oracle = @1234,
        relayer = @5678,
        executor = @1357,
        executor_auth = @executor_auth,
        oft = @oft,
        alice = @0xABCD,
        bob = @0xAABB
    )]
    fun test_send_and_receive_oft(
        aptos: &signer,
        core_resources: &signer,
        layerzero: &signer,
        msglib_auth: &signer,
        oracle: &signer,
        relayer: &signer,
        executor: &signer,
        executor_auth: &signer,
        oft: &signer,
        alice: &signer,
        bob: &signer
    ) {
        oft::setup(
            aptos,
            core_resources,
            &vector[
                address_of(layerzero),
                address_of(msglib_auth),
                address_of(oracle),
                address_of(relayer),
                address_of(executor),
                address_of(executor_auth),
                address_of(oft),
                address_of(alice),
                address_of(bob),
            ],
        );

        // prepare the endpoint
        let local_chain_id: u64 = 20030;
        let remote_chain_id: u64 = 20030;
        test_helpers::setup_layerzero_for_test(
            layerzero,
            msglib_auth,
            oracle,
            relayer,
            executor,
            executor_auth,
            local_chain_id,
            remote_chain_id
        );

        // user address
        let (alice_addr, bob_addr) = (address_of(alice), address_of(bob));
        let (alice_addr_bytes, bob_addr_bytes) = (bcs::to_bytes(&alice_addr), bcs::to_bytes(&bob_addr));

        // init oft
        initialize(oft);

        // config oft
        let (local_oft_addr, remote_oft_addr) = (@oft, @oft);
        let (local_oft_addr_bytes, remote_oft_addr_bytes) = (bcs::to_bytes(&local_oft_addr), bcs::to_bytes(
            &remote_oft_addr
        ));
        remote::set(oft, remote_chain_id, remote_oft_addr_bytes);

        // mock packet for send oft to bob: remote chain -> local chain
        let nonce = 1;
        let (amount, amount_sd) = (100000, 1000); // 100000 / 100
        let payload = oft::encode_send_payload_for_testing(bob_addr_bytes, amount_sd);
        let emitted_packet = packet::new_packet(
            remote_chain_id,
            remote_oft_addr_bytes,
            local_chain_id,
            local_oft_addr_bytes,
            nonce,
            payload
        );
        test_helpers::deliver_packet<GlobalLiquidityBTC>(oracle, relayer, emitted_packet, 20);

        // bob doesn't receive coin for no registering
        lz_receive(local_chain_id, local_oft_addr_bytes, payload);
        assert!(oft::get_claimable_amount<GlobalLiquidityBTC>(bob_addr) == amount, 0);
        // coin is minted but locked
        assert!(*option::borrow(&coin::supply<GlobalLiquidityBTC>()) == (amount as u128), 0);
        assert!(oft::get_total_locked_coin<GlobalLiquidityBTC>() == amount, 0);

        // bob claim coin
        oft::claim<GlobalLiquidityBTC>(bob);
        assert!(oft::get_claimable_amount<GlobalLiquidityBTC>(bob_addr) == 0, 0);
        assert!(coin::balance<GlobalLiquidityBTC>(bob_addr) == amount, 0);
        assert!(oft::get_total_locked_coin<GlobalLiquidityBTC>() == 0, 0); // all locked coin is released to bob

        // bob send some coin to alice on remote chain
        let amount = amount / 2;
        let (fee, _) = oft::quote_fee<GlobalLiquidityBTC>(
            remote_chain_id,
            alice_addr_bytes,
            amount,
            false,
            vector::empty<u8>(),
            vector::empty<u8>()
        );
        oft::send<GlobalLiquidityBTC>(
            bob,
            remote_chain_id,
            alice_addr_bytes,
            amount,
            amount,
            fee,
            0,
            vector::empty<u8>(),
            vector::empty<u8>()
        );

        // token is burned
        assert!(*option::borrow(&coin::supply<GlobalLiquidityBTC>()) == (amount as u128), 0);
        assert!(coin::balance<GlobalLiquidityBTC>(bob_addr) == amount, 0);
    }

    #[test(
        aptos = @aptos_framework,
        core_resources = @core_resources,
        layerzero = @layerzero,
        msglib_auth = @msglib_auth,
        oracle = @1234,
        relayer = @5678,
        executor = @1357,
        executor_auth = @executor_auth,
        oft = @oft,
    )]
    fun test_receive_oft_with_zero_address_payload(
        aptos: &signer,
        core_resources: &signer,
        layerzero: &signer,
        msglib_auth: &signer,
        oracle: &signer,
        relayer: &signer,
        executor: &signer,
        executor_auth: &signer,
        oft: &signer,
    ) {
        oft::setup(
            aptos,
            core_resources,
            &vector[
                address_of(layerzero),
                address_of(msglib_auth),
                address_of(oracle),
                address_of(relayer),
                address_of(executor),
                address_of(executor_auth),
                address_of(oft),
            ],
        );

        // prepare the endpoint
        let local_chain_id: u64 = 20030;
        let remote_chain_id: u64 = 20030;
        test_helpers::setup_layerzero_for_test(
            layerzero,
            msglib_auth,
            oracle,
            relayer,
            executor,
            executor_auth,
            local_chain_id,
            remote_chain_id
        );

        // init oft
        initialize(oft);

        // config oft
        let (local_oft_addr, remote_oft_addr) = (@oft, @oft);
        let (local_oft_addr_bytes, remote_oft_addr_bytes) = (bcs::to_bytes(&local_oft_addr), bcs::to_bytes(
            &remote_oft_addr
        ));
        remote::set(oft, remote_chain_id, remote_oft_addr_bytes);

        // mock packet for send oft to invalid address
        let nonce = 1;
        let payload = oft::encode_send_payload_for_testing(x"0000000000000000000000000000000000000000000000000000000000000000", 1000);
        let emitted_packet = packet::new_packet(
            remote_chain_id,
            remote_oft_addr_bytes,
            local_chain_id,
            local_oft_addr_bytes,
            nonce,
            payload
        );
        test_helpers::deliver_packet<GlobalLiquidityBTC>(oracle, relayer, emitted_packet, 20);

        // drop the payload and coin gets locked
        lz_receive(local_chain_id, local_oft_addr_bytes, payload);
        assert!(*option::borrow(&coin::supply<GlobalLiquidityBTC>()) == 100000, 0); //local decimal 5, shared decimal 3, ld2sd_rate 100
        assert!(oft::get_total_locked_coin<GlobalLiquidityBTC>() == 100000, 0);
        assert!(oft::get_claimable_amount<GlobalLiquidityBTC>(@0x0) == 100000, 0);
    }
}