
<a name="0x1_TransactionPublishOption"></a>

# Module `0x1::TransactionPublishOption`



-  [Struct `TransactionPublishOption`](#0x1_TransactionPublishOption_TransactionPublishOption)
-  [Constants](#@Constants_0)
-  [Function `initialize`](#0x1_TransactionPublishOption_initialize)
-  [Function `new_transaction_publish_option`](#0x1_TransactionPublishOption_new_transaction_publish_option)
-  [Function `is_script_allowed`](#0x1_TransactionPublishOption_is_script_allowed)
-  [Function `is_module_allowed`](#0x1_TransactionPublishOption_is_module_allowed)
-  [Function `add_to_script_allow_list`](#0x1_TransactionPublishOption_add_to_script_allow_list)
-  [Function `set_open_script`](#0x1_TransactionPublishOption_set_open_script)
-  [Function `set_open_module`](#0x1_TransactionPublishOption_set_open_module)
-  [Specification](#@Specification_1)


<pre><code><b>use</b> <a href="Config.md#0x1_Config">0x1::Config</a>;
<b>use</b> <a href="CoreAddresses.md#0x1_CoreAddresses">0x1::CoreAddresses</a>;
<b>use</b> <a href="Errors.md#0x1_Errors">0x1::Errors</a>;
<b>use</b> <a href="Signer.md#0x1_Signer">0x1::Signer</a>;
<b>use</b> <a href="Timestamp.md#0x1_Timestamp">0x1::Timestamp</a>;
<b>use</b> <a href="Vector.md#0x1_Vector">0x1::Vector</a>;
</code></pre>



<a name="0x1_TransactionPublishOption_TransactionPublishOption"></a>

## Struct `TransactionPublishOption`

Defines and holds the publishing policies for the VM. There are three possible configurations:
1. No module publishing, only allowlisted scripts are allowed.
2. No module publishing, custom scripts are allowed.
3. Both module publishing and custom scripts are allowed.
We represent these as the following resource.


<pre><code><b>struct</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>script_allow_list: vector&lt;vector&lt;u8&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>module_publishing_allowed: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_TransactionPublishOption_EINVALID_ARGUMENT"></a>



<pre><code><b>const</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EINVALID_ARGUMENT">EINVALID_ARGUMENT</a>: u64 = 18;
</code></pre>



<a name="0x1_TransactionPublishOption_EALLOWLIST_ALREADY_CONTAINS_SCRIPT"></a>

The script hash already exists in the allowlist


<pre><code><b>const</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EALLOWLIST_ALREADY_CONTAINS_SCRIPT">EALLOWLIST_ALREADY_CONTAINS_SCRIPT</a>: u64 = 1002;
</code></pre>



<a name="0x1_TransactionPublishOption_EINVALID_SCRIPT_HASH"></a>

The script hash has an invalid length


<pre><code><b>const</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EINVALID_SCRIPT_HASH">EINVALID_SCRIPT_HASH</a>: u64 = 1001;
</code></pre>



<a name="0x1_TransactionPublishOption_EPROLOGUE_ACCOUNT_DOES_NOT_EXIST"></a>



<pre><code><b>const</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EPROLOGUE_ACCOUNT_DOES_NOT_EXIST">EPROLOGUE_ACCOUNT_DOES_NOT_EXIST</a>: u64 = 0;
</code></pre>



<a name="0x1_TransactionPublishOption_SCRIPT_HASH_LENGTH"></a>



<pre><code><b>const</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_SCRIPT_HASH_LENGTH">SCRIPT_HASH_LENGTH</a>: u64 = 32;
</code></pre>



<a name="0x1_TransactionPublishOption_initialize"></a>

## Function `initialize`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_initialize">initialize</a>(account: &signer, merged_script_allow_list: vector&lt;u8&gt;, module_publishing_allowed: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_initialize">initialize</a>(
    account: &signer,
    merged_script_allow_list: vector&lt;u8&gt;,
    module_publishing_allowed: bool,
) {
    <a href="Timestamp.md#0x1_Timestamp_assert_genesis">Timestamp::assert_genesis</a>();
    <b>assert</b>(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == <a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>(),
        <a href="Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(<a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EPROLOGUE_ACCOUNT_DOES_NOT_EXIST">EPROLOGUE_ACCOUNT_DOES_NOT_EXIST</a>),
    );
    <b>let</b> transaction_publish_option = <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_new_transaction_publish_option">Self::new_transaction_publish_option</a>(merged_script_allow_list, module_publishing_allowed);
    <a href="Config.md#0x1_Config_publish_new_config">Config::publish_new_config</a>(
        account,
        transaction_publish_option,
    );
}
</code></pre>



</details>

<a name="0x1_TransactionPublishOption_new_transaction_publish_option"></a>

## Function `new_transaction_publish_option`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_new_transaction_publish_option">new_transaction_publish_option</a>(script_allow_list: vector&lt;u8&gt;, module_publishing_allowed: bool): <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_TransactionPublishOption">TransactionPublishOption::TransactionPublishOption</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_new_transaction_publish_option">new_transaction_publish_option</a>(
    script_allow_list: vector&lt;u8&gt;,
    module_publishing_allowed: bool,
): <a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a> {
    <b>let</b> list = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;vector&lt;u8&gt;&gt;();
    <b>let</b> len = <a href="Vector.md#0x1_Vector_length">Vector::length</a>(&script_allow_list) / <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_SCRIPT_HASH_LENGTH">SCRIPT_HASH_LENGTH</a>;
    <b>let</b> i = 0;
    <b>while</b> (i &lt; len){
        <b>let</b> script_hash = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>&lt;u8&gt;();
        <b>let</b> j = 0;
        <b>while</b> (j &lt; <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_SCRIPT_HASH_LENGTH">SCRIPT_HASH_LENGTH</a>){
            <b>let</b> index = <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_SCRIPT_HASH_LENGTH">SCRIPT_HASH_LENGTH</a> * i + j;
            <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(
                &<b>mut</b> script_hash,
                *<a href="Vector.md#0x1_Vector_borrow">Vector::borrow</a>(&script_allow_list, index),
            );
            j = j + 1;
        };
        <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>&lt;vector&lt;u8&gt;&gt;(&<b>mut</b> list, script_hash);
        i = i + 1;
    };
    <a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a> { script_allow_list: list, module_publishing_allowed }
}
</code></pre>



</details>

<a name="0x1_TransactionPublishOption_is_script_allowed"></a>

## Function `is_script_allowed`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_is_script_allowed">is_script_allowed</a>(account: address, hash: &vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_is_script_allowed">is_script_allowed</a>(account: address, hash: &vector&lt;u8&gt;): bool {
    <b>let</b> publish_option = <a href="Config.md#0x1_Config_get_by_address">Config::get_by_address</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(account);
    <a href="Vector.md#0x1_Vector_is_empty">Vector::is_empty</a>(&publish_option.script_allow_list) ||
        <a href="Vector.md#0x1_Vector_contains">Vector::contains</a>(&publish_option.script_allow_list, hash)
}
</code></pre>



</details>

<a name="0x1_TransactionPublishOption_is_module_allowed"></a>

## Function `is_module_allowed`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_is_module_allowed">is_module_allowed</a>(account: address): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_is_module_allowed">is_module_allowed</a>(account: address): bool {
    <b>let</b> publish_option = <a href="Config.md#0x1_Config_get_by_address">Config::get_by_address</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(account);
    publish_option.module_publishing_allowed
}
</code></pre>



</details>

<a name="0x1_TransactionPublishOption_add_to_script_allow_list"></a>

## Function `add_to_script_allow_list`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_add_to_script_allow_list">add_to_script_allow_list</a>(account: &signer, new_hash: vector&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_add_to_script_allow_list">add_to_script_allow_list</a>(account: &signer, new_hash: vector&lt;u8&gt;) {
    <b>assert</b>(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == <a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>(),
        <a href="Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(<a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EPROLOGUE_ACCOUNT_DOES_NOT_EXIST">EPROLOGUE_ACCOUNT_DOES_NOT_EXIST</a>),
    );
    <b>assert</b>(<a href="Vector.md#0x1_Vector_length">Vector::length</a>(&new_hash) == <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_SCRIPT_HASH_LENGTH">SCRIPT_HASH_LENGTH</a>, <a href="Errors.md#0x1_Errors_invalid_argument">Errors::invalid_argument</a>(<a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EINVALID_ARGUMENT">EINVALID_ARGUMENT</a>));
    <b>let</b> publish_option = <a href="Config.md#0x1_Config_get_by_address">Config::get_by_address</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account),
    );
    <b>if</b> (<a href="Vector.md#0x1_Vector_contains">Vector::contains</a>(&publish_option.script_allow_list, &new_hash)) {
        <b>abort</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EALLOWLIST_ALREADY_CONTAINS_SCRIPT">EALLOWLIST_ALREADY_CONTAINS_SCRIPT</a>
    };
    <a href="Vector.md#0x1_Vector_push_back">Vector::push_back</a>(&<b>mut</b> publish_option.script_allow_list, new_hash);
    <a href="Config.md#0x1_Config_set">Config::set</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(account, publish_option);
}
</code></pre>



</details>

<a name="0x1_TransactionPublishOption_set_open_script"></a>

## Function `set_open_script`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_set_open_script">set_open_script</a>(account: &signer)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_set_open_script">set_open_script</a>(account: &signer) {
    <b>assert</b>(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == <a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>(),
        <a href="Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(<a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EPROLOGUE_ACCOUNT_DOES_NOT_EXIST">EPROLOGUE_ACCOUNT_DOES_NOT_EXIST</a>),
    );
    <b>let</b> publish_option = <a href="Config.md#0x1_Config_get_by_address">Config::get_by_address</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account),
    );
    publish_option.script_allow_list = <a href="Vector.md#0x1_Vector_empty">Vector::empty</a>();
    <a href="Config.md#0x1_Config_set">Config::set</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(account, publish_option);
}
</code></pre>



</details>

<a name="0x1_TransactionPublishOption_set_open_module"></a>

## Function `set_open_module`



<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_set_open_module">set_open_module</a>(account: &signer, open_module: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="TransactionPublishOption.md#0x1_TransactionPublishOption_set_open_module">set_open_module</a>(account: &signer, open_module: bool) {
    <b>assert</b>(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account) == <a href="CoreAddresses.md#0x1_CoreAddresses_GENESIS_ADDRESS">CoreAddresses::GENESIS_ADDRESS</a>(),
        <a href="Errors.md#0x1_Errors_requires_address">Errors::requires_address</a>(<a href="TransactionPublishOption.md#0x1_TransactionPublishOption_EPROLOGUE_ACCOUNT_DOES_NOT_EXIST">EPROLOGUE_ACCOUNT_DOES_NOT_EXIST</a>),
    );
    <b>let</b> publish_option = <a href="Config.md#0x1_Config_get_by_address">Config::get_by_address</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(
        <a href="Signer.md#0x1_Signer_address_of">Signer::address_of</a>(account),
    );
    publish_option.module_publishing_allowed = open_module;
    <a href="Config.md#0x1_Config_set">Config::set</a>&lt;<a href="TransactionPublishOption.md#0x1_TransactionPublishOption">TransactionPublishOption</a>&gt;(account, publish_option);
}
</code></pre>



</details>

<a name="@Specification_1"></a>

## Specification



<pre><code><b>pragma</b> verify = <b>false</b>;
<b>pragma</b> aborts_if_is_strict;
</code></pre>