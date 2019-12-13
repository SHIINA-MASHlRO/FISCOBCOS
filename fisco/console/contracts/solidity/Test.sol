pragma solidity ^0.4.0;

contract Test{

    uint a;
	uint b;

    constructor() public{
       a = b = 0;
    }

    function get() constant public returns(uint){
        return a * b;
    }

    function set(uint n, uint m) public{
    	a = n;
		b = m;
    }
}

