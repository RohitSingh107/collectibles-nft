pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/VRFConsumerBase.sol";

contract Collectible is ERC721, ERC721URIStorage, VRFConsumerBase {
    uint256 public tokenCounter;
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    // add other things
    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => uint256) public requestIdToTokenId;

    event RequestedCollectible(bytes32 indexed requestId);
    event ReturnedCollectible(bytes32 indexed requestId, uint256 randomNumber);

    bytes32 internal keyHash;
    uint256 internal fee;

    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyhash
    )
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("Dogie", "DOG")
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = 0.1 * 10**18;
    }

    function createCollectible(string memory tokenURI)
        public
        returns (bytes32)
    {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI[requestId] = tokenURI;
        emit RequestedCollectible(requestId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        address dogOwner = requestIdToSender[requestId];
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomNumber % 3);
        tokenIdToBreed[newItemId] = breed;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        emit ReturnedCollectible(requestId, randomNumber);
    }
}
