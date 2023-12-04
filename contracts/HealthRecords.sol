// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IProofOfIdentity.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interface/ERC721Custom.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract HealthRecords is Ownable{
    ERC721Custom public nft;
    uint public count;

    // Proof of Identity contract
    IProofOfIdentity private _proofOfIdentity;

    // The number assigned to each access level on the Proof of Identity contract
    uint256 private constant _AccessLevel1 = 1;
    uint256 private constant _AccessLevel2 = 2;
    uint256 private constant allAccess = 3;

    uint256 private _auctionType;

    event ProofOfIdentityAddressUpdated(address indexed poiAddress);

    event RecordUploaded(
        address indexed uploader,
        string nameOfpatient,
        bytes id,
        bytes16 nameOfContent
    );
    event NewMint(bytes id, address indexed minter, string metadataURI);

    // /// @notice Modifier for ensuring no two links uploaded are the same
    // modifier noDuplicate(string[] memory _links) {
    //     RecordStruct[] memory list = portfolioList;
    //     uint i;
    //     while (i <= list.length) {
    //         for (uint u = 0; u <= list[i].links.length; u++) {
    //             for (uint y = 0; y <= _links.length; y++) {
    //                 require(
    //                     stringsNotEqual(_links[y], list[i].links[u]),
    //                     "Cannot upload link to an existing record on our platform"
    //                 );
    //             }
    //         }
    //         i++;
    //     }
    //     _;
    // }

    // /// @notice modifier to prevent minting your own record portfolio as NFT
    // modifier mint(bytes memory id) {
    //     for (uint i = 0; i <= count; i++) {
    //         require(
    //             keccak256(personalPortfolio[msg.sender][i].id) != keccak256(id),
    //             "Cannot mint your own research"
    //         );
    //     }
    //     _;
    // }

    /// @dev For all uploaded records
    RecordStruct[] public portfolioList;

    error AccountSuspended();

    error UserType(uint256 userType, uint256 required);


    /// @dev Struct containing the details of each record
    struct RecordStruct {
        bytes id;
        address uploadingStaff;
        string patientName;
        bytes16 nameOfContent;
        string details;
        string[] links;
        bytes32 documentHash;
    }

    /// @dev For a particular staff's uploaded record
    mapping(address => mapping(uint => RecordStruct))
        public personalPortfolio;

    constructor() {
        nft = new ERC721Custom(
            "NFT",
            "ERC20",
            "https://ipfs.io/ipfs/"
        );
    }

    /// @notice Check if the two strings are equal
    function stringsNotEqual(
        string memory a1,
        string memory a2
    ) internal pure returns (bool) {
        bytes32 first = keccak256(abi.encode(a1));
        bytes32 second = keccak256(abi.encode(a2));
        return first != second ? true : false;
    }

    /// @notice To create unique ID for each Record
    function createId(
        bytes16 b1,
        bytes32 b2
    ) public pure returns (bytes memory) {
        bytes memory result = new bytes(64);
        bytes32 b3 = bytes32(b1);

        assembly {
            mstore(add(result, 32), b3)
            mstore(add(result, 64), b2)
        }
        return result;
    }

    /// @notice Function to upload a new record instance
    function uploadRecord(
        string memory patientName,
        bytes16 nameofContent,
        string memory details,
        string[] memory llinks,
        bytes32 documentHash
    ) public noDuplicate(llinks) {
        bytes memory id = createId(nameofContent, documentHash);

        personalPortfolio[msg.sender][count] = RecordStruct(
            id,
            msg.sender,
            patientName,
            nameofContent,
            details,
            llinks,
            documentHash
        );
        RecordStruct memory resRch = personalPortfolio[msg.sender][count];
        count++;

        portfolioList.push(resRch);

        emit RecordUploaded(msg.sender, patientName, id, nameofContent);
    }

    /// @notice To get any record by using just the unique id
    function getRecordByIndex(
        bytes memory identity
    ) public view returns (RecordStruct memory research) {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);
        RecordStruct[] memory u = portfolioList;
        for (uint i = 0; i <= u.length; i++) {
            if (keccak256(u[i].id) == keccak256(identity)) {
                research = u[i];
                return research;
            }
        }
    }

    /// @notice To mint a research
    /// @dev Call the getResearchByIndex to get the research struct, send it as json to IPFS then call mint with
    /// the CID of the metadata (Researchstruct)
    function mintRecord(
        bytes memory id,
        string memory metadataURI
    ) public mint(id) {
        nft.safeMint(msg.sender, metadataURI);
        personalPortfolio[msg.sender][count] = getRecordByIndex(id);
        count++;

        emit NewMint(id, msg.sender, metadataURI);
    }

    /// @notice To get address of NFT contract
    function getNftAddress() public view returns (address) {
        return address(nft);
    }
}
