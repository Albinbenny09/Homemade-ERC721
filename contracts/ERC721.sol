// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC721.sol";
import "./Address.sol";


contract ERC721 is IERC721 {
    
  using Address for address;
   //Emitted when tokenId token is transferred from from to to.
    event Transfer(
        address indexed from,
        address indexed to,
        uint indexed tokenId
    );
    //Emitted when owner enables approved to manage the tokenId token.
    event Approval(
        address indexed owner,
        address indexed approved,
        uint indexed tokenId
    );
    //Emitted when owner enables or disables (approved) operator to manage all of its assets.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint) private _balances;

    // Mapping from token ID to approved address
    mapping(uint => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
    //Returns the number of tokens in owner's account.
    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }
    //Returns the owner of the tokenId token.
    function ownerOf(uint tokenId) public view returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }
    //Returns if the operator is allowed to manage all of the assets of owner.


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }
   //Approve or remove operator as an operator for the caller. Operators can call transferFrom or safeTransferFrom for any token owned by the caller.
    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    //Returns the account approved for tokenId token.
    function getApproved(uint tokenId) external view returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }
    //Approve to to operate on tokenId
    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    /*
     Gives permission to to to transfer tokenId token to another account.
     The approval is cleared when the token is transferred.
     Only a single account can be approved at a time, so approving the zero address clears previous approvals.
    **/
    function approve(address to, uint tokenId) external {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }
    /*Transfers tokenId from from to to. As opposed to transferFrom,
     this imposes no restrictions on msg.sender.
     **/
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    //Transfers tokenId token from from to to.
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }
    //Always returns IERC721Receiver.onERC721Received.selector.
    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "not ERC721Receiver"
        );
    }
    //Safely transfers tokenId token from from to to.
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external {
        safeTransferFrom(from, to, tokenId, "");
    }
    //Mints tokenId and transfers it to to.
    function mint(address to, uint tokenId) external {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    //Destroys tokenId. The approval is cleared when the token is burned.
    function burn(uint tokenId) external {
        address owner = ownerOf(tokenId);

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
}