// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error NotOwner(address attempt, string message);
error FileDoesNotExist(address attempt, uint256 _category, string message);
error FileAlreadyExists(address attempt, uint256 _category, string message);

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
        string url;
        string fileName;
        address fileOwner;
        string hashFile;
        uint256 size;
        FileCategory category;
        string houseId;
    }

    //State Variables
    mapping(string => mapping(string => mapping(FileCategory => File))) private s_files;

    //Events
    event FileUploaded(
        string username,
        address indexed fileOwner,
        string hashFile,
        uint256 size,
        FileCategory category
    );

    event FileDeleted(address indexed fileOwner, FileCategory file);

    /**
     * @dev Empty Constructor
     */
    constructor() {}

    /**
     * @dev Enables anyone to upload file metadata
     */
    function uploadFile(
        string memory username,
        string memory _hashFile,
        uint256 _size,
        FileCategory _category,
        string memory _ipfsURL,
        string memory _fileName,
        string memory _houseId
    ) external {
        if (s_files[_houseId][username][_category].category != FileCategory.Empty) {
            revert FileAlreadyExists(
                msg.sender,
                uint256(_category),
                'A file with this hash already exists'
            );
        }

        File memory fileInformation = File({
            fileName: _fileName,
            url: _ipfsURL,
            fileOwner: msg.sender,
            hashFile: _hashFile,
            size: _size,
            category: _category,
            houseId: _houseId
        });

        s_files[_houseId][username][_category] = fileInformation;

        emit FileUploaded(username, msg.sender, _hashFile, _size, _category);
    }

    /**
     * @dev Enables the owner of a file to delete his file metadata
     */
    function deleteFile(
        string memory username,
        FileCategory _category,
        string memory _houseId
    ) external {
        if (s_files[_houseId][username][_category].category == FileCategory.Empty) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(_category),
                'A file with this hash does not exist'
            );
        }

        if (msg.sender != s_files[_houseId][username][_category].fileOwner) {
            revert NotOwner(msg.sender, 'Address is not the owner of the file');
        }

        File memory fileInformation = File({
            fileName: '',
            url: '',
            fileOwner: address(0),
            hashFile: '',
            size: 0,
            category: FileCategory.Empty,
            houseId: ''
        });

        s_files[_houseId][username][_category] = fileInformation;

        emit FileDeleted(msg.sender, _category);
    }

    function getFileOwner(
        string memory username,
        FileCategory _category,
        string memory _houseId
    ) public view returns (address) {
        if (s_files[_houseId][username][_category].category == FileCategory.Empty) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(_category),
                'A file with this hash does not exist'
            );
        }

        return s_files[_houseId][username][_category].fileOwner;
    }

    function getFileSize(
        string memory username,
        FileCategory _category,
        string memory _houseId
    ) public view returns (uint256) {
        if (s_files[_houseId][username][_category].category == FileCategory.Empty) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(_category),
                'A file with this hash does not exist'
            );
        }
        return s_files[_houseId][username][_category].size;
    }

    function getFileCategory(
        string memory username,
        FileCategory _category,
        string memory _houseId
    ) public view returns (uint256) {
        if (s_files[_houseId][username][_category].category == FileCategory.Empty) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(_category),
                'A file with this hash does not currently exist'
            );
        }
        return uint256(s_files[_houseId][username][_category].category);
    }

    function getFilesURL(
        string memory username,
        string memory _houseId
    ) public view returns (string[] memory) {
        if (s_files[_houseId][username][FileCategory.IdCard].category == FileCategory.Empty) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(FileCategory.IdCard),
                'A file with this hash does not exist'
            );
        }

        if (
            s_files[_houseId][username][FileCategory.LiquidationNote].category == FileCategory.Empty
        ) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(FileCategory.LiquidationNote),
                'A file with this hash does not exist'
            );
        }

        if (
            s_files[_houseId][username][FileCategory.SalaryReceipt].category == FileCategory.Empty
        ) {
            revert FileDoesNotExist(
                msg.sender,
                uint256(FileCategory.SalaryReceipt),
                'A file with this hash does not exist'
            );
        }

        string[] memory result = new string[](4);

        result[0] = s_files[_houseId][username][FileCategory.IdCard].hashFile;
        result[1] = s_files[_houseId][username][FileCategory.SalaryReceipt].hashFile;
        result[2] = s_files[_houseId][username][FileCategory.LiquidationNote].hashFile;
        result[3] = s_files[_houseId][username][FileCategory.IdCard].url;

        return result;
    }
}
