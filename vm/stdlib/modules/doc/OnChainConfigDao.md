
<a name="0x1_OnChainConfigDao"></a>

# Module `0x1::OnChainConfigDao`



-  [Resource `WrappedConfigModifyCapability`](#0x1_OnChainConfigDao_WrappedConfigModifyCapability)
-  [Struct `OnChainConfigUpdate`](#0x1_OnChainConfigDao_OnChainConfigUpdate)
-  [Constants](#@Constants_0)
-  [Function `plugin`](#0x1_OnChainConfigDao_plugin)
-  [Function `propose_update`](#0x1_OnChainConfigDao_propose_update)
-  [Function `execute`](#0x1_OnChainConfigDao_execute)


<pre><code><b>use</b> <a href="Config.md#0x1_Config">0x1::Config</a>;
<b>use</b> <a href="Dao.md#0x1_Dao">0x1::Dao</a>;
<b>use</b> <a href="Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Token.md#0x1_Token">0x1::Token</a>;
</code></pre>



<a name="0x1_OnChainConfigDao_WrappedConfigModifyCapability"></a>

## Resource `WrappedConfigModifyCapability`



<pre><code><b>resource</b> <b>struct</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_WrappedConfigModifyCapability">WrappedConfigModifyCapability</a>&lt;TokenT, ConfigT: <b>copyable</b>&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cap: <a href="Config.md#0x1_Config_ModifyConfigCapability">Config::ModifyConfigCapability</a>&lt;ConfigT&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_OnChainConfigDao_OnChainConfigUpdate"></a>

## Struct `OnChainConfigUpdate`



<pre><code><b>struct</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_OnChainConfigUpdate">OnChainConfigUpdate</a>&lt;ConfigT: <b>copyable</b>&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: ConfigT</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_OnChainConfigDao_ERR_NOT_AUTHORIZED"></a>



<pre><code><b>const</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_ERR_NOT_AUTHORIZED">ERR_NOT_AUTHORIZED</a>: u64 = 401;
</code></pre>



<a name="0x1_OnChainConfigDao_plugin"></a>

## Function `plugin`



<pre><code><b>public</b> <b>fun</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_plugin">plugin</a>&lt;TokenT, ConfigT: <b>copyable</b>&gt;(signer: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_plugin">plugin</a>&lt;TokenT, ConfigT: <b>copyable</b>&gt;(signer: &signer) {
    <b>let</b> token_issuer = <a href="Token.md#0x1_Token_token_address">Token::token_address</a>&lt;TokenT&gt;();
    <b>assert</b>(<a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(signer) == token_issuer, <a href="Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(<a href="OnChainConfigDao.md#0x1_OnChainConfigDao_ERR_NOT_AUTHORIZED">ERR_NOT_AUTHORIZED</a>));
    <b>let</b> config_modify_cap = <a href="Config.md#0x1_Config_extract_modify_config_capability">Config::extract_modify_config_capability</a>&lt;ConfigT&gt;(signer);
    <b>let</b> cap = <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_WrappedConfigModifyCapability">WrappedConfigModifyCapability</a>&lt;TokenT, ConfigT&gt; { cap: config_modify_cap };
    move_to(signer, cap);
}
</code></pre>



</details>

<a name="0x1_OnChainConfigDao_propose_update"></a>

## Function `propose_update`

issue a proposal to update config of ConfigT goved by TokenT


<pre><code><b>public</b> <b>fun</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_propose_update">propose_update</a>&lt;TokenT: <b>copyable</b>, ConfigT: <b>copyable</b>&gt;(signer: &signer, new_config: ConfigT, exec_delay: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_propose_update">propose_update</a>&lt;TokenT: <b>copyable</b>, ConfigT: <b>copyable</b>&gt;(
    signer: &signer,
    new_config: ConfigT,
    exec_delay: u64,
) {
    <a href="Dao.md#0x1_Dao_propose">Dao::propose</a>&lt;TokenT, <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_OnChainConfigUpdate">OnChainConfigUpdate</a>&lt;ConfigT&gt;&gt;(
        signer,
        <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_OnChainConfigUpdate">OnChainConfigUpdate</a> { value: new_config },
        exec_delay,
    );
}
</code></pre>



</details>

<a name="0x1_OnChainConfigDao_execute"></a>

## Function `execute`



<pre><code><b>public</b> <b>fun</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_execute">execute</a>&lt;TokenT: <b>copyable</b>, ConfigT: <b>copyable</b>&gt;(proposer_address: address, proposal_id: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_execute">execute</a>&lt;TokenT: <b>copyable</b>, ConfigT: <b>copyable</b>&gt;(
    proposer_address: address,
    proposal_id: u64,
) <b>acquires</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_WrappedConfigModifyCapability">WrappedConfigModifyCapability</a> {
    <b>let</b> <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_OnChainConfigUpdate">OnChainConfigUpdate</a> { value } = <a href="Dao.md#0x1_Dao_extract_proposal_action">Dao::extract_proposal_action</a>&lt;
        TokenT,
        <a href="OnChainConfigDao.md#0x1_OnChainConfigDao_OnChainConfigUpdate">OnChainConfigUpdate</a>&lt;ConfigT&gt;,
    &gt;(proposer_address, proposal_id);
    <b>let</b> cap = borrow_global_mut&lt;<a href="OnChainConfigDao.md#0x1_OnChainConfigDao_WrappedConfigModifyCapability">WrappedConfigModifyCapability</a>&lt;TokenT, ConfigT&gt;&gt;(
        <a href="Token.md#0x1_Token_token_address">Token::token_address</a>&lt;TokenT&gt;(),
    );
    <a href="Config.md#0x1_Config_set_with_capability">Config::set_with_capability</a>(&<b>mut</b> cap.cap, value);
}
</code></pre>



</details>