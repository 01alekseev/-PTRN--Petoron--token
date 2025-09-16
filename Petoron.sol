// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Petoron (PTRN) - fixed-supply, ownerless ERC‑20 with EIP‑2612 permit
/// @notice Minimal, gas‑efficient, no admin keys, no upgrade hooks
/// Created to popularize Petoron open-source cryptographic tools:
/// Petoron core (ADC)
/// Petoron Time Burn Cipher (PTBC)
/// Petoron Crypto Archiver (PCA)
/// Petoron Seal Contracts (PSC)
/// Petoron Local Destroyer (PLD)
/// Petoron Quantum Standard (PQS)
/// Petoron P2P Messenger (P-P2P-M)
contract Petoron {
    // --- Metadata -----------------------------------------------------------
    string public constant name = "Petoron";
    string public constant symbol = "PTRN";
    function decimals() public pure returns (uint8) { return 8; }

    // --- Supply / accounting ------------------------------------------------
    uint256 public immutable totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // --- EIP-2612 (permit) --------------------------------------------------
    mapping(address => uint256) public nonces;
    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    // --- Transparency -------------------------------------------------------
    bytes32 public immutable SOURCE_HASH;
    event ProofOfSource(bytes32 indexed sourceHash);

    // --- Events / Errors ----------------------------------------------------
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    error ZeroAddress();
    error InsufficientBalance();
    error InsufficientAllowance();
    error PermitExpired();
    error InvalidSignature();

    constructor(address treasury, bytes32 sourceHash) {
        if (treasury == address(0)) revert ZeroAddress();

        uint256 supply = 20_000_000 * (10 ** uint256(decimals()));
        totalSupply = supply;
        balanceOf[treasury] = supply;
        emit Transfer(address(0), treasury, supply);

        SOURCE_HASH = sourceHash;
        emit ProofOfSource(sourceHash);

        _HASHED_NAME = keccak256(bytes(name));
        _HASHED_VERSION = keccak256(bytes("1"));
        _TYPE_HASH = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
    }

    // --- ERC-20 core --------------------------------------------------------
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            if (allowed < amount) revert InsufficientAllowance();
            unchecked { allowance[from][msg.sender] = allowed - amount; }
        }
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 added) external returns (bool) {
        uint256 newAllow = allowance[msg.sender][spender] + added;
        allowance[msg.sender][spender] = newAllow;
        emit Approval(msg.sender, spender, newAllow);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtracted) external returns (bool) {
        uint256 current = allowance[msg.sender][spender];
        uint256 newAllow = subtracted > current ? 0 : current - subtracted;
        allowance[msg.sender][spender] = newAllow;
        emit Approval(msg.sender, spender, newAllow);
        return true;
    }

    // Optional self burn for holders (does not change immutable totalSupply)
    function burn(uint256 amount) external {
        uint256 fromBal = balanceOf[msg.sender];
        if (fromBal < amount) revert InsufficientBalance();
        unchecked { balanceOf[msg.sender] = fromBal - amount; }
        emit Transfer(msg.sender, address(0), amount);
        emit Burn(msg.sender, amount);
    }

    // --- EIP-2612 -----------------------------------------------------------
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) public {
        if (block.timestamp > deadline) revert PermitExpired();
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            ))
        ));
        address recovered = _recover(digest, v, r, s);
        if (recovered != owner) revert InvalidSignature();

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function permitAndTransferFrom(
        address owner,
        address spender,
        address to,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external returns (bool) {
        permit(owner, spender, value, deadline, v, r, s);
        require(msg.sender == spender, "Only spender can invoke transfer");
        return transferFrom(owner, to, value);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return (block.chainid == _CACHED_CHAIN_ID)
            ? _CACHED_DOMAIN_SEPARATOR
            : _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(
            typeHash,
            nameHash,
            versionHash,
            block.chainid,
            address(this)
        ));
    }

    // --- Views --------------------------------------------------------------
    function circulatingSupply() public view returns (uint256) {
        return totalSupply - balanceOf[address(0)];
    }

    // --- Internals ----------------------------------------------------------
    function _transfer(address from, address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        uint256 fromBal = balanceOf[from];
        if (fromBal < amount) revert InsufficientBalance();
        unchecked {
            balanceOf[from] = fromBal - amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _recover(bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes32 SECP256K1N_HALF =
            0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;
        if (uint256(s) > uint256(SECP256K1N_HALF)) revert InvalidSignature();
        if (v != 27 && v != 28) revert InvalidSignature();
        address signer = ecrecover(digest, v, r, s);
        if (signer == address(0)) revert InvalidSignature();
        return signer;
    }

    // --- Safety -------------------------------------------------------------
    receive() external payable { revert(); }
    fallback() external payable { revert(); }
}
