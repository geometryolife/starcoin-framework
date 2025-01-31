module StarcoinFramework::InstallPluginProposalPlugin{
    use StarcoinFramework::Option;
    use StarcoinFramework::DAOPluginMarketplace;
    use StarcoinFramework::DAOSpace::{Self, CapType};
    use StarcoinFramework::Vector;

    struct InstallPluginProposalPlugin has store, drop{}

    struct InstallPluginAction<phantom ToInstallPluginT> has store, drop {
        required_caps: vector<CapType>,
    }

    public fun initialize(_sender: &signer) {
        let witness = InstallPluginProposalPlugin{};

        DAOPluginMarketplace::register_plugin<InstallPluginProposalPlugin>(
            &witness,
            b"0x1::InstallPluginProposalPlugin",
            b"The plugin for install plugin proposal",
            Option::none(),
        );

        let implement_extpoints = Vector::empty<vector<u8>>();
        let depend_extpoints = Vector::empty<vector<u8>>();

        DAOPluginMarketplace::publish_plugin_version<InstallPluginProposalPlugin>(
            &witness,
            b"v0.1.0", 
            *&implement_extpoints,
            *&depend_extpoints,
            b"inner-plugin://install-plugin-proposal-plugin",
        );
    }

    public fun required_caps():vector<CapType>{
        let caps = Vector::singleton(DAOSpace::proposal_cap_type());   
        Vector::push_back(&mut caps, DAOSpace::install_plugin_cap_type());    
        caps
    }

    /// Create a proposal to install a plugin.
    /// We do not provide a entry function for create_proposal, because we can not use CapType as an entry function parameter, 
    /// every plugin should provide a entry function to create proposal to install self. 
    public fun create_proposal<DAOT: store, ToInstallPluginT: store>(sender: &signer, required_caps: vector<CapType>, title:vector<u8>, introduction:vector<u8>, extend: vector<u8>, action_delay: u64){
        let witness = InstallPluginProposalPlugin{};

        let cap = DAOSpace::acquire_proposal_cap<DAOT, InstallPluginProposalPlugin>(&witness);
        let action = InstallPluginAction<ToInstallPluginT>{
            required_caps,
        };

        DAOSpace::create_proposal(&cap, sender, action, title, introduction, extend, action_delay, Option::none<u8>());
    }

    public fun execute_proposal<DAOT: store, ToInstallPluginT: store>(sender: &signer, proposal_id: u64){
        let witness = InstallPluginProposalPlugin{};

        let proposal_cap = DAOSpace::acquire_proposal_cap<DAOT, InstallPluginProposalPlugin>(&witness);
        let InstallPluginAction{required_caps} = DAOSpace::execute_proposal<DAOT, InstallPluginProposalPlugin, InstallPluginAction<ToInstallPluginT>>(&proposal_cap, sender, proposal_id);
        
        let install_plugin_cap = DAOSpace::acquire_install_plugin_cap<DAOT, InstallPluginProposalPlugin>(&witness);
        DAOSpace::install_plugin<DAOT, InstallPluginProposalPlugin, ToInstallPluginT>(&install_plugin_cap, required_caps);
    }

    public (script) fun execute_proposal_entry<DAOT: store, ToInstallPluginT: store>(sender: signer, proposal_id: u64) {
        execute_proposal<DAOT, ToInstallPluginT>(&sender, proposal_id);
    }
}