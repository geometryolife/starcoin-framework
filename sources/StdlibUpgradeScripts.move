address StarcoinFramework {
/// The module for StdlibUpgrade init scripts
module StdlibUpgradeScripts {

    use StarcoinFramework::CoreAddresses;
    use StarcoinFramework::STC::{Self, STC};
    use StarcoinFramework::Token::{Self, LinearTimeMintKey};
    use StarcoinFramework::TreasuryWithdrawDaoProposal;
    use StarcoinFramework::Treasury::{Self, LinearWithdrawCapability};
    use StarcoinFramework::Offer;
    use StarcoinFramework::Timestamp;
    use StarcoinFramework::Collection;
    use StarcoinFramework::Oracle;
    use StarcoinFramework::STCUSDOracle;
    use StarcoinFramework::NFT;
    use StarcoinFramework::GenesisNFT;
    use StarcoinFramework::LanguageVersion;
    use StarcoinFramework::OnChainConfigDao;
    use StarcoinFramework::Config;
    use StarcoinFramework::GenesisSignerCapability;
    use StarcoinFramework::Account;
    use StarcoinFramework::Block;
    use StarcoinFramework::DAORegistry;
    use StarcoinFramework::DAOExtensionPoint;
    use StarcoinFramework::DAOPluginMarketplace;
    use StarcoinFramework::AnyMemberPlugin;
    use StarcoinFramework::ConfigProposalPlugin;
    use StarcoinFramework::GrantProposalPlugin;
    use StarcoinFramework::InstallPluginProposalPlugin;
    use StarcoinFramework::MemberProposalPlugin;
    use StarcoinFramework::MintProposalPlugin;
    use StarcoinFramework::StakeToSBTPlugin;
    use StarcoinFramework::UpgradeModulePlugin;
    use StarcoinFramework::StarcoinDAO;
    use StarcoinFramework::GasOracleProposalPlugin;
    use StarcoinFramework::Dao;
    use StarcoinFramework::TreasuryPlugin;
    use StarcoinFramework::TransactionPublishOption;
    use StarcoinFramework::VMConfig;
    use StarcoinFramework::ConsensusConfig;
    use StarcoinFramework::RewardConfig;
    use StarcoinFramework::TransactionTimeoutConfig;
    use StarcoinFramework::UpgradeModuleDaoProposal;
    use StarcoinFramework::ModifyDaoConfigProposal;
    use StarcoinFramework::WithdrawPlugin;

    spec module {
        pragma verify = false;
        pragma aborts_if_is_strict = true;
    }

    /// Stdlib upgrade script from v2 to v3
    public(script) fun upgrade_from_v2_to_v3(account: signer, total_stc_amount: u128) {
        CoreAddresses::assert_genesis_address(&account);

        let withdraw_cap = STC::upgrade_from_v1_to_v2(&account, total_stc_amount);

        let mint_keys = Collection::borrow_collection<LinearTimeMintKey<STC>>(CoreAddresses::ASSOCIATION_ROOT_ADDRESS());
        let mint_key = Collection::borrow(&mint_keys, 0);
        let (total, minted, start_time, period) = Token::read_linear_time_key(mint_key);
        Collection::return_collection(mint_keys);

        let now = Timestamp::now_seconds();
        let linear_withdraw_cap = Treasury::issue_linear_withdraw_capability(&mut withdraw_cap, total - minted, period - (now - start_time));
        // Lock the TreasuryWithdrawCapability to Dao
        TreasuryWithdrawDaoProposal::plugin(&account, withdraw_cap);
        // Give a LinearWithdrawCapability Offer to association, association need to take the offer, and destroy old LinearTimeMintKey.
        Offer::create(&account, linear_withdraw_cap, CoreAddresses::ASSOCIATION_ROOT_ADDRESS(), 0);
    }

    /// association account should call this script after upgrade from v2 to v3.
    public(script) fun take_linear_withdraw_capability(signer: signer) {
        let offered = Offer::redeem<LinearWithdrawCapability<STC>>(&signer, CoreAddresses::GENESIS_ADDRESS());
        Treasury::add_linear_withdraw_capability(&signer, offered);
        let mint_key = Collection::take<LinearTimeMintKey<STC>>(&signer);
        Token::destroy_linear_time_key(mint_key);
    }

    public fun do_upgrade_from_v5_to_v6(sender: &signer) {
        CoreAddresses::assert_genesis_address(sender);
        Oracle::initialize(sender);
        //register oracle
        STCUSDOracle::register(sender);
        NFT::initialize(sender);
        let merkle_root = x"5969f0e8e19f8769276fb638e6060d5c02e40088f5fde70a6778dd69d659ee6d";
        let image = b"ipfs://QmSPcvcXgdtHHiVTAAarzTeubk5X3iWymPAoKBfiRFjPMY";
        GenesisNFT::initialize(sender, merkle_root, 1639u64, image);
    }

    public(script) fun upgrade_from_v5_to_v6(sender: signer) {
        Self::do_upgrade_from_v5_to_v6(&sender)
    }

    public(script) fun upgrade_from_v6_to_v7(sender: signer) {
        Self::do_upgrade_from_v6_to_v7_with_language_version(&sender, 2);
    }

    /// deprecated, use `do_upgrade_from_v6_to_v7_with_language_version`.
    public fun do_upgrade_from_v6_to_v7(sender: &signer) {
        do_upgrade_from_v6_to_v7_with_language_version(sender, 2);
    }

    public fun do_upgrade_from_v6_to_v7_with_language_version(sender: &signer, language_version: u64) {
        // initialize the language version config.
        Config::publish_new_config(sender, LanguageVersion::new(language_version));
        // use STC Dao to upgrade onchain's move-language-version configuration.
        OnChainConfigDao::plugin<STC, LanguageVersion::LanguageVersion>(sender);
        // upgrade genesis NFT
        GenesisNFT::upgrade_to_nft_type_info_v2(sender);
    }

    public(script) fun upgrade_from_v7_to_v8(sender: signer) {
        do_upgrade_from_v7_to_v8(&sender);
    }

    public fun do_upgrade_from_v7_to_v8(sender: &signer) {
        {
            let cap = Oracle::extract_signer_cap(sender);
            GenesisSignerCapability::initialize(sender, cap);
        };

        {
            let cap = NFT::extract_signer_cap(sender);
            Account::destroy_signer_cap(cap);
        };
    }

    public(script) fun upgrade_from_v11_to_v12() {
        do_upgrade_from_v11_to_v12();
    }

    public fun do_upgrade_from_v11_to_v12() {
        let genessis_signer = GenesisSignerCapability::get_genesis_signer();
        Block::checkpoints_init();
        DAORegistry::initialize();

        DAOExtensionPoint::initialize();
        DAOPluginMarketplace::initialize();

        AnyMemberPlugin::initialize(&genessis_signer);
        ConfigProposalPlugin::initialize(&genessis_signer);
        GrantProposalPlugin::initialize(&genessis_signer);
        InstallPluginProposalPlugin::initialize(&genessis_signer);
        MemberProposalPlugin::initialize(&genessis_signer);
        MintProposalPlugin::initialize(&genessis_signer);
        StakeToSBTPlugin::initialize(&genessis_signer);
        UpgradeModulePlugin::initialize(&genessis_signer);
        GasOracleProposalPlugin::initialize(&genessis_signer);
        TreasuryPlugin::initialize(&genessis_signer);

        //TODO : config rate need mind
        // voting_delay: 60000 ms
        // voting_period: 3600000 ms
        // voting_quorum_rate: 4
        // min_action_delay: 3600000 ms
        let signer_cap = Account::get_genesis_capability();
        let upgrade_plan_cap = UpgradeModuleDaoProposal::get_genesis_upgrade_cap<STC>();
        StarcoinDAO::create_dao(signer_cap, upgrade_plan_cap, Dao::voting_delay<STC>(), Dao::voting_period<STC>(), Dao::voting_quorum_rate<STC>(), Dao::min_action_delay<STC>(), 1000 * 1000 * 1000 * 1000);

        StarcoinDAO::delegate_config_capability<STC, TransactionPublishOption::TransactionPublishOption>(
            OnChainConfigDao::config_cap<STC, TransactionPublishOption::TransactionPublishOption>());
        StarcoinDAO::delegate_config_capability<STC, VMConfig::VMConfig>(
            OnChainConfigDao::config_cap<STC, VMConfig::VMConfig>());
        StarcoinDAO::delegate_config_capability<STC, ConsensusConfig::ConsensusConfig>(
            OnChainConfigDao::config_cap<STC, ConsensusConfig::ConsensusConfig>());
        StarcoinDAO::delegate_config_capability<STC, RewardConfig::RewardConfig>(
            OnChainConfigDao::config_cap<STC, RewardConfig::RewardConfig>());
        StarcoinDAO::delegate_config_capability<STC, TransactionTimeoutConfig::TransactionTimeoutConfig>(
            OnChainConfigDao::config_cap<STC, TransactionTimeoutConfig::TransactionTimeoutConfig>());
        StarcoinDAO::delegate_config_capability<STC, LanguageVersion::LanguageVersion>(
            OnChainConfigDao::config_cap<STC, LanguageVersion::LanguageVersion>());

        let signer = GenesisSignerCapability::get_genesis_signer();
        let cap = TreasuryWithdrawDaoProposal::takeout_withdraw_capability<STC>(&signer);
        TreasuryPlugin::delegate_capability<STC>(&signer, cap);
        StarcoinDAO::set_treasury_withdraw_proposal_scale(100);

        // clean old DAO resources
        ModifyDaoConfigProposal::destroy_modify_config_capability<STC>(&genessis_signer);
    }

    public(script) fun upgrade_from_v12_to_v13() {
        do_upgrade_from_v12_to_v13();
    }

    public fun do_upgrade_from_v12_to_v13() {
        let genessis_signer = GenesisSignerCapability::get_genesis_signer();
        WithdrawPlugin::initialize(&genessis_signer);
        StarcoinDAO::upgrade_dao();
    }
}
}