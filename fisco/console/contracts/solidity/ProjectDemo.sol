pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Table.sol";

contract ProjectDemo {
    event CreateResult(int count);
    event InsertResult(int count);
    event UpdateResult(int count);
    event RemoveResult(int count);
    event TransferEvent(int256 ret, string from_account, string to_account, int amount);
    event MakeOverEvent(string from_account, string to_account, int amount);
    
    constructor() public{
       createAccountTB();
       createReceiptFromTB();
       createReceiptToTB();
    }
    function initProject() public {

        if(insertAccount("CE", 1000) == 0){
            updateAccount("CE", 1000);
        }
        if(insertAccount("TC", 1000) == 0){
            updateAccount("TC", 1000);
        }
        if(insertAccount("HC", 1000) == 0){
            updateAccount("HC", 1000);
        }
        if(insertAccount("FO", 1000) == 0){
            updateAccount("FO", 10000);
        }

        removeReceiptOfAccount("CE");
        removeReceiptOfAccount("TC");
        removeReceiptOfAccount("HC");
        removeReceiptOfAccount("FO");
    }
    //create table
    function createAccountTB() public returns(int){
        TableFactory tf = TableFactory(0x1001); //The fixed address is 0x1001 for TableFactory
        
        int count = tf.createTable("t_account", "name", "balance");
        emit CreateResult(count);
        return count;
    }

    function createReceiptFromTB() public returns(int){
        TableFactory tf = TableFactory(0x1001); //The fixed address is 0x1001 for TableFactory
        
        int count = tf.createTable("t_receiptFrom", "from", "to, amount");
        emit CreateResult(count);
        return count;
    }
    function createReceiptToTB() public returns(int){
        TableFactory tf = TableFactory(0x1001); //The fixed address is 0x1001 for TableFactory
        
        int count = tf.createTable("t_receiptTo", "to", "from, amount");
        emit CreateResult(count);
        return count;
    }

    //select records
    function selectAccount(string name) public constant returns(int, string[], int[]){
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_account");
        
        Condition condition = table.newCondition();
        
        Entries entries = table.select(name, condition);
        string[] memory user_name_bytes_list = new string[](uint256(entries.size()));
        int[] memory balance_list = new int[](uint256(entries.size()));
        
        for(int i=0; i < entries.size(); ++i) {
            Entry entry = entries.get(i);
            
            user_name_bytes_list[uint256(i)] = entry.getString("name");
            balance_list[uint256(i)] = entry.getInt("balance");
        }
 
        return (entries.size(), user_name_bytes_list, balance_list);
    }
    function selectReceiptByFrom(string from) public constant returns(int, string[], string[], int[]){
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receiptFrom");
        
        Condition condition = table.newCondition();
        
        Entries entries = table.select(from, condition);
        string[] memory from_list = new string[](uint256(entries.size()));
        string[] memory to_list = new string[](uint256(entries.size()));
        int[] memory amount_list = new int[](uint256(entries.size()));
        
        for(int i=0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            
            from_list[uint256(i)] = entry.getString("from");
            to_list[uint256(i)] = entry.getString("to");
            amount_list[uint256(i)] = entry.getInt("amount"); 
        }
 
        return (entries.size(), from_list, to_list, amount_list);
    }
    function selectReceiptByTo(string to) public constant returns(int, string[], string[], int[]){
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receiptTo");
        
        Condition condition = table.newCondition();
        
        Entries entries = table.select(to, condition);
        string[] memory from_list = new string[](uint256(entries.size()));
        string[] memory to_list = new string[](uint256(entries.size()));
        int[] memory amount_list = new int[](uint256(entries.size()));
        
        for(int i=0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            
            from_list[uint256(i)] = entry.getString("from");
            to_list[uint256(i)] = entry.getString("to");
            amount_list[uint256(i)] = entry.getInt("amount"); 
        }
 
        return (entries.size(), from_list, to_list, amount_list);
    }
    //insert records
    function insertAccount(string name, int balance) public returns(int) {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_account");
        int count = 0;

        Condition condition = table.newCondition();
        Entries entries = table.select(name, condition);
        if(entries.size() == 0) {
            Entry entry = table.newEntry();
            entry.set("name", name);
            entry.set("balance", balance);
            
            count = table.insert(name, entry);
        }
        emit InsertResult(count);
        
        return count;
    }
    function insertReceipt(string from, string to, int amount) public returns(int) {
        TableFactory tf = TableFactory(0x1001);
        Table tableFrom = tf.openTable("t_receiptFrom");
        Table tableTo = tf.openTable("t_receiptTo");
        int count = 0;

        if(keccak256(from) != keccak256(to)) {
            Entry entryFrom = tableFrom.newEntry();
            entryFrom.set("from", from);
            entryFrom.set("to", to);
            entryFrom.set("amount", amount);
            
            count += tableFrom.insert(from, entryFrom);

            Entry entryTo = tableTo.newEntry();
            entryTo.set("to", to);
            entryTo.set("from", from);
            entryTo.set("amount", amount);
            
            count += tableTo.insert(to, entryTo);
        }

        emit InsertResult(count);
        
        return count;
    }
    //update records
    function updateAccount(string name, int balance) public returns(int) {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_account");
        
        Entry entry = table.newEntry();
        entry.set("balance", balance);
        
        Condition condition = table.newCondition();
        condition.EQ("name", name);
        
        int count = table.update(name, entry, condition);
        emit UpdateResult(count);
        
        return count;
    }
    function updateReceipt(string from, string to, int amount, int newAmount) public returns(int) {
        TableFactory tf = TableFactory(0x1001);
        Table tableFrom = tf.openTable("t_receiptFrom");
        Table tableTo = tf.openTable("t_receiptTo");
        int count = 0;
        
        Entry entryFrom = tableFrom.newEntry();
        entryFrom.set("amount", newAmount);
        
        Condition conditionFrom = tableFrom.newCondition();
        conditionFrom.EQ("from", from);
		conditionFrom.EQ("to", to);
		conditionFrom.EQ("amount", amount);
        
        count += tableFrom.update(from, entryFrom, conditionFrom);

        Entry entryTo = tableTo.newEntry();
        entryTo.set("amount", newAmount);
        
        Condition conditionTo = tableTo.newCondition();
        conditionTo.EQ("from", from);
		conditionTo.EQ("to", to);
		conditionTo.EQ("amount", amount);
        
        count += tableTo.update(to, entryTo, conditionTo);


        emit UpdateResult(count);
        
        return count;
    }
    //remove records
    function removeAccount(string name) public returns(int){
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_account");
        
        Condition condition = table.newCondition();
        condition.EQ("name", name);
        
        int count = table.remove(name, condition);
        emit RemoveResult(count);
        
        return count;
    }
    function removeReceipt(string from, string to, int amount) public returns(int){
        TableFactory tf = TableFactory(0x1001);
        Table tableFrom = tf.openTable("t_receiptFrom");
        Table tableTo = tf.openTable("t_receiptTo");
        int count = 0;
        
        Condition conditionFrom = tableFrom.newCondition();
        conditionFrom.EQ("from", from);
		conditionFrom.EQ("to", to);
		conditionFrom.EQ("amount", amount);
        
        count += tableFrom.remove(from, conditionFrom);

        Condition conditionTo = tableTo.newCondition();
        conditionTo.EQ("from", from);
		conditionTo.EQ("to", to);
		conditionTo.EQ("amount", amount);
        
        count += tableTo.remove(to, conditionTo);

        emit RemoveResult(count);
        
        return count;
    }
    function removeReceiptOfAccount(string name) public returns(int){
        TableFactory tf = TableFactory(0x1001);
        Table tableFrom = tf.openTable("t_receiptFrom");
        Table tableTo = tf.openTable("t_receiptTo");
        int count = 0;
        
        Condition conditionFrom = tableFrom.newCondition();
        
        count += tableFrom.remove(name, conditionFrom);

        Condition conditionTo = tableTo.newCondition();
        
        count += tableTo.remove(name, conditionTo);

        emit RemoveResult(count);
        
        return count;
    }
	function transaction(string from_account, string to_account, int amount) public returns(int) {
        // 查询转移资产账户信息
        int ret_code = 0;
        int from_asset_value = 0;
        int to_asset_value = 0;

        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_account");
        
		Entries entries;
		Entry entry;

        // 转移账户是否存在?
		entries = table.select(from_account, table.newCondition());
        if(entries.size() == 0) {
            ret_code = -1;
            // 转移账户不存在
            emit TransferEvent(ret_code, from_account, to_account, amount);
            return ret_code;

        }
		entry = entries.get(0);
		from_asset_value = entry.getInt("balance");

        // 接受账户是否存在?
		entries = table.select(to_account, table.newCondition());
        if(entries.size() == 0) {
            ret_code = -2;
            // 接收资产的账户不存在
            emit TransferEvent(ret_code, from_account, to_account, amount);
            return ret_code;
        }
		entry = entries.get(0);
		to_asset_value = entry.getInt("balance");

        if(from_asset_value < amount) {
            ret_code = -3;
            // 转移资产的账户金额不足
            emit TransferEvent(ret_code, from_account, to_account, amount);
            return ret_code;
        } 

        if (to_asset_value + amount < to_asset_value) {
            ret_code = -4;
            // 接收账户金额溢出
            emit TransferEvent(ret_code, from_account, to_account, amount);
            return ret_code;
        }


        Entry entry0 = table.newEntry();
        entry0.set("name", from_account);
        entry0.set("balance", int(from_asset_value - amount));
        // 更新转账账户
        int count = table.update(from_account, entry0, table.newCondition());
        if(count != 1) {
            ret_code = -5;
            // 失败? 无权限或者其他错误?
            emit TransferEvent(ret_code, from_account, to_account, amount);
            return ret_code;
        }

        Entry entry1 = table.newEntry();
        entry1.set("name", to_account);
        entry1.set("balance", int256(to_asset_value + amount));
        // 更新接收账户
        table.update(to_account, entry1, table.newCondition());

        emit TransferEvent(ret_code, from_account, to_account, amount);

        return ret_code;
    }
    function insertReceiptByMakingOver(string from_account, string to_account, int amount) public returns(int) {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receiptTo");

        Condition condition = table.newCondition();
        
        Entries entries = table.select(from_account, condition);
        string[] memory from_list = new string[](uint256(entries.size()));
        string[] memory to_list = new string[](uint256(entries.size()));
        int[] memory amount_list = new int[](uint256(entries.size()));
        
        int i;
        for(i= 0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            
            from_list[uint256(i)] = entry.getString("from");
            to_list[uint256(i)] = entry.getString("to");
            amount_list[uint256(i)] = entry.getInt("amount"); 
        }
        int spareAmount;
        for(i = 0; i < entries.size(); i ++) {
            if(amount_list[uint256(i)] < amount) {
                amount -= amount_list[uint256(i)];
                if(keccak256(from_list[uint256(i)]) != keccak256(to_account)) {
                    insertReceipt(from_list[uint256(i)], to_account, amount_list[uint256(i)]);
                }
                removeReceipt(from_list[uint256(i)], to_list[uint256(i)], amount_list[uint256(i)]);
            } else if(amount_list[uint256(i)] == amount) {
                amount -= amount_list[uint256(i)];
                if(keccak256(from_list[uint256(i)]) != keccak256(to_account)) {
                    insertReceipt(from_list[uint256(i)], to_account, amount_list[uint256(i)]);
                }
                removeReceipt(from_list[uint256(i)], to_list[uint256(i)], amount_list[uint256(i)]);
                break;
            } else {
                spareAmount = amount_list[uint256(i)] - amount;
                if(keccak256(from_list[uint256(i)]) != keccak256(to_account)) {
                    insertReceipt(from_list[uint256(i)], to_account, amount);
                }
                updateReceipt(from_list[uint256(i)], to_list[uint256(i)], amount_list[uint256(i)], spareAmount);
                amount = 0;
                break;
            }
        }
        if(amount > 0) {
            insertReceipt(from_account, to_account, amount);
        }
        emit MakeOverEvent(from_account, to_account, amount);
        return amount;
    }
}
