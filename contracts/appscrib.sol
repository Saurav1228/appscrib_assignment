pragma solidity ^0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    //event register
    event registerUser(
        address indexed user,
        string firstName,
        string lastName,
        uint256 userType
    );

    //event freeze
    event Freeze(address indexed user, address indexed sender, bool value);

    //event mint
    event Mint(address indexed sender, address indexed user, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20Basic is IERC20 {
    string public constant name = "ERC20Basic";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;

    //Struct for usertype
    //userType = 0 for admin
    //userType = 1 for tokenHolder
    //userType = 2 for owner

    // Create mapping named registry
    mapping(address => string) registry_firstName;
    mapping(address => string) registry_lastName;
    mapping(address => uint256) registry_userType;

    // Create mapping for ban user
    mapping(address => bool) banUser;

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    uint256 totalSupply_;

    using SafeMath for uint256;

    constructor(string memory firstName, string memory lastName) public {
        registry_firstName[msg.sender] = firstName;
        registry_lastName[msg.sender] = lastName;
        registry_userType[msg.sender] = 2;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens)
        public
        override
        returns (bool)
    {
        require(banUser[msg.sender] != true);
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        require(banUser[msg.sender] != true);
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    // function register added

    function Register(
        address user_address,
        string memory _firstName,
        string memory _lastName,
        uint256 _userType
    ) public {
        require(registry_userType[msg.sender] == 2);
        registry_firstName[user_address] = _firstName;
        registry_lastName[user_address] = _lastName;
        registry_userType[user_address] = _userType;
        emit registerUser(user_address, _firstName, _lastName, _userType);
    }

    //funtion ban

    function freeze(address user, bool value) public {
        require(registry_userType[msg.sender] == 0);
        banUser[user] = value;
        //value = true (ban the user)
        //value = false (unban the user)
        emit Freeze(user, msg.sender, value);
    }

    //function mint

    function mint(address user, uint256 amount) public {
        require(registry_userType[msg.sender] == 2);
        balances[user] = balances[user].add(amount);
        totalSupply_ = totalSupply_.add(amount);
        emit Mint(user, msg.sender, amount);
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
