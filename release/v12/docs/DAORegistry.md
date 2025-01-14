
<a name="0x1_DAORegistry"></a>

# Module `0x1::DAORegistry`



-  [Resource `DAORegistry`](#0x1_DAORegistry_DAORegistry)
-  [Resource `DAORegistryEntry`](#0x1_DAORegistry_DAORegistryEntry)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_DAORegistry_initialize)
-  [Function `register`](#0x1_DAORegistry_register)
-  [Function `next_dao_id`](#0x1_DAORegistry_next_dao_id)
-  [Function `dao_address`](#0x1_DAORegistry_dao_address)
-  [Module Specification](#@Module_Specification_1)


<pre><code><b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="GenesisSignerCapability.md#0x1_GenesisSignerCapability">0x1::GenesisSignerCapability</a>;
</code></pre>



<a name="0x1_DAORegistry_DAORegistry"></a>

## Resource `DAORegistry`

Global DAO registry info


<pre><code><b>struct</b> <a href="DAORegistry.md#0x1_DAORegistry">DAORegistry</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>next_dao_id: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_DAORegistry_DAORegistryEntry"></a>

## Resource `DAORegistryEntry`

Registry Entry for record the mapping between <code>DAOT</code> and <code>dao_address</code>


<pre><code><b>struct</b> <a href="DAORegistry.md#0x1_DAORegistry_DAORegistryEntry">DAORegistryEntry</a>&lt;DAOT&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dao_id: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>dao_address: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_DAORegistry_ERR_ALREADY_INITIALIZED"></a>



<pre><code><b>const</b> <a href="DAORegistry.md#0x1_DAORegistry_ERR_ALREADY_INITIALIZED">ERR_ALREADY_INITIALIZED</a>: u64 = 100;
</code></pre>



<a name="0x1_DAORegistry_initialize"></a>

## Function `initialize`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_initialize">initialize</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_initialize">initialize</a>(){
    <b>assert</b>!(!<b>exists</b>&lt;<a href="DAORegistry.md#0x1_DAORegistry">DAORegistry</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>()), <a href="Errors.md#0x1_Errors_already_published">Errors::already_published</a>(<a href="DAORegistry.md#0x1_DAORegistry_ERR_ALREADY_INITIALIZED">ERR_ALREADY_INITIALIZED</a>));
    <b>let</b> signer = <a href="GenesisSignerCapability.md#0x1_GenesisSignerCapability_get_genesis_signer">GenesisSignerCapability::get_genesis_signer</a>();
    <b>move_to</b>(&signer, <a href="DAORegistry.md#0x1_DAORegistry">DAORegistry</a>{next_dao_id: 1})
}
</code></pre>



</details>

<a name="0x1_DAORegistry_register"></a>

## Function `register`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_register">register</a>&lt;DAOT&gt;(dao_address: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_register">register</a>&lt;DAOT&gt;(dao_address: <b>address</b>): u64 <b>acquires</b> <a href="DAORegistry.md#0x1_DAORegistry">DAORegistry</a>{
    <b>let</b> genesis_account = <a href="GenesisSignerCapability.md#0x1_GenesisSignerCapability_get_genesis_signer">GenesisSignerCapability::get_genesis_signer</a>();
    <b>let</b> dao_id = <a href="DAORegistry.md#0x1_DAORegistry_next_dao_id">next_dao_id</a>();
    <b>move_to</b>(&genesis_account, <a href="DAORegistry.md#0x1_DAORegistry_DAORegistryEntry">DAORegistryEntry</a>&lt;DAOT&gt;{
        dao_id,
        dao_address,
    });
    dao_id
}
</code></pre>



</details>

<a name="0x1_DAORegistry_next_dao_id"></a>

## Function `next_dao_id`



<pre><code><b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_next_dao_id">next_dao_id</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_next_dao_id">next_dao_id</a>(): u64 <b>acquires</b> <a href="DAORegistry.md#0x1_DAORegistry">DAORegistry</a> {
    <b>let</b> dao_registry = <b>borrow_global_mut</b>&lt;<a href="DAORegistry.md#0x1_DAORegistry">DAORegistry</a>&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>());
    <b>let</b> dao_id = dao_registry.next_dao_id;
    dao_registry.next_dao_id = dao_id + 1;
    dao_id

}
</code></pre>



</details>

<a name="0x1_DAORegistry_dao_address"></a>

## Function `dao_address`



<pre><code><b>public</b> <b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_dao_address">dao_address</a>&lt;DAOT&gt;(): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="DAORegistry.md#0x1_DAORegistry_dao_address">dao_address</a>&lt;DAOT&gt;():<b>address</b> <b>acquires</b> <a href="DAORegistry.md#0x1_DAORegistry_DAORegistryEntry">DAORegistryEntry</a>{
    *&<b>borrow_global</b>&lt;<a href="DAORegistry.md#0x1_DAORegistry_DAORegistryEntry">DAORegistryEntry</a>&lt;DAOT&gt;&gt;(<a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>()).dao_address
}
</code></pre>



</details>

<a name="@Module_Specification_1"></a>

## Module Specification



<pre><code><b>pragma</b> verify = <b>false</b>;
<b>pragma</b> aborts_if_is_strict = <b>true</b>;
</code></pre>
