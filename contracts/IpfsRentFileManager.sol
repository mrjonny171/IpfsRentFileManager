// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error NotOwner(address attempt, string message);

contract IpfsRentFileManager {
    //Enums
    enum FileCategory {
        Empty,
        IdCard,
        LiquidationNote,
        SalaryReceipt
    }

    //Structs
    struct File {
        address fileOwner;
        uint256 size;
        FileCategory category;
        address[] accesses;
        uint256[] accessTimes;
        uint256 entrances;
    }

    //State Variables
    mapping(string => File) public s_files;

    //Events
    event FileUploaded(
        address indexed fileOwner,
        string hashFile,
        uint256 size,
        FileCategory category
    );

    event FileDeleted(address indexed fileOwner, string hashFile);

    event FileAccessed(
        address indexed fileOwner,
        string hashFile,
        address indexed accessor,
        uint256 timestamp
    );

    constructor() {}

    /**
     * @dev Enables anyone to upload file metadata
     */
    function uploadFile(
        string memory _hashFile,
        uint256 _size,
        FileCategory _category
    ) external {
        File memory fileInformation = File({
            fileOwner: msg.sender,
            size: _size,
            category: _category,
            accesses: new address[](0),
            accessTimes: new uint256[](0),
            entrances: 0
        });

        s_files[_hashFile] = fileInformation;

        emit FileUploaded(msg.sender, _hashFile, _size, _category);
    }

    /**
     * @dev Enables the owner of a file to delete his file metadata
     */
    function deleteFile(string memory _hashFile) external {
        if (msg.sender != s_files[_hashFile].fileOwner) {
            revert NotOwner(msg.sender, "Address is not the owner of the file");
        }

        File memory fileInformation = File({
            fileOwner: address(0),
            size: 0,
            category: FileCategory.Empty,
            accesses: new address[](0),
            accessTimes: new uint256[](0),
            entrances: 0
        });

        s_files[_hashFile] = fileInformation;

        emit FileDeleted(msg.sender, _hashFile);
    }

    /**
     * @dev Saves in the file metadata who and when accessed a certain file
     */
    function updateStatistics(string memory _hashFile) internal {
        uint256 index = s_files[_hashFile].entrances;

        s_files[_hashFile].entrances++;
        s_files[_hashFile].accessTimes[index] = block.timestamp;
        s_files[_hashFile].accesses[index] = msg.sender;

        emit FileAccessed(
            s_files[_hashFile].fileOwner,
            _hashFile,
            msg.sender,
            block.timestamp
        );
    }

    function getFileOwner(string memory _hashFile) external returns (address) {
        updateStatistics(_hashFile);
        return s_files[_hashFile].fileOwner;
    }

    function gets_filesize(string memory _hashFile) external returns (uint256) {
        updateStatistics(_hashFile);
        return s_files[_hashFile].size;
    }

    function getFileCategory(
        string memory _hashFile
    ) external returns (uint256) {
        updateStatistics(_hashFile);
        return uint256(s_files[_hashFile].category);
    }

    function getFileNumberAccesses(
        string memory _hashFile
    ) external returns (uint256) {
        updateStatistics(_hashFile);
        return s_files[_hashFile].accesses.length;
    }

    function getFileAccesses(
        string memory _hashFile
    ) external returns (address[] memory, uint256[] memory) {
        updateStatistics(_hashFile);
        return (s_files[_hashFile].accesses, s_files[_hashFile].accessTimes);
    }
}
